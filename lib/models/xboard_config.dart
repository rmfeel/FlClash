class XboardConfig {
  final String? backendUrl;
  final String? authToken;
  final String? userEmail;
  final bool isLoggedIn;

  const XboardConfig({
    this.backendUrl,
    this.authToken,
    this.userEmail,
    this.isLoggedIn = false,
  });

  XboardConfig copyWith({
    String? backendUrl,
    String? authToken,
    String? userEmail,
    bool? isLoggedIn,
  }) {
    return XboardConfig(
      backendUrl: backendUrl ?? this.backendUrl,
      authToken: authToken ?? this.authToken,
      userEmail: userEmail ?? this.userEmail,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backendUrl': backendUrl,
      'authToken': authToken,
      'userEmail': userEmail,
      'isLoggedIn': isLoggedIn,
    };
  }

  factory XboardConfig.fromJson(Map<String, dynamic> json) {
    return XboardConfig(
      backendUrl: json['backendUrl'] as String?,
      authToken: json['authToken'] as String?,
      userEmail: json['userEmail'] as String?,
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
    );
  }
}
