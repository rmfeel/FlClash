# Xboard API 端点完整文档

## 📋 API 基础信息

**API 版本**: V1  
**基础路径**: `{baseUrl}/api/v1`  
**认证方式**: Bearer Token (存放在 Authorization header)

---

## 🔐 认证相关 API (Passport)

### 基础路径: `/api/v1/passport`

| 方法 | 端点 | 说明 | 需要认证 |
|------|------|------|---------|
| POST | `/auth/register` | 用户注册 | ❌ |
| POST | `/auth/login` | 用户登录 | ❌ |
| GET  | `/auth/token2Login` | Token登录 | ❌ |
| POST | `/auth/forget` | 忘记密码/重置密码 | ❌ |
| POST | `/auth/getQuickLoginUrl` | 获取快速登录URL | ✅ |
| POST | `/auth/loginWithMailLink` | 邮件链接登录 | ❌ |
| POST | `/comm/sendEmailVerify` | 发送邮箱验证码 | ❌ |

### API 详情

#### 1. 用户注册
```
POST /api/v1/passport/auth/register

请求参数:
{
  "email": "user@example.com",
  "password": "password123",
  "email_code": "123456",        // 可选
  "invite_code": "ABC123"        // 可选
}

响应:
{
  "data": {
    "auth_data": "Bearer token...",
    "is_admin": false
  }
}
```

#### 2. 用户登录
```
POST /api/v1/passport/auth/login

请求参数:
{
  "email": "user@example.com",
  "password": "password123"
}

响应:
{
  "data": {
    "auth_data": "Bearer token...",
    "is_admin": false
  }
}
```

#### 3. 忘记密码
```
POST /api/v1/passport/auth/forget

请求参数:
{
  "email": "user@example.com",
  "email_code": "123456",
  "password": "newpassword123"
}

响应:
{
  "data": true
}
```

#### 4. 发送邮箱验证码
```
POST /api/v1/passport/comm/sendEmailVerify

请求参数:
{
  "email": "user@example.com"
}

响应:
{
  "data": true
}
```

---

## 👤 用户相关 API (User)

### 基础路径: `/api/v1/user`
**所有接口都需要认证（Bearer Token）**

| 方法 | 端点 | 说明 |
|------|------|------|
| GET  | `/info` | 获取用户信息 |
| GET  | `/getSubscribe` | 获取订阅信息 |
| GET  | `/getStat` | 获取统计信息 |
| GET  | `/checkLogin` | 检查登录状态 |
| POST | `/changePassword` | 修改密码 |
| POST | `/update` | 更新用户设置 |
| GET  | `/resetSecurity` | 重置安全信息 |
| POST | `/transfer` | 佣金转账 |
| POST | `/getQuickLoginUrl` | 获取快速登录URL |

### API 详情

#### 1. 获取用户信息
```
GET /api/v1/user/info

Headers:
Authorization: Bearer {token}

响应:
{
  "data": {
    "email": "user@example.com",
    "transfer_enable": 107374182400,
    "last_login_at": 1234567890,
    "created_at": 1234567890,
    "banned": 0,
    "remind_expire": 1,
    "remind_traffic": 1,
    "expired_at": 1234567890,
    "balance": 0,
    "commission_balance": 0,
    "plan_id": 1,
    "discount": null,
    "commission_rate": null,
    "telegram_id": null,
    "uuid": "xxx-xxx-xxx",
    "avatar_url": "https://..."
  }
}
```

#### 2. 获取订阅信息 ⭐ 重要
```
GET /api/v1/user/getSubscribe

Headers:
Authorization: Bearer {token}

响应:
{
  "data": {
    "plan_id": 1,
    "token": "subscription_token",
    "expired_at": 1234567890,          // 到期时间戳
    "u": 1073741824,                   // 已上传流量（字节）
    "d": 2147483648,                   // 已下载流量（字节）
    "transfer_enable": 107374182400,   // 总流量（字节）
    "email": "user@example.com",
    "uuid": "xxx-xxx-xxx",
    "device_limit": 3,
    "speed_limit": 0,
    "next_reset_at": 1234567890,
    "plan": {                          // 订阅计划信息
      "id": 1,
      "name": "标准套餐",
      "transfer_enable": 107374182400,
      "month_price": 1000,
      "content": "套餐说明..."
    },
    "subscribe_url": "https://...",
    "reset_day": "每月1日"
  }
}
```

#### 3. 获取统计信息
```
GET /api/v1/user/getStat

Headers:
Authorization: Bearer {token}

响应:
{
  "data": [
    0,  // 待支付订单数
    0,  // 待处理工单数
    5   // 邀请用户数
  ]
}
```

---

## 📦 订阅计划 API

### 基础路径: `/api/v1/user/plan`

| 方法 | 端点 | 说明 |
|------|------|------|
| GET  | `/fetch` | 获取可用套餐列表 |

---

## 📋 订单 API

### 基础路径: `/api/v1/user/order`

| 方法 | 端点 | 说明 |
|------|------|------|
| GET  | `/fetch` | 获取订单列表 |
| GET  | `/detail` | 获取订单详情 |
| POST | `/save` | 创建订单 |
| POST | `/checkout` | 订单结账 |
| GET  | `/check` | 检查订单状态 |
| POST | `/cancel` | 取消订单 |
| GET  | `/getPaymentMethod` | 获取支付方式 |

---

## 💡 使用示例

### 完整登录流程

```dart
// 1. 发送验证码（如果需要）
await apiService.sendEmailVerify(email: 'user@example.com');

// 2. 注册用户
final registerResult = await apiService.register(
  email: 'user@example.com',
  password: 'password123',
  emailCode: '123456',
);

// 3. 登录
final loginResult = await apiService.login(
  email: 'user@example.com',
  password: 'password123',
);

// 4. 保存 token
final token = loginResult['data']['auth_data'];

// 5. 获取订阅信息
apiService.setToken(token);
final subscriptionInfo = await apiService.getSubscribe();
```

---

## 🔑 认证说明

### Token 格式
登录成功后返回的 `auth_data` 就是 Bearer Token，使用时需要添加到请求头：

```
Authorization: Bearer {auth_data}
```

### Token 存储
Token 应该安全存储在本地，建议使用加密存储。

---

## 📊 数据字段说明

### 流量相关
- `u`: 上传流量（字节）
- `d`: 下载流量（字节）  
- `transfer_enable`: 总流量（字节）
- 已用流量 = `u + d`
- 剩余流量 = `transfer_enable - (u + d)`

### 时间戳
所有时间戳都是 Unix 时间戳（秒），需要转换为日期：
```dart
DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
```

### 价格
价格单位为分（cent），需要除以 100 得到实际金额。

---

## ⚠️ 注意事项

1. **CORS**: 确保后端配置了正确的 CORS 允许前端访问
2. **HTTPS**: 生产环境建议使用 HTTPS
3. **错误处理**: 所有 API 都可能返回错误，需要妥善处理
4. **Token 过期**: Token 可能过期，需要重新登录
5. **频率限制**: 部分接口可能有频率限制（如发送验证码）

---

## 🔗 相关文件

- API 服务实现: `lib/services/xboard_api_service.dart`
- 配置管理: `lib/providers/xboard_config.dart`
- 数据模型: `lib/models/xboard_config.dart`
