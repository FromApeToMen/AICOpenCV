# AICOpenCV

基于官方 OpenCV 4.10.0 构建的静态 `opencv2.xcframework`，供团队通过 CocoaPods 获取统一产物。

- 最低部署系统：iOS 15.0。
- 真机：arm64；Apple Silicon 模拟器：独立 arm64 切片。
- 保留 OpenCV C++ API 与 `opencv2` 头文件路径，不含自动生成的 ObjC / Swift 包装层。
- 使用 Apache-2.0 许可证，完整上游许可证见 LICENSE，第三方许可证见 third-party-licenses。

## 安装

```ruby
pod 'AICOpenCV', :git => 'https://github.com/FromApeToMen/AICOpenCV.git', :tag => '4.10.0.1'
```

建议团队在 Podfile 中用实际发布 commit 的完整 SHA 固定版本，同时纳入 Podfile.lock。安装者无需在本机编译 OpenCV。旧 OpenCV Pod 必须移除，避免重复链接同名框架。

## 重新构建

准备 Python 3、CMake 3.31.6 与 Xcode 27.0。下载并解压官方源码，校验压缩包：

- 地址：https://github.com/opencv/opencv/archive/refs/tags/4.10.0.tar.gz
- SHA-256：`b2171af5be6b26f7a06b1229948bbb2bdaa74fcf5cd097e0af6378fce50a6eb9`

```sh
bash scripts/build.sh /绝对路径/opencv-4.10.0
```

构建脚本会先验证平台、最低系统和已知崩溃符号，再更新仓库根目录的 XCFramework。源码与中间产物不纳入分发仓库。重新发布必须使用新的版本/commit，不覆盖已有版本。

## 验证范围

`scripts/verify.py` 检查两种平台的 arm64 切片、真实最低系统不高于 15.0，以及 `_objc_claimAutoreleasedReturnValue` 不存在强引用。

此静态检查不能替代 iOS 15 真机或最终应用的运行验证。团队应验证最低系统上的 Release 冷启动，以及 Xcode 27 模拟器中的实际图像处理调用。
