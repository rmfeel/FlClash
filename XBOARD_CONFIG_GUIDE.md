# Xboard 统一配置功能实现说明

## 📋 更新概述

本次更新实现了 **Xboard 后端地址和 Token 的统一配置管理**，解决了之前需要在多处手动配置的问题。现在只需配置一次，所有功能都会自动使用统一的配置。

## ✨ 新增功能

### 1. 统一配置管理系统

#### 配置数据模型
**文件**: `lib/models/xboard_config.dart`

```dart
class XboardConfig {
  String baseUrl;           // 后端地址
  String? authToken;        // 认证Token
  bool isLoggedIn;          // 登录状态
  String? userEmail;        // 用户邮箱
}
```

#### 配置状态管理
**文件**: `lib/providers/xboard_config.dart`

提供了完整的配置管理功能：
- ✅ 自动加载和保存配置到本地存储
- ✅ 统一的 API 服务实例管理
- ✅ Token 自动设置和清除
- ✅ 登录状态管理

**Provider**:
- `xboardConfigProvider` - 配置状态管理
- `xboardApiProvider` - 自动配置的 API 服务实例

#### 配置界面
**文件**: `lib/views/xboard_settings.dart`

提供了用户友好的配置界面：
- ✅ 后端地址配置和编辑
- ✅ 账户信息显示
- ✅ 登录/登出功能
- ✅ 使用说明

### 2. 自动化配置集成

所有使用 Xboard API 的地方都已更新为使用统一配置：

#### 认证页面
**文件**: `lib/views/auth/login_page.dart`
- ✅ 登录功能使用统一配置
- ✅ 注册功能使用统一配置
- ✅ 忘记密码功能使用统一配置
- ✅ 登录成功后自动保存 Token

#### 订阅信息卡片
**文件**: `lib/views/dashboard/widgets/subscription_card.dart`
- ✅ 自动使用配置的 API 服务
- ✅ 自动使用保存的 Token
- ✅ 未配置时显示友好提示

## 📁 新增/修改文件

### 新增文件
1. ✅ `lib/models/xboard_config.dart` - 配置数据模型
2. ✅ `lib/providers/xboard_config.dart` - 配置状态管理
3. ✅ `lib/views/xboard_settings.dart` - 配置界面

### 修改文件
1. ✅ `lib/models/models.dart` - 导出新模型
2. ✅ `lib/views/auth/login_page.dart` - 使用统一配置
3. ✅ `lib/views/dashboard/widgets/subscription_card.dart` - 使用统一配置
4. ✅ `XBOARD_INTEGRATION_README.md` - 更新文档

## 🎯 使用方式

### 1. 配置后端地址

#### 方式一：通过设置页面（推荐）
```dart
import 'package:fl_clash/views/xboard_settings.dart';

// 打开设置页面
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const XboardSettingsView(),
  ),
);
```

在设置页面中：
1. 点击"后端地址"的编辑按钮
2. 输入后端地址（如：`http://127.0.0.1:8000`）
3. 点击"保存"
4. 配置自动保存到本地

#### 方式二：通过代码（不推荐）
```dart
// 设置后端地址
await ref.read(xboardConfigProvider.notifier).setBaseUrl('http://your-domain.com');
```

### 2. 使用 API 服务

所有地方都使用统一的 Provider：

```dart
// 在任何需要使用 API 的地方
final apiService = ref.read(xboardApiProvider);

if (apiService != null) {
  // API 服务已配置且可用
  final result = await apiService.login(email: email, password: password);
} else {
  // 提示用户先配置后端地址
  showSnackBar('请先配置后端地址');
}
```

### 3. 管理登录状态

```dart
// 登录成功后保存 Token
await ref.read(xboardConfigProvider.notifier).setAuthToken(
  token,
  userEmail: email,
);

// 登出
await ref.read(xboardConfigProvider.notifier).logout();

// 检查登录状态
final config = ref.watch(xboardConfigProvider);
if (config.isLoggedIn) {
  // 已登录
}
```

## 🔄 工作流程

```
1. 用户打开应用
   ↓
2. 自动从本地加载配置
   ↓
3. 如果有配置，自动初始化 API 服务
   ↓
4. 所有功能使用统一的 API 服务
   ↓
5. 配置更改时自动保存到本地
```

## ⚙️ 配置持久化

配置使用 `SharedPreferences` 持久化存储：
- ✅ 应用启动时自动加载
- ✅ 配置更改时自动保存
- ✅ JSON 格式存储
- ✅ 加密存储 Token（建议）

存储键名：`xboard_config`

## 🎨 用户体验改进

### 配置前
- ❌ 需要在多个文件中修改后端地址
- ❌ 代码硬编码，不便于使用
- ❌ Token 管理混乱
- ❌ 用户无法自行配置

### 配置后
- ✅ 只需配置一次
- ✅ 图形界面配置，简单易用
- ✅ Token 自动管理
- ✅ 配置持久化，重启不丢失
- ✅ 所有功能自动共享配置

## 🔐 安全性

1. **Token 存储**: 使用 SharedPreferences 存储，建议后续添加加密
2. **配置验证**: URL 格式验证，必须以 `http://` 或 `https://` 开头
3. **错误处理**: 完善的错误提示和处理

## 📊 配置状态展示

配置页面会显示：
- 📍 当前后端地址（可编辑）
- 👤 登录状态和用户信息
- 📖 使用说明
- 🔑 登录/登出按钮

## 🚀 后续优化建议

1. **Token 加密**: 添加 Token 加密存储
2. **多后端支持**: 支持配置和切换多个后端
3. **配置导入导出**: 支持配置的备份和恢复
4. **健康检查**: 自动检测后端连接状态
5. **设置入口**: 在主设置页面添加 Xboard 设置入口

## 📝 开发者注意事项

### 添加新功能时

如果需要使用 Xboard API，直接使用 Provider：

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiService = ref.watch(xboardApiProvider);
    
    // 使用 apiService...
  }
}
```

### 不要做的事

❌ 不要再手动创建 `XboardApiService` 实例  
❌ 不要在代码中硬编码后端地址  
❌ 不要手动管理 Token  

### 应该做的事

✅ 使用 `xboardApiProvider` 获取 API 服务  
✅ 使用 `xboardConfigProvider` 管理配置  
✅ 在 API 调用前检查 `apiService` 是否为 null  

## 📚 相关文档

- [完整功能说明](./XBOARD_INTEGRATION_README.md)
- [API 文档](./lib/services/xboard_api_service.dart)
- [配置模型](./lib/models/xboard_config.dart)
- [配置管理](./lib/providers/xboard_config.dart)

---

**版本**: 1.1.0  
**更新日期**: 2025-12-12  
**作者**: Qoder AI Assistant
