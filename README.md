# VerdantFlare Market

VerdantFlare 应用交付仓库，集中维护 Helm Chart 源码与打包配套。

当前状态：`charts/` 下包含 14 个 Station 受管应用 Chart 与 5 个仅评审候选 Chart（共 19 个）；旧版 Blender 方案保存在 `archive/`。

## 1. 目录

```text
charts/
  blender/                       # Station 受管应用（Chart name = appId = blender）
  chatgpt/                       # Station 渠道应用（含 channel.yaml ConfigMap 挂载）
  comfyui/                       # Station 受管应用
  concat/                        # 候选评审 Chart（非 Station 可安装）
  fal/                           # Station 渠道应用（含 channel.yaml ConfigMap 挂载）
  google/                        # Station 渠道应用（含 channel.yaml ConfigMap 挂载）
  grok/                          # Station 渠道应用（含 channel.yaml ConfigMap 挂载）
  hermes-agent/                  # 候选评审 Chart（非 Station 可安装）
  higgsfield/                    # Station 渠道应用（含 channel.yaml ConfigMap 挂载）
  image-mcp/                     # Station 领域 MCP 应用
  indextts2/                     # 候选评审 Chart（非 Station 可安装）
  music-mcp/                     # Station 领域 MCP 应用
  network/                       # Station 系统应用
  openclaw/                      # 候选评审 Chart（非 Station 可安装）
  project/                       # Station 系统应用
  resources/                     # Station 系统应用
  video-mcp/                     # Station 领域 MCP 应用
  video-minimax-h3-singularity/  # Station 本地视频渠道运行时（含 channel.yaml ConfigMap 挂载）
  whisper-webui/                 # 候选评审 Chart（非 Station 可安装）
scripts/
  publish-charts.sh              # OCI Chart 校验、打包、防覆盖检查、推送与匿名回拉双摘要核验脚本
archive/
  blender-mcp-v0.1.2/            # 旧 App + Worker 固定部署样本
  blender-mcp-legacy/            # 更早的成都单容器样本
```

当前目录使用简短、稳定的应用 slug，不加源码仓库前缀；14 个 Station 受管 Chart 的目录名、Hub `appId` 与 `Chart.yaml` 中的 `name` 严格一致（例如 `charts/blender/` 的 Chart `name` 与正式 `appId` 均为 `blender`）。每个 Station Chart 在 `Chart.yaml` 的 `annotations` 中声明 `verdantflare.com/app-id`、`verdantflare.com/capabilities`、`verdantflare.com/models`、`verdantflare.com/images` 及可选 `verdantflare.com/logo-file`、`verdantflare.com/channel-file`，供 Control 在登记 `AppVersion` 时从原包直接提取并核验。包含 `channel.yaml` 的 6 个渠道 Chart 均通过 `templates/configmap-channel.yaml` 渲染 ConfigMap 并挂载至 `/etc/verdantflare/channel.yaml`。所有含 `templates/pvc.yaml` 的 16 个 Chart 均保留 `helm.sh/resource-policy: keep`。

`archive/` 只用于历史评审，不作为当前安装包来源。构建产物保存在被忽略的 `dist/` 或 `.tmp/`，发布后由公开 OCI Registry（`oci://registry.verdantflare.ai/charts`）保存。

## 2. 开发与交付

应用代码和镜像构建由各 `verdantflare-app-*` 项目维护；本仓库消费固定语义化版本镜像，维护相应 Chart。应用管理元数据、不可变 `AppVersion` 登记、发布选择与组织可见性由 Hub／Control 承接。具体集群的环境 Values 和部署说明统一保存在设计仓库 `deploys/`。

工作流 `.github/workflows/publish-charts.yml` 配合 `scripts/publish-charts.sh` 执行 `helm lint`、`helm template`、`helm dependency build`、`helm package`，在推送 `oci://registry.verdantflare.ai/charts` 前检查远端同版本是否存在并拒绝不同摘要覆盖，推送后执行匿名回拉并核验 OCI `manifestDigest` 与 `.tgz` `packageDigest` 双摘要，输出结构化 JSON 摘要供 Control 登记固定 `AppVersion`。

GitHub 默认分支为 `main`，日常开发及工作区子模块跟踪 `dev`；发布遵循 `dev` → `release` 快进触发构建交付 → 验证后同步 `main` 的工作区流程。

## 3. 设计入口

- [Market 总体设计与仓库职责](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)
- [Market 技术架构与双摘要契约](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/technical-architecture.md)
- [Chart 发布与更新方案](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/details/README.app-release-update.md)
- [公开 Chart Registry 设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/details/README.chart-registry.md)
- [打通 App 下载、安装、更新、卸载全流程与 Market 协作计划](https://github.com/verdantflarehub/verdantflare-design/blob/dev/plan/2026.10.hub-market-app-lifecycle.plan.md)
- [GitHub Actions 应用指南](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/GithubAction.md)

产品/API 契约、跨模块决策和验收记录在设计仓库维护，本仓库只保留开发与构建所需说明。
