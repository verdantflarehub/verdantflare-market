{{- define "blender-mcp.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "blender-mcp.labels" -}}
app.kubernetes.io/name: blender
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: verdantflare-blender
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- end -}}

{{- define "blender-mcp.validate" -}}
{{- if or (hasKey .Values.resources.requests "nvidia.com/gpu") (hasKey .Values.resources.limits "nvidia.com/gpu") (hasKey .Values.resources.requests "nvidia.com/gpu.shared") (hasKey .Values.resources.limits "nvidia.com/gpu.shared") -}}
  {{- fail "Blender App 不申请 GPU；Worker GPU 名额由 Station Runtime 实例模板管理" -}}
{{- end -}}
{{- if not (contains ".invalid/" .Values.image.repository) -}}
  {{- if not (regexMatch "^sha256:[a-f0-9]{64}$" .Values.image.digest) -}}
    {{- fail "Blender 安装前必须登记已核验的 App 镜像摘要" -}}
  {{- end -}}
  {{- if or (not .Values.instance.configMapName) (not .Values.auth.existingSecretName) (not .Values.auth.contentSecretName) (not .Values.auth.turnSecretName) (not .Values.contentOrigin) (not .Values.turn.host) -}}
    {{- fail "Blender 安装前必须提供实例 ConfigMap、三份受控 Secret、内容服务与 TURN 地址" -}}
  {{- end -}}
  {{- if and .Values.storage.create (not .Values.storage.storageClassName) -}}
    {{- fail "Blender 新建状态卷必须指定目标 Station 已验证的 StorageClass" -}}
  {{- end -}}
  {{- if and (not .Values.storage.create) (not .Values.storage.existingClaim) -}}
    {{- fail "Blender 必须新建状态卷或使用已有授权 PVC" -}}
  {{- end -}}
  {{- if and .Values.storage.create .Values.storage.existingClaim -}}
    {{- fail "Blender 状态卷不能同时新建并引用已有 PVC" -}}
  {{- end -}}
{{- end -}}
{{- end -}}
