#!/bin/bash
set -euo pipefail
# 源码固定为官方 4.10.0；输出放到仓库 .build 中，团队安装无需执行此脚本。
if [[ $# -ne 1 ]]; then
  echo "用法：bash scripts/build.sh /绝对路径/opencv-4.10.0" >&2
  exit 2
fi
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
source_dir="$(cd "$1" && pwd)"
python3 "$source_dir/platforms/apple/build_xcframework.py" \
  --out "$repo_dir/.build" \
  --framework_name opencv2 \
  --iphoneos_archs arm64 \
  --iphonesimulator_archs arm64 \
  --build_only_specified_archs \
  --iphoneos_deployment_target 15.0 \
  --disable-bitcode \
  --without objc
python3 "$repo_dir/scripts/verify.py" "$repo_dir/.build/opencv2.xcframework"
# 验证通过后才替换对外分发产物。
python3 - "$repo_dir" <<'COPY'
import pathlib, shutil, sys
root = pathlib.Path(sys.argv[1])
destination = root / 'opencv2.xcframework'
if destination.exists():
    shutil.rmtree(destination)
shutil.copytree(root / '.build/opencv2.xcframework', destination, symlinks=True)
COPY
