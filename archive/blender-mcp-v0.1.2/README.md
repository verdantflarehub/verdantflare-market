# Blender MCP Chart 评审稿

> 历史样本：本目录保留 2026-10-10 的 v0.1.2 固定 App + Worker 双 Deployment 方案供追溯，已不符合 Station Runtime 动态实例现状。现行通用 Chart 候选源码仅在 [`charts/blender/`](../../charts/blender/README.md) 维护；不得将本目录的 Chart 上传为当前安装包。

本 Chart 对应 2026-10-10 时 `verdantflare-app-blender` v0.1.2 的 **App + GPU Worker** 两镜像结构。源码提交以构建记录为准；两份镜像均包含各自运行代码，旧成都 KDE6 单容器方案保存在相邻的 `../blender-mcp-legacy/`，不能用于当前交付。

## 交付结构

- App 提供内部 8080 端口，持有实例目录和 5Gi 状态卷，负责 Studio 的受控 MCP 入口；Worker 持有独占 `nvidia.com/gpu: 1`、50Gi 工作卷、图形运行环境和 48083/48084/48085 内部端口。均为单副本 `Recreate`。
- 两个 Service 均为 `ClusterIP`。NetworkPolicy 仅允许 Station 命名空间的 Studio 到 App 8080 和 Worker GUI 48083，以及 App 到 Worker 内部端口；实际应用协议还必须逐请求鉴权。不创建 Ingress、NodePort 或公网 MCP 入口。
- App 以 UID 10001、只读根文件系统、丢弃 capabilities、`RuntimeDefault` 运行。Worker 以 UID 1000、`RuntimeDefault`、非 privileged 运行；其图形栈当前需要 `allowPrivilegeEscalation: true`，这是现行实例观察到的最小已运行组合，仍需在目标环境重新审查。
- 凭据和实例目录仅引用目标命名空间预先存在的 Secret/ConfigMap，Chart 不创建或携带凭据。`auth.secretName` 必须含 `BLENDER_WORKER_A`、`BLENDER_STUDIO_TOKEN`、`BLENDER_GUI_A_PASSWORD`；`auth.contentSecretName` 必须含 `token`。模板还需要实例 ConfigMap 的 `instances.json`、`instance-a-id` 和受控 `contentOrigin`。
- 默认镜像仓库是 `.invalid`，这些默认值只用于静态审阅。`values.images-0.1.2.yaml` 只记录现行 Pod 观察到的两份镜像身份；切到真实仓库时，两个 `images.*.digest` 必须填写安装前核验的 Registry 摘要作为审核证据。Pod 镜像引用使用语义化标签与 `Always`，遵循工作区部署规范。
- 新建 PVC 时须指定目标环境已核验的 StorageClass；如果采用静态供应类，先准备独立 PV，不能借用别的业务卷。也可由 Station 指定已授权的 `existingClaim`。卸载后 PVC 保留，由 Station 管理数据归属。

## 已有运行制品的只读证据

2026-10-10 只读盘点的 Pod `imageID` 显示：App `blender-v0.1.2` 摘要为 `sha256:864e70747d05c66d3f8aa46d87cbde3dc14606cf310c3ae9f6085b884612ceec`；Worker `blender-worker-v0.1.2` 为 `sha256:6c440b9f550eeedf50fecf2b283f8d061af75102cf2ef4709e2d5602e93cb151`。当前运行实例拥有就绪的 App/Worker Pod、独立 PVC 和上述 Secret/ConfigMap 键，Worker 镜像内有 Blender 与 MCP 代码。安装前仍须从 Registry 复核标签对应摘要；此证据不等于本 Chart 已安装验收，也不证明客户入口或工具调用通过。

## 静态审核

```bash
helm lint archive/blender-mcp-v0.1.2
helm template review archive/blender-mcp-v0.1.2 --namespace review
```

实际安装覆盖值必须由目标 Station 管理，并逐一核验镜像标签和摘要、Secret/ConfigMap 键、内容服务、PV/PVC、整卡 GPU、图形设备、安全上下文、Studio 授权与 NetworkPolicy。用户已明确不在两台 5090 上实际测试；此稿没有安装、占用 GPU 或触发图形会话。
