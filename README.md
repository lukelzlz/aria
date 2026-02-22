# Aria - 阈界人格定制版

[![GitHub Release](https://img.shields.io/github/v/release/lukelzlz/aria)](https://github.com/lukelzlz/aria/releases/latest)
[![Build Debug](https://github.com/lukelzlz/aria/actions/workflows/build-debug.yml/badge.svg)](https://github.com/lukelzlz/aria/actions/workflows/build-debug.yml)

基于 [Aria](https://github.com/poppingmoon/aria) 的定制版本，专为 [阈界人格](https://misskey.liminalselves.top) 服务器优化。

## 定制功能

- 🔒 **强制服务端** - 登录页面锁定为 `misskey.liminalselves.top`，无法切换服务器
- 💬 **私聊入口** - 底部导航栏添加私聊按钮，作为主要入口
- 📌 **私聊置顶** - `@aliya` 用户的对话始终置顶显示

## 下载

| Android | Windows | Linux | macOS | iOS |
| ------- | ------- | ----- | ----- | --- |
| [APK][Release] | [EXE][Release] | [TAR][Release] | [DMG][Release] | [IPA][Release] |

[Release]: https://github.com/lukelzlz/aria/releases/latest

## 构建

需要 Flutter 环境，参考 [.fvmrc](.fvmrc) 查看所需版本。

```bash
# 获取依赖
flutter pub get

# 构建 debug APK（无需签名）
flutter build apk --debug --split-per-abi

# 构建 release APK（需要签名配置）
flutter build apk --split-per-abi
```

## 原版信息

Aria 是一个跨平台的 Misskey 客户端，使用 Flutter 开发。

- 原版仓库: https://github.com/poppingmoon/aria
- 原作者: [@aria_app@misskey.io](https://misskey.io/@aria_app)

## License

Same as upstream Aria - see [LICENSE](LICENSE) for details.
