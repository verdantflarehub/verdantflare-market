{{- define "whisper-webui.name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "whisper-webui.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "whisper-webui.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- define "whisper-webui.validateInstall" -}}
{{- if not (contains ".invalid/" .Values.image.repository) -}}
  {{- if not .Values.image.digest -}}
    {{- fail "Controlled image digest is required before install" -}}
  {{- end -}}
  {{- if and .Values.storage.create (not .Values.storage.existingClaim) (not .Values.storage.storageClassName) -}}
    {{- fail "Target Station StorageClass must be verified before install" -}}
  {{- end -}}
  {{- if and (not .Values.storage.create) (not .Values.storage.existingClaim) -}}
    {{- fail "A new or authorized existing PVC is required" -}}
  {{- end -}}
  {{- if or not .Values.review.accessApproved not .Values.review.licenseApproved not .Values.review.modelAssetsApproved -}}
    {{- fail "License, assets, access and required Secret reviews must be completed before install" -}}
  {{- end -}}
{{- end -}}
{{- end -}}
