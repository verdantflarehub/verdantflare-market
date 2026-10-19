# Blender Chart 当前源码与交付状态

当前 `Chart.yaml` 的 `name` 为 `blender`，Chart 版本为 `0.1.0`，`appVersion` 为 `0.1.12`。2026-10-19 用户确定 `blender` 为正式 Hub AppID；旧 `blender-mcp` 目录资料与链接按 [Market 身份迁移设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/details/README.app-metadata-ui.md#411-blender-历史身份迁移)处理。

## 1. 当前事实

- 5090 dev 的 `verdantflare-app` 命名空间已有名为 `blender` 的 Helm release，版本 `0.1.0`，App Pod 运行镜像标签 `blender-v0.1.12`。旧 `verdantflare-blender` 命名空间的固定 Deployment 已缩为 0 副本。
- 本目录默认 values 含现场 Station、组织、安装标识及 PVC 名，属于当前环境导出的候选源码，不是可直接用于另一 Station 的通用默认值。
- 当前模板包含 Deployment、ClusterIP Service 和可选 PVC；不包含现场 Helm manifest 中的两个 NetworkPolicy。相同版本号不能证明这份源码可复现现场制品。
- 尚无由 Hub／Control 固定的原始 Chart 包及摘要，也没有经 Center→Station 分发并安装的 AppVersion。现有 Helm release 不转记为 Center 安装验收。

完整核对证据见 [Center、Chart 与 Station 基线](https://github.com/verdantflarehub/verdantflare-design/blob/dev/changes/archive/change_20261019_center_blender_baseline.md)。

## 2. 本地静态检查

```bash
helm lint charts/blender
helm template blender charts/blender --namespace verdantflare-app
```

静态渲染仅供核对模板，不进行 `helm upgrade --install`。交付前须把环境专属输入移至目标 values，补齐与现场网络策略对应的模板或明确版本差异，固定原始包与镜像摘要，并完成 Hub 审核和目标 Station 验证。Blender 的 GPU Worker 由 Station Runtime 创建，App Chart 不为满足旧审核器而重复申请 GPU。
