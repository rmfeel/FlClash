# 🚀 FlClash + Xboard 快速开始指南

## ⚡ 只需 3 步，开始使用！

### 1️⃣ 配置后端地址（只需改1行代码）

**文件**: `lib/models/xboard_config.dart`  
**位置**: 第 11 行

```dart
@Default('http://127.0.0.1:8000') String baseUrl,  // 改成您的地址
```

**示例**：
```dart
// 本地开发
@Default('http://127.0.0.1:8000') String baseUrl,

// 生产环境
@Default('https://xboard.yourdomain.com') String baseUrl,

// 局域网
@Default('http://192.168.1.100:8000') String baseUrl,
```

### 2️⃣ 构建应用

```bash
flutter build windows
# 或
flutter build macos
# 或
flutter build linux
```

### 3️⃣ 登录并自动导入配置

1. 打开应用
2. 导航到登录页面
3. 输入 Xboard 账号密码
4. 点击登录

**自动完成以下步骤**：
- ✅ 登录验证
- ✅ 获取订阅信息
- ✅ 下载 Clash 配置文件
- ✅ 自动导入配置到 FlClash
- ✅ 配置立即可用！

## 🎯 功能特性

### ✨ 自动配置导入（NEW！）

登录成功后，系统会自动：
1. 获取您的订阅信息
2. 下载 Clash 配置文件（YAML 格式）
3. 导入配置到 FlClash
4. 配置命名为 "Xboard 订阅"
5. 立即可以使用！

### 📊 订阅信息展示

仪表盘显示实时订阅信息：
- **订阅计划名称**
- **到期时间**
- **流量使用情况** (已用/总量)
- **剩余流量**
- **可视化进度条**

### 🔐 用户认证

完整的用户认证功能：
- 登录
- 注册
- 忘记密码

### ⚙️ 统一配置管理

- Token 自动管理
- 配置持久化存储
- 应用重启自动加载

## 📝 详细文档

- **完整功能说明**: [XBOARD_INTEGRATION_README.md](XBOARD_INTEGRATION_README.md)
- **API 参考文档**: [XBOARD_API_REFERENCE.md](XBOARD_API_REFERENCE.md)

## ⚠️ 注意事项

### 后端地址格式

✅ **正确**:
```
http://127.0.0.1:8000
https://xboard.example.com
http://192.168.1.100:8000
```

❌ **错误**:
```
127.0.0.1:8000                    (缺少协议)
http://127.0.0.1:8000/api/v1     (不要加路径)
xboard.example.com               (缺少协议)
```

### 登录要求

- 需要有效的 Xboard 账号
- 账号需要已购买订阅套餐
- 后端服务需要正常运行

## 🐛 常见问题

### 1. 配置未自动导入？

**检查**：
- 订阅是否已激活
- 订阅链接是否有效
- 网络连接是否正常
- 查看错误提示信息

### 2. 后端无法连接？

**检查**：
- 后端服务是否运行
- 端口是否正确
- 防火墙是否放行
- 地址格式是否正确

### 3. Token 过期？

**解决**：重新登录即可

## 💡 高级配置

### 自定义配置标签

修改 `lib/views/auth/login_page.dart` 第 120 行：

```dart
final profile = Profile.normal(
  url: subscribeUrl,
  label: '我的自定义标签',  // 改成您想要的名称
);
```

### 禁用自动导入

注释 `lib/views/auth/login_page.dart` 第 75-84 行：

```dart
// if (subscribeInfo.subscribeUrl != null) {
//   ...
//   await _importProfile(subscribeInfo.subscribeUrl!);
// }
```

## 🎉 就这么简单！

改1行代码 → 构建应用 → 登录使用

所有配置自动完成，立即开始使用 FlClash + Xboard！
