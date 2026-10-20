# Google 渠道应用 Helm Chart

## 1. 当前依据

- [App Helm Chart 发布与更新方案](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/details/README.app-release-update.md)：每 App 一个 Chart 与 Helm 安装／更新／卸载简版设计。
- [多模态渠道应用契约 v1](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/contracts/channel-provider-v1.md)：根目录 `channel.yaml`、双监听与 etcd 发现边界。
- [Google 渠道应用设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/app/google/README.md)：`google` 渠道账号、执行与日志规范。
- [World 分析执行契约](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/contracts/world-analysis-v1.md)：独立分析、验证状态与恢复边界。

## 2. Chart 范围与资源

本目录维护 `google`（Google 渠道管理）的通用 Helm Chart（`charts/google/`），对应源码仓库 `verdantflare-app-google`。

| 文件或模板 | 职责说明 |
| --- | --- |
| `Chart.yaml` / `logo.svg` | 声明 `name: google`（自动发现 AppID）与渠道品牌图标 |
| `channel.yaml` | 声明图像能力及待验证的分析模型 |
| `templates/configmap-channel.yaml` | 将 `channel.yaml` 生成为 ConfigMap 并挂载至 `/etc/verdantflare/channel.yaml` |
| `templates/deployment.yaml` | 单副本 `Recreate` Deployment（管理端口 `8000`、执行端口 `8001`、探针 `/health`） |
| `templates/service.yaml` | 内部 ClusterIP Service `google-channel` |
| `templates/pvc.yaml` | 可选新建状态卷（带 `helm.sh/resource-policy: keep`，卸载保留数据）或复用已有 `google-channel` PVC |
| `templates/networkpolicy.yaml` | 现行内部入站规则；仍含同命名空间与指定命名空间准入，不能称为逐调用方隔离 |

## 3. 本地校验

```bash
helm lint charts/google
helm template google charts/google --namespace verdantflare-app
```

## 4. 分析适配输入

`analysis.enabled` 默认关闭；专用令牌来自 `analysis.existingSecretName` 的 `analysis.tokenKey`，不能与既有执行令牌共用。关闭不删除调用记录，已存在令牌时仍可查询历史结果。Secret 不在本 Chart 中生成或写入包。

分析模型声明保留 `adapter_connected_unverified`，即使运行开关开启也不接受普通新调用。只有真实适配验证通过、声明随新 Chart 发布为 `enabled` 后才开放；源码和镜像交付不等于数字世界完整分析流程上线。安装时按中央契约核验实际来源网络边界，不能以旧策略的宽准入作为新增外部入口依据。

### 4.1 分析专用 TLS

`analysis.tls.enabled` 默认关闭。启用时必须提供 `analysis.tls.existingSecretName`，其 `tls.crt`／`tls.key` 只读挂载；独立分析令牌即使在新调用关闭时也必须存在，以便恢复原任务。固定 8002 端口只提供分析执行协议，旧 8000／8001 保持原协议。

TLS 启用必须同时启用 NetworkPolicy。Chart 对 8002 只允许 `analysis.tls.worldNamespace` 中 `app.kubernetes.io/name=analysis.tls.worldPodName` 的工作负载；部署前核对集群其他策略的并集，宽泛的既有允许规则不能覆盖这一边界。World 使用实际内部服务 DNS 与 CA 校验连接，不关闭证书校验，不创建公网入口。

