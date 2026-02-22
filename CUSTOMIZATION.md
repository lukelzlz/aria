# Aria Customization Requirements

对 Aria Misskey 客户端进行客制化修改。

## 1. 强制服务端域名

将默认服务器域名强制设为 `misskey.liminalselves.top`：
- 登录页面默认填充此域名
- 隐藏或移除"查找服务器"功能（可选）
- 用户无法切换到其他服务器

相关文件：
- `lib/view/page/login_page.dart` - 登录页面
- `lib/provider/misskey_servers_provider.dart` - 服务器列表

## 2. 底部导航添加私聊入口

在 TimelinesPage 底部添加一个独立的私聊入口按钮：
- 私聊按钮应该作为主要导航入口之一
- 点击后打开 `/accounts/chat` 路由
- 类似现有的 notifications、settings 等按钮的处理方式
- 如果有未读私聊，显示红点或角标

相关文件：
- `lib/view/page/timelines_page.dart` - 主时间线页面
- `lib/model/general_settings.dart` - 可能需要添加新的按钮类型
- `lib/constant/tab_icon_data.dart` - 图标数据

## 3. 私聊列表置顶 @aliya 用户

在私聊历史列表中，将用户名为 `aliya` 的对话始终置顶显示：
- 修改 `ChatHistoryNotifier` 的排序逻辑
- 用户 `aliya` 的私聊记录始终排在列表第一位
- 其他记录按时间倒序排列

用户完整信息：
- 用户名: `aliya`
- 服务器: `misskey.liminalselves.top`

相关文件：
- `lib/provider/api/chat_history_notifier_provider.dart` - 私聊历史数据

## 实现顺序

1. 先实现强制域名（最简单）
2. 再实现私聊置顶
3. 最后实现底部私聊入口（最复杂）

## 注意事项

- 保持代码风格一致
- 不要破坏现有功能
- 注释使用英文
