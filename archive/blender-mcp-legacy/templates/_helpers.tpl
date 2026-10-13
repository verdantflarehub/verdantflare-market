{{- define "blender-mcp.name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "blender-mcp.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "blender-mcp.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- define "blender-mcp.validateInstall" -}}
{{- if not (contains ".invalid/" .Values.image.repository) -}}
  {{- if eq .Chart.AppVersion "pending-build" -}}
    {{- fail "Blender MCP 安装前必须登记已构建镜像的真实 appVersion" -}}
  {{- end -}}
  {{- if not .Values.image.digest -}}
    {{- fail "Blender MCP 安装前必须提供已审核的 image.digest" -}}
  {{- end -}}
  {{- if not .Values.auth.existingSecretName -}}
    {{- fail "Blender MCP 安装前必须提供 Station 管理的 auth.existingSecretName" -}}
  {{- end -}}
  {{- if and .Values.storage.create (not .Values.storage.existingClaim) (not .Values.storage.storageClassName) -}}
    {{- fail "Blender MCP 新建 PVC 必须指定目标 Station 已验证的 storage.storageClassName" -}}
  {{- end -}}
  {{- if and (not .Values.storage.create) (not .Values.storage.existingClaim) -}}
    {{- fail "Blender MCP 必须新建 PVC 或提供已授权的 storage.existingClaim" -}}
  {{- end -}}
{{- end -}}
{{- end -}}
