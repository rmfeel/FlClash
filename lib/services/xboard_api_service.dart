import 'package:dio/dio.dart';
import 'package:fl_clash/models/models.dart';

/// Xboard API服务
class XboardApiService {
  late Dio _dio;
  String? _token;
  
  XboardApiService({required String baseUrl}) {
    _dio = Dio(BaseOptions(
      baseURL: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = _token;
        }
        return handler.next(options);
      },
    ));
  }

  /// 设置token
  void setToken(String? token) {
    _token = token;
  }

  /// 用户注册
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? emailCode,
    String? inviteCode,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/passport/auth/register',
        data: {
          'email': email,
          'password': password,
          if (emailCode != null) 'email_code': emailCode,
          if (inviteCode != null) 'invite_code': inviteCode,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 用户登录
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/passport/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 忘记密码
  Future<Map<String, dynamic>> forgetPassword({
    required String email,
    required String emailCode,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/passport/auth/forget',
        data: {
          'email': email,
          'email_code': emailCode,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 发送邮箱验证码
  Future<Map<String, dynamic>> sendEmailVerify({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/passport/comm/sendEmailVerify',
        data: {
          'email': email,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _dio.get('/api/v1/user/info');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// 获取订阅信息
  Future<XboardSubscriptionInfo> getSubscribe() async {
    try {
      final response = await _dio.get('/api/v1/user/getSubscribe');
      final data = response.data['data'];
      return XboardSubscriptionInfo.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// 下载订阅配置文件（Clash格式）
  /// subscribeUrl: 订阅链接，从 getSubscribe() 获取
  /// 返回配置文件的YAML内容
  Future<String> downloadClashConfig(String subscribeUrl) async {
    try {
      final response = await Dio().get(
        subscribeUrl,
        options: Options(
          headers: {
            'User-Agent': 'clash-verge/v1.3.8',  // 模拟Clash客户端
          },
          responseType: ResponseType.plain,
        ),
      );
      return response.data as String;
    } catch (e) {
      rethrow;
    }
  }
}

/// Xboard订阅信息模型
class XboardSubscriptionInfo {
  final int? planId;
  final String? token;
  final int? expiredAt;
  final int u;
  final int d;
  final int transferEnable;
  final String email;
  final String? uuid;
  final int? deviceLimit;
  final int? speedLimit;
  final int? nextResetAt;
  final XboardPlan? plan;
  final String? subscribeUrl;
  final String? resetDay;

  XboardSubscriptionInfo({
    this.planId,
    this.token,
    this.expiredAt,
    required this.u,
    required this.d,
    required this.transferEnable,
    required this.email,
    this.uuid,
    this.deviceLimit,
    this.speedLimit,
    this.nextResetAt,
    this.plan,
    this.subscribeUrl,
    this.resetDay,
  });

  factory XboardSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return XboardSubscriptionInfo(
      planId: json['plan_id'],
      token: json['token'],
      expiredAt: json['expired_at'],
      u: json['u'] ?? 0,
      d: json['d'] ?? 0,
      transferEnable: json['transfer_enable'] ?? 0,
      email: json['email'] ?? '',
      uuid: json['uuid'],
      deviceLimit: json['device_limit'],
      speedLimit: json['speed_limit'],
      nextResetAt: json['next_reset_at'],
      plan: json['plan'] != null ? XboardPlan.fromJson(json['plan']) : null,
      subscribeUrl: json['subscribe_url'],
      resetDay: json['reset_day'],
    );
  }

  /// 获取已使用流量
  int get usedTraffic => u + d;

  /// 获取剩余流量
  int get remainingTraffic => transferEnable - usedTraffic;
}

/// Xboard订阅计划模型
class XboardPlan {
  final int id;
  final String name;
  final int? transferEnable;
  final int? price;
  final String? content;

  XboardPlan({
    required this.id,
    required this.name,
    this.transferEnable,
    this.price,
    this.content,
  });

  factory XboardPlan.fromJson(Map<String, dynamic> json) {
    return XboardPlan(
      id: json['id'],
      name: json['name'] ?? '',
      transferEnable: json['transfer_enable'],
      price: json['month_price'] ?? json['quarter_price'] ?? json['half_year_price'] ?? json['year_price'],
      content: json['content'],
    );
  }
}
