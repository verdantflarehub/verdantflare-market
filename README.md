# VerdantFlare Market

VerdantFlare 应用交付仓库，集中维护 Helm Chart 源码与打包配套。

当前状态：仓库初始化，首个交付样本为 Blender；`charts/verdantflare-app-blender/` 仅是交付准备入口，尚无可安装 Chart、已发布制品或 Station 安装结果。

## 目录

```text
charts/
  verdantflare-app-blender/  # 与应用源码项目同名
```

目录使用应用源码项目名称；目录名与 Hub App ID 分别管理。成熟 Chart 按应用独立版本化，包含 `Chart.yaml`、`values.yaml`、`values.schema.json` 与 `templates/`。公共打包工具在出现实际复用需求时放入 `scripts/`。构建产物保存在被忽略的 `dist/`，发布后由受控制品仓库保存。

## 开发与交付

应用代码和镜像构建由各 `verdantflare-app-*` 项目维护；本仓库消费固定镜像及摘要，维护相应 Chart。应用管理元数据、版本登记、发布与授权由 Hub／Control 承接。具体集群的 values 和部署记录统一保存在设计仓库 `deploys/`。

先补齐 [Blender 交付准备](charts/verdantflare-app-blender/README.md)中的实现依据，再建立可渲染的 Chart，完成本地校验、打包和目标环境验收。当前未配置 CI/CD；制品存储、签名和发布接口仍按设计仓库的 D1/D2 落实。

GitHub 默认分支为 `main`，日常开发及工作区子模块跟踪 `dev`。初始化时两者指向同一份已检查的仓库骨架；后续发布遵循 `dev` → `release` 快进构建交付 → 验证后同步 `main` 的工作区流程，仓库初始化不表示应用已发布。

## 设计入口

- [Market 总体设计与仓库职责](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)
- [应用开发与交付指南](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/guides/market-app-development.md)
- [交付包契约](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/contracts/market-app-package.draft.md)
- [专项计划](https://github.com/verdantflarehub/verdantflare-design/blob/dev/plan/2026.10.market-app-lifecycle.plan.md)
- [GitHub Actions 应用指南](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/GithubAction.md)

产品/API 契约、跨模块决策和验收记录在设计仓库维护，本仓库只保留开发与构建所需说明。
