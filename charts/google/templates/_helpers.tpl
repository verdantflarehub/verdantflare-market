{{- define "google.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "google.selectorLabels" -}}
app.kubernetes.io/name: {{ include "google.fullname" . }}
{{- end -}}

{{- define "google.labels" -}}
{{ include "google.selectorLabels" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: verdantflare-app
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end -}}

{{- define "google.validate" -}}
{{- if and .Values.storage.create (not .Values.storage.storageClassName) -}}
  {{- fail "Google 渠道新建状态卷必须指定 StorageClass" -}}
{{- end -}}
{{- if and (not .Values.storage.create) (not .Values.storage.existingClaim) -}}
  {{- fail "Google 渠道必须新建状态卷或引用已有 PVC" -}}
{{- end -}}
{{- end -}}

