# Aria - 阈界人格定制版

[![GitHub Release](https://img.shields.io/github/v/release/lukelzlz/aria)](https://github.com/lukelzlz/aria/releases/latest)
[![Build](https://github.com/lukelzlz/aria/actions/workflows/build.yml/badge.svg)](https://github.com/lukelzlz/aria/actions/workflows/build.yml)

基于 [Aria](https://github.com/poppingmoon/aria) 的定制版本，专为 [阈界人格](https://misskey.liminalselves.top) 社区优化。

## ✨ 定制功能

### 🔐 登录体验
- **引导欢迎页** - 新用户首次打开显示 Misskey 介绍，引导登录/注册
- **内置 WebView 登录** - 无需跳转浏览器，应用内完成 MiAuth 认证
- **内置注册页面** - 直接在应用内注册新账号
- **Token 登录** - 支持通过 Access Token 登录
- **强制服务端** - 登录页面锁定为 `misskey.liminalselves.top`

### 💬 私聊优化
- **私聊 Tab** - 时间线页面直接切换私聊，无需侧边栏
- **首次登录自动创建** - 新账号自动添加私聊标签页

### 🔔 国内推送优化
> 针对国内安卓环境（无 FCM、厂商激进杀后台）的实时消息优化

- **前台服务** - 保持 WebSocket 长连接，实时接收消息（默认开启）
- **定时轮询** - WorkManager 每 15 分钟检查一次，作为保底（默认开启）
- **通知栏常驻** - 显示"Aria 运行中"状态，防止被系统杀死

## 📥 下载

| 平台 | 下载 |
| ---- | ---- |
| Android (arm64) | [APK](https://github.com/lukelzlz/aria/releases/latest) |
| Android (arm32) | [APK](https://github.com/lukelzlz/aria/releases/latest) |
| Android (x86_64) | [APK](https://github.com/lukelzlz/aria/releases/latest) |
| Windows | [EXE](https://github.com/lukelzlz/aria/releases/latest) |
| Linux (x64) | [TAR](https://github.com/lukelzlz/aria/releases/latest) |
| Linux (arm64) | [TAR](https://github.com/lukelzlz/aria/releases/latest) |

> ⚠️ iOS/macOS 版本因需要 Apple 开发者证书，暂不提供签名版本

## 🛠️ 构建

需要 Flutter 环境，参考 [.fvmrc](.fvmrc) 查看所需版本。

```bash
# 获取依赖
flutter pub get

# 生成代码（Riverpod 等）
dart run build_runner build -d

# 构建 debug APK（无需签名）
flutter build apk --debug --split-per-abi

# 构建 release APK（需要签名）
flutter build apk --split-per-abi
```

## 📝 版本历史

| 版本 | 更新内容 |
| ---- | -------- |
| v1.1.0 | 国内安卓推送优化（前台服务 + 定时轮询），默认开启 |
| v1.0.6 | 引导欢迎页 + 内置 WebView 登录/注册 |
| v1.0.4 | 私聊 Tab 功能，首次登录自动创建 |
| v1.0.0 | 初始定制版，强制服务端 |

## 🔗 相关链接

- **社区**: [阈界人格](https://misskey.liminalselves.top)
- **原版仓库**: https://github.com/poppingmoon/aria
- **原作者**: [@aria_app@misskey.io](https://misskey.io/@aria_app)

## 📄 License

Same as upstream Aria - see [LICENSE](LICENSE) for details.
