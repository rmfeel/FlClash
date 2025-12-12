import 'dart:convert';

import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/services/xboard_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _xboardConfigKey = 'xboard_config';

/// Xboard配置Provider
class XboardConfigNotifier extends StateNotifier<XboardConfig> {
  XboardConfigNotifier() : super(defaultXboardConfig) {
    _loadConfig();
  }

  XboardApiService? _apiService;

  /// 获取API服务实例
  XboardApiService? get apiService => _apiService;

  /// 加载配置
  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_xboardConfigKey);
      if (configJson != null && configJson.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(configJson);
        final config = XboardConfig.fromJson(json);
        state = config;
        _initApiService();
      }
    } catch (e) {
      // 加载失败，使用默认配置
    }
  }

  /// 保存配置
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = state.toJson();
      final configJson = jsonEncode(json);
      await prefs.setString(_xboardConfigKey, configJson);
    } catch (e) {
      // 保存失败
    }
  }

  /// 初始化API服务
  void _initApiService() {
    if (state.baseUrl.isNotEmpty) {
      _apiService = XboardApiService(baseUrl: state.baseUrl);
      if (state.authToken != null) {
        _apiService?.setToken(state.authToken);
      }
    }
  }

  /// 设置后端地址
  Future<void> setBaseUrl(String baseUrl) async {
    state = state.copyWith(baseUrl: baseUrl);
    _initApiService();
    await _saveConfig();
  }

  /// 设置认证Token
  Future<void> setAuthToken(String? token, {String? userEmail}) async {
    state = state.copyWith(
      authToken: token,
      isLoggedIn: token != null,
      userEmail: userEmail,
    );
    _apiService?.setToken(token);
    await _saveConfig();
  }

  /// 登出
  Future<void> logout() async {
    state = state.copyWith(
      authToken: null,
      isLoggedIn: false,
      userEmail: null,
    );
    _apiService?.setToken(null);
    await _saveConfig();
  }

  /// 更新配置
  Future<void> updateConfig(XboardConfig config) async {
    state = config;
    _initApiService();
    await _saveConfig();
  }
}

/// Xboard配置Provider
final xboardConfigProvider =
    StateNotifierProvider<XboardConfigNotifier, XboardConfig>((ref) {
  return XboardConfigNotifier();
});

/// 便捷的API服务Provider
final xboardApiProvider = Provider<XboardApiService?>((ref) {
  final config = ref.watch(xboardConfigProvider);
  if (config.baseUrl.isEmpty) {
    return null;
  }
  
  final apiService = XboardApiService(baseUrl: config.baseUrl);
  if (config.authToken != null) {
    apiService.setToken(config.authToken);
  }
  return apiService;
});
