# FlClash 对接 Xboard 后端功能实现说明

## 概述
本次更新实现了 FlClash 与 Xboard 后端的对接功能，包括用户认证（登录、注册、忘记密码）和订阅信息展示。

## 主要功能

### 1. 统一配置管理
**文件位置**: 
- `lib/models/xboard_config.dart` - 配置数据模型
- `lib/providers/xboard_config.dart` - 配置状态管理
- `lib/views/xboard_settings.dart` - 配置界面

**功能特性**:
- 全局统一的后端地址配置
- Token 自动管理和持久化存储
- 登录状态管理
- 配置自动保存到本地
- 所有功能共享同一配置，无需重复设置

**Provider**:
- `xboardConfigProvider` - 配置状态管理
- `xboardApiProvider` - 自动配置的 API 服务实例

### 2. API 服务模块
**文件位置**: `lib/services/xboard_api_service.dart`

提供了与 Xboard 后端通信的完整 API 接口：
- `login()` - 用户登录
- `register()` - 用户注册
- `forgetPassword()` - 忘记密码/重置密码
- `sendEmailVerify()` - 发送邮箱验证码
- `getUserInfo()` - 获取用户信息
- `getSubscribe()` - 获取订阅信息

**数据模型**:
- `XboardSubscriptionInfo` - 订阅信息模型
- `XboardPlan` - 订阅计划模型

### 2. 用户认证页面
**文件位置**: `lib/views/auth/login_page.dart`

包含三个完整的认证页面：

#### 登录页面 (`LoginPage`)
- 邮箱和密码输入
- 表单验证
- 密码可见性切换
- 跳转到注册和忘记密码页面

#### 注册页面 (`RegisterPage`)
- 邮箱、密码、确认密码输入
- 可选的邀请码输入
- 密码强度验证（至少8位）
- 密码一致性验证

#### 忘记密码页面 (`ForgotPasswordPage`)
- 邮箱验证码发送
- 验证码倒计时功能（60秒）
- 新密码设置
- 密码重置

### 3. 订阅信息卡片
**文件位置**: `lib/views/dashboard/widgets/subscription_card.dart`

**功能特性**:
- 显示订阅计划名称
- 显示到期时间（支持长期有效）
- 显示流量使用情况：
  - 已用流量
  - 总流量
  - 剩余流量
- 流量进度条可视化
- 剩余流量不足时红色警告（< 10%）
- 支持空状态、加载状态、错误状态展示

**卡片尺寸**: 与网络速度卡片相同（8列宽，2行高）

### 4. 仪表盘配置更新

#### 修改的文件
1. **`lib/enum/enum.dart`**
   - 在 `DashboardWidget` 枚举中添加 `subscriptionCard`
   - 导入订阅卡片模块

2. **`lib/models/config.dart`**
   - 将默认仪表盘配置中的 `networkSpeed` 替换为 `subscriptionCard`
   - 网络速度卡片被隐藏，但仍可通过编辑功能添加回来

3. **`lib/views/dashboard/widgets/widgets.dart`**
   - 导出订阅卡片模块

## 默认仪表盘布局

新的默认仪表盘卡片顺序：
1. 订阅信息卡片 (`subscriptionCard`) - 新增
2. 系统代理按钮 (`systemProxyButton`)
3. TUN 按钮 (`tunButton`)
4. 出站模式 (`outboundMode`)
5. 网络检测 (`networkDetection`)
6. 流量使用 (`trafficUsage`)
7. 内网IP (`intranetIp`)

**隐藏的卡片**:
- 网络速度 (`networkSpeed`) - 可通过右上角编辑按钮重新添加

## 用户使用说明

### 配置 Xboard 后端

#### 方式一：通过设置页面配置（推荐）
1. 打开 FlClash 应用
2. 进入 Xboard 设置页面
3. 点击“后端地址”的编辑按钮
4. 输入你的 Xboard 后端地址（例如：`http://127.0.0.1:8000` 或 `https://xboard.example.com`）
5. 点击“保存”
6. 配置会自动保存到本地，下次启动自动加载

#### 方式二：通过代码配置
不推荐，建议使用设置页面。

### 访问配置页面
```dart
import 'package:fl_clash/views/xboard_settings.dart';

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const XboardSettingsView(),
  ),
);
```

### 登录 Xboard 账户
1. 在 Xboard 设置页面点击“登录”按钮
2. 输入邮箱和密码
3. 登录成功后，Token 会自动保存
4. 所有功能（订阅信息、API 请求等）都会自动使用该 Token

### 查看订阅信息
登录后，在仪表盘页面就能看到订阅信息卡片，显示：
- 订阅计划名称
- 到期时间
- 已用流量
- 总流量
- 剩余流量

### 管理仪表盘卡片
1. 点击仪表盘页面右上角的编辑按钮（铅笔图标）
2. 进入编辑模式后：
   - 拖动卡片重新排序
   - 点击右上角的加号按钮添加隐藏的卡片
   - 网络速度卡片会出现在可添加列表中
3. 点击保存按钮（磁盘图标）保存更改

## API 端点说明

### Xboard API v1 端点
- `POST /api/v1/passport/auth/register` - 用户注册
- `POST /api/v1/passport/auth/login` - 用户登录
- `POST /api/v1/passport/auth/forget` - 忘记密码
- `POST /api/v1/passport/comm/sendEmailVerify` - 发送邮箱验证码
- `GET /api/v1/user/info` - 获取用户信息
- `GET /api/v1/user/getSubscribe` - 获取订阅信息

## 待完成工作

1. **国际化支持**
   - 添加多语言支持
   - 将硬编码的中文字符串提取到语言文件

2. **订阅信息自动刷新**
   - 实现定时刷新订阅信息
   - 在流量使用后自动更新显示

3. **错误处理优化**
   - 完善网络错误处理
   - 添加更友好的错误提示
   - 实现重试机制

4. **UI/UX 优化**
   - 在设置中添加 Xboard 设置入口
   - 优化配置页面的用户体验
   - 添加加载状态和进度提示

## 测试建议

### 单元测试
1. 测试 API 服务的各个方法
2. 测试订阅信息模型的数据解析
3. 测试表单验证逻辑

### 集成测试
1. 测试完整的登录流程
2. 测试注册流程
3. 测试忘记密码流程
4. 测试订阅信息获取和显示

### UI 测试
1. 测试仪表盘卡片拖拽排序
2. 测试卡片添加和删除
3. 测试订阅信息卡片的各种状态显示

## 注意事项

1. **安全性**: Token 应该加密存储，避免明文保存
2. **网络超时**: 已设置 10 秒超时，可根据实际情况调整
3. **错误处理**: 当前错误处理较为简单，生产环境需要更详细的错误分类和处理
4. **数据验证**: 所有用户输入都进行了基本验证，但服务器端仍需二次验证

## 版本信息
- FlClash 版本: 0.8.91
- Xboard API 版本: v1
- 更新日期: 2025-12-12
