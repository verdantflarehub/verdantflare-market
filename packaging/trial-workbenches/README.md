# 内部试用工作台镜像

## 1. 范围

此目录记录 Huobao Drama 与 Toonflow 内部试用镜像的固定来源。镜像经本仓库 GitHub Actions 从上游固定提交构建，推送到 VF 受控 Registry；本仓库不复制上游源码，也不把试用服务作为 Hub 可安装版本发布。阿里云现场声明和执行记录归 `verdantflare-design/deploys/` 与 `changes/`。

## 2. 固定版本

- Huobao Drama：上游 `v4.0.8`，提交 `26de7df59806588e98e103a21bd0bfd26d4a55a6`；试用镜像标签 `huobao-drama-trial-v0.1.0`。代码采用 CC BY-NC-SA 4.0，只用于用户确认的内部非商用试用；商业使用须另行取得许可。
- Toonflow：上游 `v2.0.6`，提交 `c6756b9c23e87aff1ecafad6ebf8dfbe015a74a2`；试用镜像标签 `toonflow-trial-v0.1.0`。代码采用 MIT，保留原许可声明。

两项都使用各自上游 Dockerfile。Huobao 的当前镜像使用 Node 22、SQLite 和 `/app/data`，不启用 Compose 中的 Watchtower；Toonflow 使用 Bun 1.3.14、FFmpeg 和 `/app/data`。第三方模型 API Key 不进入镜像和 Git。变更上游提交或构建输入时，递增试用镜像版本，不覆盖现有标签。

## 3. 当前依据

- [Huobao Drama 发布版本](https://github.com/chatfire-AI/huobao-drama/releases/tag/v4.0.8)：固定来源。
- [Huobao Drama 许可证](https://github.com/chatfire-AI/huobao-drama/blob/v4.0.8/LICENSE)：非商用使用边界。
- [Toonflow 发布版本](https://github.com/HBAI-Ltd/Toonflow-app/releases/tag/v2.0.6)：固定来源。
- [Toonflow 许可证](https://github.com/HBAI-Ltd/Toonflow-app/blob/v2.0.6/LICENSE)：许可保留。
