# VerdantFlare Market

VerdantFlare 应用交付仓库，集中维护 Helm Chart 源码与打包配套。

当前状态：Blender、ComfyUI、Concat、Whisper-WebUI、IndexTTS2、OpenClaw 与 Hermes Agent 均有 Chart 候选源码；旧版 Blender 方案保存在 `archive/`。这些源码不代表已有可安装 Chart、已发布制品或 Station 安装结果。

## 1. 目录

```text
charts/
  blender/
  comfyui/
  concat/
  hermes-agent/
  indextts2/
  openclaw/
  whisper-webui/
archive/
  blender-mcp-v0.1.2/  # 旧 App + Worker 固定部署样本
  blender-mcp-legacy/  # 更早的成都单容器样本
```

当前候选目录使用简短应用 slug，不加源码仓库前缀；目录名与 Hub App ID、Chart `name` 分别管理。例如 `charts/blender/` 的 Chart `name` 是 `blender-mcp`。每个 Chart 按应用独立版本化，包含 `Chart.yaml`、`values.yaml`、`values.schema.json` 与 `templates/`。`archive/` 只用于历史评审，不作为当前安装包来源。公共打包工具在出现实际复用需求时放入 `scripts/`。构建产物保存在被忽略的 `dist/`，发布后由受控制品仓库保存。

## 2. 开发与交付

应用代码和镜像构建由各 `verdantflare-app-*` 项目维护；本仓库消费固定镜像及摘要，维护相应 Chart。应用管理元数据、版本登记、发布与授权由 Hub／Control 承接。具体集群的 values 和部署记录统一保存在设计仓库 `deploys/`。

当前 [Blender Chart 候选](charts/blender/README.md)已可做本地静态校验，但默认镜像不可拉取，且 Control 审核、制品存储、签名、Station 安装及目标环境验收仍未闭环。其他候选同样须逐项补齐真实镜像、许可、依赖与验收证据；不能因集中到 Market 就视为可安装。当前未配置 CI/CD；制品存储、签名和发布接口仍按设计仓库的 D1/D2 落实。

GitHub 默认分支为 `main`，日常开发及工作区子模块跟踪 `dev`。初始化时两者指向同一份已检查的仓库骨架；后续发布遵循 `dev` → `release` 快进构建交付 → 验证后同步 `main` 的工作区流程，仓库初始化不表示应用已发布。

## 3. 设计入口

- [Market 总体设计与仓库职责](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)
- [应用开发与交付指南](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/guides/market-app-development.md)
- [交付包契约](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/contracts/market-app-package.draft.md)
- [专项计划](https://github.com/verdantflarehub/verdantflare-design/blob/dev/plan/2026.10.studio.appcenter.lifecycle.plan.md)
- [GitHub Actions 应用指南](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/GithubAction.md)

产品/API 契约、跨模块决策和验收记录在设计仓库维护，本仓库只保留开发与构建所需说明。
