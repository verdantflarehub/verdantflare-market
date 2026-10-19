#!/usr/bin/env bash
set -euo pipefail

REGISTRY_HOST="${REGISTRY_HOST:-registry.verdantflare.ai}"
DIST_DIR="${DIST_DIR:-.tmp/chart-packages}"
SUMMARY_FILE="${SUMMARY_FILE:-${DIST_DIR}/published-charts.json}"
DRY_RUN="${DRY_RUN:-0}"

DEFAULT_STATION_CHARTS=(
  blender
  chatgpt
  comfyui
  fal
  google
  grok
  higgsfield
  image-mcp
  music-mcp
  network
  project
  resources
  video-mcp
  video-minimax-h3-singularity
)

if [[ $# -gt 0 ]]; then
  TARGET_CHARTS=("$@")
elif [[ -n "${CHARTS:-}" ]]; then
  read -r -a TARGET_CHARTS <<< "${CHARTS}"
else
  TARGET_CHARTS=("${DEFAULT_STATION_CHARTS[@]}")
fi

WORK_DIR="$(mktemp -d)"
export HELM_REGISTRY_CONFIG="${WORK_DIR}/registry-auth.json"
ANON_REGISTRY_CONFIG="${WORK_DIR}/registry-anon.json"
VERIFY_DIR="${WORK_DIR}/verify"
mkdir -p "${DIST_DIR}" "${VERIFY_DIR}"

cleanup() {
  if [[ -f "${HELM_REGISTRY_CONFIG}" ]]; then
    helm registry logout "${REGISTRY_TRANSPORT_HOST:-${REGISTRY_HOST}}" >/dev/null 2>&1 || true
  fi
  rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

REGISTRY_TRANSPORT_HOST="${REGISTRY_TRANSPORT_HOST:-}"
if [[ "${DRY_RUN}" != "1" ]]; then
  if [[ -z "${REGISTRY_TRANSPORT_HOST}" ]]; then
    if curl -sS --connect-timeout 5 -I "https://${REGISTRY_HOST}/v2/" >/dev/null 2>&1; then
      REGISTRY_TRANSPORT_HOST="${REGISTRY_HOST}"
    elif curl -sS --connect-timeout 5 -I "https://registry.verdantflarehub.com/v2/" >/dev/null 2>&1; then
      REGISTRY_TRANSPORT_HOST="registry.verdantflarehub.com"
      echo "INFO: ${REGISTRY_HOST} public HTTPS not reachable; using transport host ${REGISTRY_TRANSPORT_HOST} for identical Registry service"
    else
      REGISTRY_TRANSPORT_HOST="${REGISTRY_HOST}"
    fi
  fi
  if [[ -z "${REGISTRY_PUBLISH_USERNAME:-}" || -z "${REGISTRY_PUBLISH_PASSWORD:-}" ]]; then
    echo "ERROR: REGISTRY_PUBLISH_USERNAME and REGISTRY_PUBLISH_PASSWORD are required when DRY_RUN!=1" >&2
    exit 1
  fi
  printf '%s' "${REGISTRY_PUBLISH_PASSWORD}" | helm registry login "${REGISTRY_TRANSPORT_HOST}" \
    --username "${REGISTRY_PUBLISH_USERNAME}" \
    --password-stdin
fi

echo "[]" > "${SUMMARY_FILE}"

for chart in "${TARGET_CHARTS[@]}"; do
  chart_dir="charts/${chart}"
  if [[ ! -d "${chart_dir}" ]]; then
    echo "ERROR: Chart directory not found: ${chart_dir}" >&2
    exit 1
  fi

  if grep -Eq 'candidate-not-installable|delivery-status:\s*candidate' "${chart_dir}/Chart.yaml"; then
    echo "ERROR: Refusing to publish review-only candidate chart: ${chart}" >&2
    exit 1
  fi

  echo "=== Validating ${chart} ==="
  helm lint "${chart_dir}"
  helm template "${chart}" "${chart_dir}" --namespace verdantflare-app >/dev/null

  chart_meta="$(python3 -c '
import json, sys, yaml
with open(sys.argv[1], "r", encoding="utf-8") as f:
    doc = yaml.safe_load(f)
print(json.dumps({
    "name": str(doc.get("name", "")),
    "version": str(doc.get("version", "")),
    "appVersion": str(doc.get("appVersion", "")),
    "appId": str((doc.get("annotations") or {}).get("verdantflare.com/app-id") or doc.get("name", ""))
}))
' "${chart_dir}/Chart.yaml")"

  chart_name="$(echo "${chart_meta}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])')"
  chart_version="$(echo "${chart_meta}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])')"
  app_version="$(echo "${chart_meta}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["appVersion"])')"
  app_id="$(echo "${chart_meta}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["appId"])')"

  if [[ "${chart_name}" != "${chart}" || "${app_id}" != "${chart}" ]]; then
    echo "ERROR: Chart identity mismatch for ${chart}: name=${chart_name}, appId=${app_id}" >&2
    exit 1
  fi

  helm dependency build "${chart_dir}" >/dev/null
  helm package "${chart_dir}" --destination "${DIST_DIR}" >/dev/null

  pkg_file="${DIST_DIR}/${chart_name}-${chart_version}.tgz"
  if [[ ! -f "${pkg_file}" ]]; then
    echo "ERROR: Packaged file not found: ${pkg_file}" >&2
    exit 1
  fi

  package_digest="sha256:$(sha256sum "${pkg_file}" | awk '{print $1}')"
  package_size="$(wc -c < "${pkg_file}" | tr -d ' ')"
  oci_ref="oci://${REGISTRY_HOST}/charts/${chart_name}"
  manifest_digest=""

  if [[ "${DRY_RUN}" != "1" ]]; then
    transport_oci_ref="oci://${REGISTRY_TRANSPORT_HOST}/charts/${chart_name}"
    manifest_url="https://${REGISTRY_TRANSPORT_HOST}/v2/charts/${chart_name}/manifests/${chart_version}"
    manifest_body="${WORK_DIR}/${chart_name}-${chart_version}.manifest.json"
    manifest_headers="${WORK_DIR}/${chart_name}-${chart_version}.headers.txt"

    http_code="$(curl -sS -D "${manifest_headers}" -o "${manifest_body}" -w '%{http_code}' \
      -H 'Accept: application/vnd.oci.image.manifest.v1+json' \
      "${manifest_url}")"

    if [[ "${http_code}" == "200" ]]; then
      remote_pkg_digest="$(python3 -c '
