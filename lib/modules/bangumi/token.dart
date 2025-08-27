///@Author Ligg
///@Time 2025/8/7
library;

class BangumiToken {
  final int code;
  final String message;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int createdAt;
  final String tokenType;
  final String scope;
  final int userId;

  BangumiToken({
    required this.code,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.createdAt,
    required this.tokenType,
    required this.scope,
    required this.userId,
  });

  /// 从JSON解析Token
  factory BangumiToken.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BangumiToken(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      accessToken: data['access_token'] as String? ?? '',
      refreshToken: data['refresh_token'] as String? ?? '',
      expiresIn: data['expires_in'] as int? ?? 0,
      createdAt: data['created_at'] as int? ?? 0,
      tokenType: data['token_type'] as String? ?? '',
      scope: data['scope'] as String? ?? '',
      userId: data['user_id'] as int? ?? 0,
    );
  }
}
