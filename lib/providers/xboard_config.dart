import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/models/xboard_config.dart';

class XboardConfigNotifier extends StateNotifier<XboardConfig> {
  XboardConfigNotifier() : super(const XboardConfig()) {
    _loadConfig();
  }

  static const String _configKey = 'xboard_config';

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_configKey);
    if (configJson != null) {
      try {
        final config = XboardConfig.fromJson(json.decode(configJson));
        state = config;
      } catch (e) {
        // 解析失败，保持默认状态
      }
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
    state = state.copyWith(
      authToken: token,
      userEmail: email,
      isLoggedIn: true,
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
  }

  Future<void> updateToken(String token) async {
    state = state.copyWith(authToken: token);
    await _saveConfig();
  }
}

final xboardConfigProvider =
    StateNotifierProvider<XboardConfigNotifier, XboardConfig>((ref) {
  return XboardConfigNotifier();
});
