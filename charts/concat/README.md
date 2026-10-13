# Concat Chart 候选

> 状态：Chart `0.1.0` 仅供静态评审；不是已发布或可安装的 AppVersion。默认镜像为 `.invalid` 占位，摘要为空。

## 1. 当前依据

- [Center 候选资料与交付缺口](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/examples/concat/README.md)：App ID、CPU 资源边界、受控镜像与入口待验证项。
- [Market 总设计](https://github.com/verdantflarehub/verdantflare-design/blob/dev/docs/design/center/market/README.md)：Hub／Control 管目录与发布，Chart 仅承载版本化技术输入。

## 2. 静态检查

```bash
helm lint charts/concat
helm template review charts/concat --namespace review
```

本地渲染不证明受控镜像、许可证、Station 安装或实际功能通过。Control 当前的 GPU 静态检查会误阻断此 CPU 候选，不能为通过检查而虚构 GPU 需求。
