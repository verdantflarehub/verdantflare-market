# Blender MCP Chart 候选稿

> 状态：`0.2.0` 评审稿；只有本目录的 Chart 是通用交付源码。它尚未经 Hub 登记为 AppVersion，也未由 Station 安装。`values.yaml` 使用不可拉取的 `.invalid` 仓库，不能直接部署。

## 1. 当前依据

- [Market 总设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)：Hub／Control 管目录和发布，Station 管安装与运行。
- [Blender 现行部署记录](https://github.com/verdantflarehub/verdantflare-design/blob/dev/deploys/k8s.dev.verdantflarehub.com/verdantflare-blender/README.md)：5090 dev 的应用服务及 Runtime 动态实例事实。
- [GPU 资源管理规范](https://github.com/verdantflarehub/verdantflare-design/blob/dev/deploys/GPU.md)：5090 测试阶段 `nvidia.com/gpu: 1` 是 time-slicing 共享名额。
- [Chart 上传评审稿](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/chart-upload-review.draft.md)：静态检查和未完成的版本交接。

## 2. Chart 范围

2026-10-12 只读核对：Blender App `blender-v0.1.12` 在 Station 所在的 5090 dev 集群以声明式 Deployment 运行；`blender-worker-v0.1.8` 由 Station Runtime 按实例动态创建。原 `blender-a` Deployment 已为 0 副本。现行现场资源不是这个 Chart 安装的。

此 Chart 仅创建一个 Blender App Deployment、内部 8080 Service、受限入站 NetworkPolicy，以及在选择新建时创建 5 GiB 状态 PVC。App 不申请 GPU。Worker Pod、Worker Service、GPU 共享名额、工作卷池、实例 ACL 与生命周期属于 Station Runtime 的受控实例模板；安装 App 不自动创建编辑实例。本 Chart 不创建 Ingress、NodePort、Secret 或固定 Worker。

| 安装输入 | 目标 Station 须核对的事实 |
| --- | --- |
| `image.repository/tag/digest` | 完整 App 镜像；`digest` 是审核证据，Pod 仍用固定语义标签和 `Always` 拉取；安装前独立核对 Registry 标签映射 |
| `instance.configMapName` | 已存在、含 `instances.json` 的 ConfigMap；当前 App 仍读取此兼容配置 |
| `auth.existingSecretName` | 已存在、含 `BLENDER_STUDIO_TOKEN`、`BLENDER_WORKER_A`、`BLENDER_GUI_A_PASSWORD` 的 Secret；后两项是当前 App 的兼容输入，不代表部署固定 A Worker |
| `auth.contentSecretName` | 已存在、含 `token` 的内容服务 Secret |
| `auth.turnSecretName` | 已存在、含 `auth.conf` 的 Coturn 签发密钥 Secret；只挂载到 App |
| `contentOrigin`、`turn.host/port` | 目标 Station 的内部内容服务与客户侧可达的 TURN 地址 |
| `storage` | 目标已授权 PVC，或已验证的 StorageClass 和新建 5 GiB 状态卷；卸载保留数据 |
| `networkPolicy` | Studio 所在命名空间与 Pod 标签；仅 Studio 可访问 App 8080 |

现行 App Pod 的 `imageID` 摘要曾只读观察为 `sha256:61f8395b83d55734c64bd54494faa196605685e519047fb099146df9c5f407f5`；这不是独立的 Registry 标签复核，也不是这个 Chart 的安装证据。Worker 镜像、图形能力和 GPU 资源应在 Runtime 模板与目标 Station 的验证记录中锁定，不能通过 App Chart 的 `resources` 冒充。

## 3. 静态检查与限制

```bash
helm lint charts/blender
helm template blender charts/blender --namespace verdantflare-app
```

用目标 values 渲染时，模板要求真实镜像摘要、现有 ConfigMap、三份 Secret、内容服务、TURN 地址，以及 PVC 或 StorageClass；若给 App 填 GPU 请求则拒绝。默认渲染只用于审阅 YAML，不能 `helm upgrade --install`。

现有 Hub Chart 上传预检假设非 Agent 应用的 GPU 必须直接写在 Chart 顶层 `resources`，且要求 `image.tag` 为纯数字语义版本；这个 App 的 GPU Worker 属于 Runtime，镜像标签为 `blender-v0.1.12`。因此当前审核器会错误阻断本 Chart。不能为让静态报告变绿而给 App 申请 GPU 或伪造标签。需先更新审核器的工作负载分工与镜像身份规则，并完成 Chart 不可变分发和 Station 安装契约，才可把它登记为可安装候选。

不要将此 Chart 直接覆盖 5090 dev 的现有 Blender Deployment：当前资源不是 Helm 管理，且 App、卷和实例身份正在运行。迁移须另行计划、核对操作归属和保留数据。用户已明确不在两台 5090 上做实际应用测试；本稿只提供静态评审输入。
