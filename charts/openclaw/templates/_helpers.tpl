{{- define "candidate.name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "candidate.reviewGuard" -}}
{{- if .Values.install.enabled -}}
{{- if not (regexMatch "^sha256:[a-f0-9]{64}$" .Values.image.digest) -}}{{ fail "reviewed image.digest sha256 is required" }}{{- end -}}
{{- $_ := required "immutable image tag is required" .Values.image.tag -}}
{{- $_ := required "secret.existingName is required" .Values.secret.existingName -}}
{{- $_ := required "storage.storageClassName is required" .Values.storage.storageClassName -}}
{{- $_ := required "install.studioNamespace is required" .Values.install.studioNamespace -}}
{{- end -}}
{{- end -}}