import json, sys
with open(sys.argv[1], "rb") as f:
    doc = json.load(f)
layers = doc.get("layers") or []
for layer in layers:
    if "tar+gzip" in layer.get("mediaType", ""):
        print(layer.get("digest", ""))
        break
' "${manifest_body}")"
      rm -f "${VERIFY_DIR}/${chart_name}-${chart_version}.tgz"
      HELM_REGISTRY_CONFIG="${ANON_REGISTRY_CONFIG}" helm pull "${transport_oci_ref}" \
        --version "${chart_version}" \
        --destination "${VERIFY_DIR}"
      pulled_file="${VERIFY_DIR}/${chart_name}-${chart_version}.tgz"
      pulled_digest="sha256:$(sha256sum "${pulled_file}" | awk '{print $1}')"
      pulled_size="$(wc -c < "${pulled_file}" | tr -d ' ')"
      if [[ "${pulled_digest}" != "${remote_pkg_digest}" ]]; then
        echo "ERROR: Remote OCI layer digest (${remote_pkg_digest}) != pulled .tgz sha256 (${pulled_digest})" >&2
        exit 1
      fi
      python3 -c '
import hashlib, sys, tarfile
def archive_tree_hash(path):
    items = {}
    with tarfile.open(path, "r:gz") as tf:
        for m in tf.getmembers():
            if m.isfile():
                data = tf.extractfile(m).read()
                items[m.name] = hashlib.sha256(data).hexdigest()
    return items
