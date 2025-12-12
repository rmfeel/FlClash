class XboardConfig {
  final String? backendUrl;
  final String? authToken;
  final String? userEmail;
  final bool isLoggedIn;
  final String siteName; // 站点名称

  const XboardConfig({
    this.backendUrl,
    this.authToken,
    this.userEmail,
    this.isLoggedIn = false,
    this.siteName = 'Xboard',
  });

  XboardConfig copyWith({
    String? backendUrl,
    String? authToken,
    String? userEmail,
    bool? isLoggedIn,
    String? siteName,
  }) {
    return XboardConfig(
      backendUrl: backendUrl ?? this.backendUrl,
      authToken: authToken ?? this.authToken,
      userEmail: userEmail ?? this.userEmail,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      siteName: siteName ?? this.siteName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backendUrl': backendUrl,
      'authToken': authToken,
      'userEmail': userEmail,
      'isLoggedIn': isLoggedIn,
      'siteName': siteName,
    };
  }

  factory XboardConfig.fromJson(Map<String, dynamic> json) {
    return XboardConfig(
      backendUrl: json['backendUrl'] as String?,
      authToken: json['authToken'] as String?,
      userEmail: json['userEmail'] as String?,
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      siteName: json['siteName'] as String? ?? 'Xboard',
    );
  }
}
