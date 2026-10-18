# Google 渠道应用 Helm Chart

## 1. 当前依据

- [App Helm Chart 发布与更新方案](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/details/README.app-release-update.md)：每 App 一个 Chart 与 Helm 安装／更新／卸载简版设计。
- [多模态渠道应用契约 v1](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/contracts/channel-provider-v1.md)：根目录 `channel.yaml`、双监听与 etcd 发现边界。
- [Google 渠道应用设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/app/google/README.md)：`google` 渠道账号、执行与日志规范。

## 2. Chart 范围与资源

本目录维护 `google`（Google 渠道管理）的通用 Helm Chart（`charts/google/`），对应源码仓库 `verdantflare-app-google`。

| 文件或模板 | 职责说明 |
| --- | --- |
| `Chart.yaml` / `logo.svg` | 声明 `name: google`（自动发现 AppID）与渠道品牌图标 |
| `channel.yaml` | 声明 `channel_id: google` 及 `gemini-3.1-flash-image` 的 `image.generate`、`image.edit` 能力 |
| `templates/configmap-channel.yaml` | 将 `channel.yaml` 生成为 ConfigMap 并挂载至 `/etc/verdantflare/channel.yaml` |
| `templates/deployment.yaml` | 单副本 `Recreate` Deployment（管理端口 `8000`、执行端口 `8001`、探针 `/health`） |
| `templates/service.yaml` | 内部 ClusterIP Service `google-channel` |
| `templates/pvc.yaml` | 可选新建状态卷（带 `helm.sh/resource-policy: keep`，卸载保留数据）或复用已有 `google-channel` PVC |
| `templates/networkpolicy.yaml` | 限制 `8000` 仅允许 Studio／Runtime、`8001` 仅允许 Image MCP 访问 |

## 3. 本地校验

```bash
helm lint charts/google
helm template google charts/google --namespace verdantflare-app
```

