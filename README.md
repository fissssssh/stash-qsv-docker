# stash-qsv

基于 `stashapp/stash:v0.31.1` 官方镜像扩展的 Intel QSV 硬件转码版本。

## 为什么需要这个镜像

官方镜像只安装了 `ca-certificates vips-tools ffmpeg`（Alpine 包）。Alpine 的 ffmpeg
依赖链自带 libva（VA-API 框架）和 libvpl（oneVPL dispatcher），但缺两样东西：

| 缺失组件 | 作用 | 补装包 |
|---|---|---|
| iHD 驱动 | VA-API 实际驱动 | `onevpl-intel-gpu` 自动依赖带入 |
| oneVPL Intel GPU 运行时 | QSV MFX session 依赖 | `onevpl-intel-gpu` |

不装 `onevpl-intel-gpu` 时，ffmpeg 的 QSV 会报 `Error creating a MFX session: -9`
（dispatcher 找到、implement 缺失），stash 的 `[InitHWSupport]` 就检测不到 QSV，
MP4 转码（播放默认走的流）会回退到纯 CPU 的 libx264。

## 版本说明

- `stashapp/stash:v0.31.1`（2026-04 发布）基于 Alpine 3.23，而 `onevpl-intel-gpu`
  从 Alpine 3.24（2026-05）才开始打包，因此 Dockerfile 中通过 `--repository`
  指向 v3.24 仓库单独安装该包，不升级系统其余部分。
- 镜像版本跟随官方 stash release tag：CI 每次查询 stashapp/stash 最新 release，
  以其版本号构建并推送 `stash-qsv:<版本>` 与 `latest`。

## 硬件加速支持范围

本镜像同时启用 VAAPI 与 QSV，但 stash 对不同转码流的硬件编码器白名单不同：

| 转码流 | VAAPI | QSV |
|---|---|---|
| MP4 | ✗ | ✓ |
| HLS | ✓ | ✓ |

- **MP4 流**（播放默认走 `/stream`，`hwCodecMP4Compatible`）：硬件白名单只有
  NVENC / QSV / VideoToolbox / RKMPP，**不含 VAAPI**，只能靠 QSV。
- **HLS 流**（`/stream.m3u8`，`hwCodecHLSCompatible`）：VAAPI 与 QSV 都支持。

启动日志 `[InitHWSupport]` 应列出全部 4 个编码器：

```
Supported HW codecs [4]:
	H264 Intel Quick Sync Video (QSV) - h264_qsv
	H264 VAAPI - h264_vaapi
	VP9 Intel Quick Sync Video (QSV) - vp9_qsv
	VP9 VAAPI - vp9_vaapi
```

