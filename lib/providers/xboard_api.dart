import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/providers/xboard_config.dart';

class XboardApi {
  final String baseUrl;
  final Dio _dio;

  XboardApi(this.baseUrl) : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/v1/passport/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? inviteCode,
  }) async {
    final response = await _dio.post('/api/v1/passport/auth/register', data: {
      'email': email,
      'password': password,
      if (inviteCode != null) 'invite_code': inviteCode,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSubscriptionInfo(String token) async {
    final response = await _dio.get(
      '/api/v1/user/getSubscribe',
      options: Options(headers: {'Authorization': token}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/api/v1/passport/auth/forget', data: {
      'email': email,
    });
  }
}

final xboardApiProvider = Provider<XboardApi?>((ref) {
  final config = ref.watch(xboardConfigProvider);
  if (config.backendUrl == null || config.backendUrl!.isEmpty) {
    return null;
  }
  return XboardApi(config.backendUrl!);
});
