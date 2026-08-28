# stash 官方镜像 + Intel QSV 硬件转码运行时
#
# 官方镜像 (docker/build/x86_64/Dockerfile) 只安装 ca-certificates vips-tools ffmpeg，
# Alpine 的 ffmpeg 包依赖链自带了 libva (VA-API 框架) 和 libvpl (oneVPL dispatcher)，
# 但缺少实际驱动和 QSV 运行时:
#   - intel-media-driver   (iHD 驱动, VA-API 的实际驱动)
#   - onevpl-intel-gpu     (oneVPL Intel GPU implement, QSV 的 MFX session 依赖)
#
# onevpl-intel-gpu 会自动依赖安装 intel-media-driver，所以只需补这一个包。
#
# STASH_VERSION 默认 v0.31.1，仅用于本地构建；
# CI 通过 --build-arg STASH_VERSION=<官方最新 release tag> 覆盖，镜像版本跟随官方。

ARG STASH_VERSION=v0.31.1
FROM stashapp/stash:${STASH_VERSION}

RUN apk add --no-cache onevpl-intel-gpu

# 如需完全可复现的构建, 可固定包版本:
#   RUN apk add --no-cache onevpl-intel-gpu=25.4.6-r1
# 注意: 若官方镜像后续升级 Alpine 基础版本, 旧版本号可能不存在于新仓库, 去掉版本号即可。
