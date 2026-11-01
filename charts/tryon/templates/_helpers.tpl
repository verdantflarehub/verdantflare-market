{{- define "tryon.name" -}}
{{- .Values.workloadName | default "tryon-mcp-server" -}}
{{- end -}}
{{- define "tryon.labels" -}}
app.kubernetes.io/name: {{ include "tryon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: verdantflare
{{- end -}}
{{- define "tryon.annotations" -}}
station.verdantflare.com/app-id: {{ .Values.appId | quote }}
{{- range $key, $value := dict "station-id" .Values.station.stationId "organization-id" .Values.station.organizationId "installation-id" .Values.station.installationId "template-hash" .Values.station.templateHash }}
{{- if $value }}
station.verdantflare.com/{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end -}}
{{- define "tryon.claim" -}}
{{- if .Values.storage.create -}}
{{- if .Values.storage.existingClaim }}{{ fail "storage.create and storage.existingClaim are mutually exclusive" }}{{ end -}}
{{- printf "%s-data" .Release.Name -}}
{{- else -}}
{{- required "storage.existingClaim is required when storage.create=false" .Values.storage.existingClaim -}}
{{- end -}}
{{- end -}}
