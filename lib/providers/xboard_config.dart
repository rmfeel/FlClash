import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rmmy/models/xboard_config.dart' as models;
import 'package:rmmy/state.dart';

part 'generated/xboard_config.g.dart';

// 默认后端地址 - 在这里修改你�?Xboard 后端地址
const String defaultBackendUrl = 'https://cdn.98kjc.icu';

@riverpod
class XboardConfig extends _$XboardConfig {
  static const String _configKey = 'xboard_config';

  @override
  models.XboardConfig build() {
    _loadConfig();
    return const models.XboardConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);
    if (configJson != null) {
      try {
        final config = models.XboardConfig.fromJson(json.decode(configJson));
        state = config;
      } catch (e) {
        // 解析失败，使用默认地址
        state = models.XboardConfig(backendUrl: defaultBackendUrl);
      }
    } else {
      // 首次启动，使用默认地址
      state = models.XboardConfig(backendUrl: defaultBackendUrl);
      await _saveConfig();
    }
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, json.encode(state.toJson()));
  }

  Future<void> setBackendUrl(String url) async {
    state = state.copyWith(backendUrl: url);
    await _saveConfig();
  }

  Future<void> login({
    required String token,
    required String email,
  }) async {
    // 获取站点名称
    String siteName = 'Xboard'; // 默认�?
    try {
      if (state.backendUrl != null && state.backendUrl!.isNotEmpty) {
        final dio = Dio(BaseOptions(baseUrl: state.backendUrl!));
        final response = await dio.get('/api/v1/client/app/config');
        final data = response.data as Map<String, dynamic>;
        siteName = data['data']?['site']?['app_name'] as String? ?? 'Xboard';
      }
    } catch (e) {
      print('获取站点名称失败: $e');
    }
    
    state = state.copyWith(
      authToken: token,
      userEmail: email,
      isLoggedIn: true,
      siteName: siteName,
    );
    await _saveConfig();
  }

  Future<void> logout() async {
    state = state.copyWith(
      authToken: null,
      userEmail: null,
      isLoggedIn: false,
    );
    await _saveConfig();
    
    // 退出登录时自动关闭VPN连接并清除订阅配�?
    try {
      if (globalState.isInit) {
        // 1. 关闭VPN连接
        if (globalState.isStart) {
          await globalState.appController.updateStatus(false);
        }
        
        // 2. 删除所有订阅配置文�?
        final profiles = globalState.config.profiles;
        for (final profile in profiles) {
          await globalState.appController.deleteProfile(profile.id);
        }
      }
    } catch (e) {
      // 忽略清理失败的错�?
      print('清理VPN和订阅配置失�? $e');
    }
  }

  Future<void> updateToken(String token) async {
    state = state.copyWith(authToken: token);
    await _saveConfig();
  }
}
