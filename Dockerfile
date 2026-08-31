# stash 官方镜像 + Intel QSV 硬件转码运行时
#
# 官方镜像 (docker/build/x86_64/Dockerfile) 只安装 ca-certificates vips-tools ffmpeg，
# Alpine 的 ffmpeg 包依赖链自带了 libva (VA-API 框架) 和 libvpl (oneVPL dispatcher)，
# 但缺少实际驱动和 QSV 运行时:
#   - intel-media-driver   (iHD 驱动, VA-API 的实际驱动)
#   - onevpl-intel-gpu     (oneVPL Intel GPU implement, QSV 的 MFX session 依赖)
#
#
# STASH_VERSION 默认 v0.31.1，仅用于本地构建；
# CI 通过 --build-arg STASH_VERSION=<官方最新 release tag> 覆盖，镜像版本跟随官方。

ARG STASH_VERSION=v0.31.1
FROM stashapp/stash:${STASH_VERSION}

# v0.31.1 (2026-04) 基于 Alpine 3.23, 而 onevpl-intel-gpu 从 Alpine 3.24 (2026-05) 才开始打包,
# 所以从 3.24 的 main/community 仓库单独安装该包及其依赖, 不升级系统其余部分。
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.24/community" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
    libva-utils intel-media-driver onevpl-intel-gpu
