#!/usr/bin/env python3
"""验证平台、架构、真实最低系统和本次崩溃符号；不替代真机运行。"""
import pathlib
import plistlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1])
info = plistlib.loads((root / 'Info.plist').read_bytes())
platforms = set()
for item in info['AvailableLibraries']:
    assert item['SupportedPlatform'] == 'ios', item
    variant = item.get('SupportedPlatformVariant', 'device')
    assert variant in ('device', 'simulator'), item
    assert 'arm64' in item['SupportedArchitectures'], item
    platforms.add(variant)
    binary = root / item['LibraryIdentifier'] / item['LibraryPath'] / 'opencv2'
    headers = subprocess.check_output(['xcrun', 'otool', '-arch', 'arm64', '-l', str(binary)], text=True)
    versions = re.findall(r'(?m)^\s*minos\s+(\d+(?:\.\d+)*)\s*$', headers)
    assert versions, '没有检出最低系统版本：' + str(binary)
    assert all(tuple(map(int, v.split('.'))) <= (15, 0, 0) for v in versions), set(versions)
    # LC_BUILD_VERSION 的平台 2 为真机，7 为模拟器；旧版命令需人工核查。
    actual_platforms = re.findall(r'(?m)^\s*platform\s+(\S+)\s*$', headers)
    expected = {'2', 'IOS'} if variant == 'device' else {'7', 'IOSSIMULATOR'}
    assert actual_platforms and set(actual_platforms) <= expected, (variant, set(actual_platforms))
    symbols = subprocess.check_output(['xcrun', 'nm', '-arch', 'arm64', '-m', str(binary)], text=True)
    forbidden = [line for line in symbols.splitlines() if '(undefined)' in line and re.search(r'\b_objc_claimAutoreleasedReturnValue\b', line) and 'weak' not in line.split()]
    assert not forbidden, forbidden[:3]
    assert binary.stat().st_size < 100 * 1024 * 1024, '单文件超过 GitHub 100 MiB 限制'
    print(f'PASS {variant}: arm64, minOS={sorted(set(versions))}, 无已知崩溃符号强引用')
assert platforms == {'device', 'simulator'}, platforms
