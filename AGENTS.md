# VerdantFlare Market

本仓库维护各应用的通用 Helm Chart 源码及打包配套。产品与部署设计以 [verdantflare-design 工作区规范](https://github.com/verdantflarehub/verdantflare-design/blob/dev/AGENTS.md)和 [Market 总设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)为准；在父工作区内工作时优先读取对应本地文件。

- 当前候选按简短、稳定的应用 slug 存放在 `charts/<app-slug>/`，不用 `verdantflare-app-` 等仓库前缀。例如 `charts/blender/` 对应源码项目 `verdantflare-app-blender`，其正式 Hub App ID 与 Chart `name` 均为 `blender`；一般情形下目录名不作为应用身份。过时的 Chart 仅在 `archive/` 留作历史对照，不作为当前候选上传。
- Hub／Control 持有管理元数据、版本索引和授权；本仓库不维护另一套可编辑市场目录，也不新增业务服务。
- 一个 Chart 只保留一份权威源码。集群专属 values、固定版本引用及部署记录归设计仓库 `deploys/`，不将某个现场实例复制为通用默认值。
- 新 Chart 必须依据真实镜像、启动方式、端口、健康检查、存储与资源契约实现。资料缺失时明确记录准备状态，不虚构可安装包或验收结果。
- MCP 对外统一经 Studio；Chart 不为下游 MCP 增加独立公网入口，内部访问按路径或端口与身份边界控制。
- GitHub 默认分支为 `main`，保存验证后的稳定版本；使用 `dev` 开发，`release` 仅从 `dev` 快进。初始化时先建立 `main`，再建立开发分支。发布、推送及部署按当前任务授权范围和工作区规范执行。
- 格式、Chart lint、渲染及契约检查在本地执行；建立真实 Chart 后按改动验证渲染结果与拒绝路径。CI 仅承接已明确的构建和授权交付，不添加本地可完成的检查流水线。
- 凭据、渲染出的 Secret、打包产物、Blender 工程、音视频及模型权重不进入 Git。发布包不可覆盖，修改安装输入递增交付版本。

## 1. 渠道 Chart 的元数据声明

新增或修改渠道 Chart 时，遵循 [渠道应用契约第 3.1.2 节](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/contracts/channel-provider-v1.md#312-渠道元数据文件)。在父工作区内优先读取 `docs/design/contracts/channel-provider-v1.md`，字段与注册行为以该契约为唯一设计依据。

- 每个渠道统一在 Chart 根目录维护 `channel.yaml`，路径为 `charts/<app-slug>/channel.yaml`，与 `Chart.yaml` 并列；例如 `charts/higgsfield/channel.yaml`、`charts/chatgpt/channel.yaml`。非渠道应用不要求此文件。
- 作为渠道提供执行能力的本地应用同样遵循此规范，各应用分别声明并注册自身，不合并为一个 `local` 渠道；媒体 MCP 沿用现有调用适配，统一发现不等于自动统一执行接口。
- `channel.yaml` 是可审阅的渠道能力声明源，包含 `channel_id` 和 `capabilities`；能力条目声明模型、固定媒体类型、操作和参数定义。登记摘要 `types` 从能力条目去重生成，不在文件内重复维护。
- Helm 模板从该文件生成 ConfigMap，挂载供渠道应用读取；应用据此发布登记摘要与能力目录，不再在注册代码中维护另一份硬编码模型清单。YAML 声明不替代实际执行适配，也不自动生成 MCP 工具。
- 密钥、账号、运行地址和健康观测不写入 `channel.yaml`；运行地址仍由部署配置提供。文件存在不代表渠道已上线或模型已经验证可执行。
- 元数据修改随 Chart 版本交付；仅替换镜像且元数据未变时沿用原声明。不能要求每次镜像替换都修改元数据或重新登记，也不给卸载增加业务步骤。

本规范依据 2026-10-17 用户明确批准的统一文件方案；规范生效不代表现有渠道已完成迁移。
