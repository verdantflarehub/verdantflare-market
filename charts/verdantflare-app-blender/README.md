# Blender Chart 交付准备

状态：首个交付样本，尚无可安装 Chart。此目录暂不包含 `Chart.yaml` 或部署模板，避免空 Chart 被误认为已完成部署包。

## 已有依据

- 目录 `charts/verdantflare-app-blender/` 与源码项目同名，现有 Hub App ID 仍为 `blender-mcp`。源码仓库为 [verdantflare-app-blender](https://github.com/verdantflarehub/verdantflare-app-blender)，当前仍是初始化骨架。
- [历史候选资料](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/examples/blender-mcp/blender-mcp.app-manifest.template.md)描述的是成都预演实例；其基础桌面镜像未包含完整应用代码，现场端口、GPU 数量和挂载不能直接当成新包默认值。
- Blender MCP 与多实例接入方案仍在设计仓库评审，具体入口由 [Market 总设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)维护；选择 Blender 为首个样本不等于批准其中的接口或实例模型。

## 建立 Chart 前需要的输入

| 输入                                       | 用途                                                 |
| ------------------------------------------ | ---------------------------------------------------- |
| 完整应用源码 revision、依赖和许可证        | 确定可复现构建来源与分发范围                         |
| 首版固定镜像及真实 digest                  | 让 Chart 锁定完整应用，而非依赖宿主机挂载代码        |
| 最小安装范围、进程入口、内部端口和健康检查 | 确定工作负载、Service 与探针；区分应用安装和编辑实例 |
| 持久化目录、Secret 引用、资源与 GPU 要求   | 定义配置 schema、预检和卸载保留行为                  |
| Studio 接入及内部访问规则                  | 约束 MCP 来源、实例控制通道与桌面交互边界            |

这些输入明确后，建立 `Chart.yaml`、`values.yaml`、`values.schema.json` 和 `templates/`，在本地进行 lint、渲染及拒绝路径检查。交付包版本与 Blender 上游版本分别记录，正式 `Chart.yaml.name` 按现行契约须与 Hub App ID 一致，独立于源码目录名称；应用身份改名需先在设计仓库定义迁移。

发布前仍须补齐不可变包存储、摘要／签名、Control 版本关联和目标 Station 实装证据。任务状态统一更新到设计仓库的 [Market 专项计划](https://github.com/verdantflarehub/verdantflare-design/blob/dev/plan/2026.10.market-app-lifecycle.plan.md)。
