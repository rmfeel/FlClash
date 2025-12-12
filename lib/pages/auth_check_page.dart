import 'package:fl_clash/pages/pages.dart';
import 'package:fl_clash/providers/xboard_config.dart';
import 'package:fl_clash/views/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 登录检查页面 - 应用启动时的第一个页面
/// 检查用户是否已登录：
/// - 已登录：进入主页
/// - 未登录：显示登录页
class AuthCheckPage extends ConsumerWidget {
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(xboardConfigProvider);

    // 检查是否已登录
    if (config.isLoggedIn && config.authToken != null) {
      // 已登录，显示主页
      return const HomePage();
    } else {
      // 未登录，显示登录页
      return const LoginPage();
    }
  }
}
