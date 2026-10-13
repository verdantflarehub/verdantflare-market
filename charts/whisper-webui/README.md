# Whisper-WebUI Chart 候选

> 状态：Chart `0.1.0` 仅供静态评审；不是已发布或可安装的 AppVersion。默认镜像为 `.invalid` 占位，摘要为空。

## 1. 当前依据

- [Center 候选资料与交付缺口](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/examples/whisper-webui/README.md)：App ID、模型与许可、受控镜像及目标 Station 待验证项。
- [Market 总设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)：Hub／Control 管目录与发布，Chart 仅承载版本化技术输入。

## 2. 静态检查

```bash
helm lint charts/whisper-webui
helm template review charts/whisper-webui --namespace review
```

本地渲染不证明模型可用、许可证、Station 安装或实际转录通过。