remote_tree = archive_tree_hash(sys.argv[1])
local_tree = archive_tree_hash(sys.argv[2])
if remote_tree != local_tree:
    sys.stderr.write(f"Archive content mismatch: remote={remote_tree} vs local={local_tree}\n")
    sys.exit(1)
' "${pulled_file}" "${pkg_file}" || {
        echo "ERROR: Refusing to overwrite ${chart_name}:${chart_version} (chart content changed without version bump)" >&2
        exit 1
      }
      package_digest="${pulled_digest}"
      package_size="${pulled_size}"
      cp -f "${pulled_file}" "${pkg_file}"
      echo "Chart ${chart_name}:${chart_version} already published with matching content (packageDigest=${package_digest})"
    elif [[ "${http_code}" == "404" ]]; then
      echo "Pushing ${pkg_file} to oci://${REGISTRY_TRANSPORT_HOST}/charts ..."
      helm push "${pkg_file}" "oci://${REGISTRY_TRANSPORT_HOST}/charts"
      rm -f "${VERIFY_DIR}/${chart_name}-${chart_version}.tgz"
      HELM_REGISTRY_CONFIG="${ANON_REGISTRY_CONFIG}" helm pull "${transport_oci_ref}" \
        --version "${chart_version}" \
        --destination "${VERIFY_DIR}"
      pulled_file="${VERIFY_DIR}/${chart_name}-${chart_version}.tgz"
      pulled_digest="sha256:$(sha256sum "${pulled_file}" | awk '{print $1}')"
      pulled_size="$(wc -c < "${pulled_file}" | tr -d ' ')"
      if [[ "${pulled_digest}" != "${package_digest}" || "${pulled_size}" != "${package_size}" ]]; then
        echo "ERROR: Anonymous pull verification failed for ${chart_name}:${chart_version}" >&2
        exit 1
      fi
    else
      echo "ERROR: Unexpected HTTP status ${http_code} checking ${manifest_url}" >&2
      cat "${manifest_body}" >&2 || true
      exit 1
    fi

    http_code="$(curl -sS -D "${manifest_headers}" -o "${manifest_body}" -w '%{http_code}' \
      -H 'Accept: application/vnd.oci.image.manifest.v1+json' \
      "${manifest_url}")"
    if [[ "${http_code}" != "200" ]]; then
      echo "ERROR: Failed to fetch OCI manifest after push (HTTP ${http_code})" >&2
      exit 1
    fi
    manifest_digest="sha256:$(sha256sum "${manifest_body}" | awk '{print $1}')"
    header_digest="$(awk 'tolower($1)=="docker-content-digest:" {gsub("\r","",$2); print $2}' "${manifest_headers}" | tail -n 1)"
    if [[ -n "${header_digest}" && "${header_digest}" != "${manifest_digest}" ]]; then
      echo "ERROR: OCI manifest header digest (${header_digest}) != body sha256 (${manifest_digest})" >&2
      exit 1
    fi
    echo "Verified ${oci_ref}:${chart_version} -> manifestDigest=${manifest_digest}, packageDigest=${package_digest}"
  fi

  python3 -c '
import json, sys
summary_path, entry_json = sys.argv[1], sys.argv[2]
with open(summary_path, "r", encoding="utf-8") as f:
    items = json.load(f)
items.append(json.loads(entry_json))
with open(summary_path, "w", encoding="utf-8") as f:
    json.dump(items, f, indent=2, ensure_ascii=False)
' "${SUMMARY_FILE}" "$(python3 -c '
import json, sys
print(json.dumps({
    "appId": sys.argv[1],
    "version": sys.argv[2],
    "chartName": sys.argv[3],
    "chartVersion": sys.argv[4],
    "appVersion": sys.argv[5],
    "ociRef": sys.argv[6],
    "manifestDigest": sys.argv[7],
    "packageDigest": sys.argv[8],
    "packageSizeBytes": int(sys.argv[9]),
}))
' "${app_id}" "${app_version}" "${chart_name}" "${chart_version}" "${app_version}" "${oci_ref}" "${manifest_digest}" "${package_digest}" "${package_size}")"
done

echo "Summary written to ${SUMMARY_FILE}"
