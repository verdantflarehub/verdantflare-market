# ComfyUI Chart 候选稿

本 Chart 参考成都历史 `comfyui-shucheng` Deployment、Service 和 PVC 的运行形态，但不接管那个实例。首版边界与版本映射见[交付决策](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/examples/comfyui/delivery-decisions.draft.md)。Chart 仅供评审与上传预检，未接入 Station 可信目录，也不能据此声称可安装或可运行。

## 结构与取舍

- 首版每个组织／Station 一个实例，只允许一名授权使用者；保留单副本 `Recreate`、8188 内部 `ClusterIP`、整卡 GPU、100Gi 持久卷及 HTTP 启动／就绪／存活探针。NetworkPolicy 默认拒绝全部入站，Station 须通过受控代理和单独策略显式放行。
- 不包含公网 Ingress、固定节点、个人命名、旧 `hostpath` 存储类、代理地址、S3 凭据或 `mc mirror --overwrite` sidecar。服务入口后续由 Studio/Station 受控代理对接。
- 默认镜像指向 `.invalid` 域且未填镜像 SHA-256 证据，故默认值故意不可部署。已构建的受控 `0.1.0` 镜像身份单独记录在 `values.image-0.1.0.yaml`：摘要 `sha256:70722ff8f815a40ce9609bca5d0bd5165b008c47e519150b0dbd4f7c417c3473`，来源为[成功的 Aliyun CI 构建](https://github.com/verdantflarehub/verdantflare-app-image/actions/runs/38022061267)。`image.digest` 是制品审核字段，不拼入 Kubernetes 镜像引用。Deployment 使用语义化标签与 `Always` 拉取策略。Chart `version=0.1.0` 对齐首个交付版本，`appVersion=0.32.0` 记录上游版本。
- PVC 默认为新建，但 `storageClassName: ""` 显式禁用隐式默认存储类；安装时须选择目标环境已核验的 StorageClass，若该类不动态供卷，还须先提供专属静态 PV，或改用经过授权的 `storage.existingClaim`。PVC 带 Helm `keep` 标注，卸载后工作数据仍保留并须由 Station 登记后续归属。
- 容器按 UID/GID 1000 非 root 运行，丢弃 capabilities，使用 RuntimeDefault seccomp；目标 PV 的权限和 GPU 设备访问仍须在 Station 实测。
- 一旦把镜像仓库改为真实地址，模板会要求已审核的 `image.digest`，以及明确的 StorageClass 或已授权的现有 PVC；缺项时 `helm template/install` 直接失败。默认 `.invalid` 占位仍可供本地 lint 和静态预检。

## 审核前必须补齐

1. `verdantflare-app-image/services/comfyui/` 已固定上游 revision 与 CUDA 12.8/PyTorch 构建定义，CI 已推送 `0.1.0` 并产出上述摘要；安装前还须从 Registry 独立读回核对标签和摘要，完成 GPL-3.0 及依赖许可证审核。旧成都私有镜像不能直接充当交付制品。首版不预装第三方节点或模型。
2. 目标 Station 的架构、CUDA/驱动与显存、GPU、CPU、内存、存储类及 PVC 容量预检；ComfyUI 工作流需要的模型、自定义节点及各自许可另行锁定。
3. Studio 受控入口与单使用者鉴权、WebSocket、NetworkPolicy 实际生效、任务／结果与 Artifact 映射；Chart 的 Service 可渲染不等于客户可访问或能执行工作流。
4. Chart 归档、摘要、签名、受控存储与 Station 安装执行协议；`helm lint` 和 `helm template` 仅证明结构与模板可解析。

本稿不创建 Namespace、Secret、Ingress 或 NodePort，不触碰成都现有 Deployment/PVC。实际包的签名及发布前审核结果待包契约定版。
