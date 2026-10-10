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
  --iphonesimulator_archs arm64,x86_64 \
  --build_only_specified_archs \
  --iphoneos_deployment_target 15.0 \
  --disable-bitcode \
  --without objc
python3 "$repo_dir/scripts/verify.py" "$repo_dir/.build/opencv2.xcframework"
# 压缩后分发，避免通用模拟器静态库超过 GitHub 单文件限制。
python3 - "$repo_dir" <<'PACK'
import pathlib, subprocess, sys
root = pathlib.Path(sys.argv[1])
archive = root / 'opencv2.xcframework.zip'
if archive.exists():
    archive.unlink()
subprocess.run(['ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', str(root / '.build/opencv2.xcframework'), str(archive)], check=True)
assert archive.stat().st_size < 100 * 1024 * 1024, '分发压缩包超过 GitHub 单文件限制'
PACK
