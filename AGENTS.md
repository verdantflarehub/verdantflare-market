# VerdantFlare Market

本仓库维护各应用的通用 Helm Chart 源码及打包配套。产品与部署设计以 [verdantflare-design 工作区规范](https://github.com/verdantflarehub/verdantflare-design/blob/dev/AGENTS.md)和 [Market 总设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)为准；在父工作区内工作时优先读取对应本地文件。

- 应用目录使用现有 Hub App ID：`charts/<app_id>/`。首个样本是 `blender-mcp`，应用源码在 `verdantflare-app-blender`。
- Hub／Control 持有管理元数据、版本索引和授权；本仓库不维护另一套可编辑市场目录，也不新增业务服务。
- 一个 Chart 只保留一份权威源码。集群专属 values、固定版本引用及部署记录归设计仓库 `deploys/`，不将某个现场实例复制为通用默认值。
- 新 Chart 必须依据真实镜像、启动方式、端口、健康检查、存储与资源契约实现。资料缺失时明确记录准备状态，不虚构可安装包或验收结果。
- MCP 对外统一经 Studio；Chart 不为下游 MCP 增加独立公网入口，内部访问按路径或端口与身份边界控制。
- 使用 `dev` 开发；`release` 仅从 `dev` 快进，`main` 保存验证后的稳定版本。发布、推送及部署按当前任务授权范围和工作区规范执行。
- 格式、Chart lint、渲染及契约检查在本地执行；建立真实 Chart 后按改动验证渲染结果与拒绝路径。CI 仅承接已明确的构建和授权交付，不添加本地可完成的检查流水线。
- 凭据、渲染出的 Secret、打包产物、Blender 工程、音视频及模型权重不进入 Git。发布包不可覆盖，修改安装输入递增交付版本。
