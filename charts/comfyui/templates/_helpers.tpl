{{- define "comfyui.name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "comfyui.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "comfyui.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- define "comfyui.validateInstall" -}}
{{- if not (contains ".invalid/" .Values.image.repository) -}}
  {{- if not .Values.image.digest -}}
    {{- fail "ComfyUI 安装前必须提供已审核的 image.digest" -}}
  {{- end -}}
  {{- if and .Values.storage.create (not .Values.storage.existingClaim) (not .Values.storage.storageClassName) -}}
    {{- fail "ComfyUI 新建 PVC 必须指定目标 Station 已验证的 storage.storageClassName" -}}
  {{- end -}}
  {{- if and (not .Values.storage.create) (not .Values.storage.existingClaim) -}}
    {{- fail "ComfyUI 必须新建 PVC 或提供已授权的 storage.existingClaim" -}}
  {{- end -}}
{{- end -}}
{{- end -}}
