import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/xboard_config.freezed.dart';
part 'generated/xboard_config.g.dart';

/// Xboard配置
@freezed
class XboardConfig with _$XboardConfig {
  const factory XboardConfig({
    /// 后端地址 - 在这里修改您的Xboard后端地址
    @Default('https://cdn.98kjc.icu') String baseUrl,
    /// 认证Token
    String? authToken,
    /// 是否已登录
    @Default(false) bool isLoggedIn,
    /// 用户邮箱
    String? userEmail,
  }) = _XboardConfig;

  factory XboardConfig.fromJson(Map<String, Object?> json) =>
      _$XboardConfigFromJson(json);
}

/// 默认配置 - 修改上面的 baseUrl 即可
const defaultXboardConfig = XboardConfig();
