{{- define "blender-mcp.appName" -}}{{ .Release.Name | trunc 55 | trimSuffix "-" }}{{- end -}}
{{- define "blender-mcp.workerName" -}}{{ printf "%s-%s" .Release.Name .Values.instance.alias | trunc 63 | trimSuffix "-" }}{{- end -}}
{{- define "blender-mcp.labels" -}}
app.kubernetes.io/part-of: blender-mcp
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
{{- define "blender-mcp.validate" -}}
{{- if or (ne (int (index .Values.resources.worker.requests "nvidia.com/gpu")) 1) (ne (int (index .Values.resources.worker.limits "nvidia.com/gpu")) 1) -}}
  {{- fail "Blender Worker 必须申请且限制整张 nvidia.com/gpu: 1" -}}
{{- end -}}
{{- if or (not (contains ".invalid/" .Values.images.app.repository)) (not (contains ".invalid/" .Values.images.worker.repository)) -}}
  {{- if or (not .Values.images.app.digest) (not .Values.images.worker.digest) -}}
    {{- fail "Blender 安装前必须提供两个已审核的镜像摘要" -}}
  {{- end -}}
  {{- if or (not .Values.instance.configMapName) (not .Values.auth.secretName) (not .Values.auth.contentSecretName) (not .Values.contentOrigin) -}}
    {{- fail "Blender 安装前必须提供实例 ConfigMap、两份受控 Secret 和内容服务地址" -}}
  {{- end -}}
  {{- if and (or .Values.storage.app.create .Values.storage.worker.create) (not .Values.storage.storageClassName) -}}
    {{- fail "Blender 新建 PVC 必须指定已验证的 StorageClass" -}}
  {{- end -}}
  {{- if and (not .Values.storage.app.create) (not .Values.storage.app.existingClaim) -}}
    {{- fail "Blender App 必须使用已有 PVC 或新建 PVC" -}}
  {{- end -}}
  {{- if and (not .Values.storage.worker.create) (not .Values.storage.worker.existingClaim) -}}
    {{- fail "Blender Worker 必须使用已有 PVC 或新建 PVC" -}}
  {{- end -}}
{{- end -}}
{{- end -}}
