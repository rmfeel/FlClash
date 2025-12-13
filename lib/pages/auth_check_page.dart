import 'package:rmmy/pages/pages.dart';
import 'package:rmmy/providers/xboard_config.dart';
import 'package:rmmy/views/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 登录检查页�?- 应用启动时的第一个页�?
class AuthCheckPage extends ConsumerWidget {
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(xboardConfigProvider);

    if (config.isLoggedIn && config.authToken != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
