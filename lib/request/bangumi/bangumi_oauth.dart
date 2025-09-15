/*
  @Author Ligg
  @Time 2025/8/5
 */
import 'dart:async';
import 'package:animeFlow/modules/bangumi/token.dart';
import '../api/bangumi/oauth.dart';
import '../request.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OAuthCallbackHandler {
  static StreamSubscription? _subscription;
  static StreamController<String>? _codeController;
  static const String _tokenBoxName = 'bangumi_token';
  // 持久化后通知用的广播流
  static final StreamController<BangumiToken> _tokenController =
      StreamController<BangumiToken>.broadcast();

  /// 对外暴露的 Token 事件流（授权并持久化成功后触发）
  static Stream<BangumiToken> get tokenStream => _tokenController.stream;

  /// 处理OAuth回调URL
  static Future<String?> handleCallback(String url) async {
    try {
      print('处理OAuth回调URL: $url');

      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('成功获取到授权码: $code');
        return code;
      } else {
        print('URL中没有找到code参数');
      }
    } catch (e) {
      print('处理OAuth回调时出错: $e');
    }
    return null;
  }

  /// 获取Token
  static Future<BangumiToken?> getToken(String code) async {
    try {
      final response = await httpRequest.get(
        BangumiOAuthApi.tokenUrl,
        queryParameters: {'code': code},
      );
      BangumiToken bangumiToken = BangumiToken.fromJson(response.data);
      if (bangumiToken.code == 200) {
        return bangumiToken;
      }
      return null;
    } catch (e) {
      print('获取Token请求失败: $e');
      return null;
    }
  }

  /// 持久化Token到Hive
  static Future<void> persistToken(BangumiToken token) async {
    try {
      final box = await Hive.openBox(_tokenBoxName);
      await box.put('token', {
        'accessToken': token.accessToken,
        'refreshToken': token.refreshToken,
        'expiresIn': token.expiresIn,
        'createdAt': token.createdAt,
        'tokenType': token.tokenType,
        'userId': token.userId,
        'scope': token.scope,
      });
      print('Token已持久化到Hive: ${token.accessToken}');
      // 新增：广播通知
      _tokenController.add(token);
    } catch (e) {
      print('持久化Token失败: $e');
    }
  }

  /// 从Hive获取Token
  static Future<BangumiToken?> getPersistedToken() async {
    try {
      final box = await Hive.openBox(_tokenBoxName);
      final tokenData = box.get('token');
      if (tokenData != null) {
        // 安全地转换Map类型
        final Map<String, dynamic> tokenMap = Map<String, dynamic>.from(
          tokenData,
        );
        return BangumiToken(
          code: tokenMap['code'] as int? ?? 0,
          message: tokenMap['message'] as String? ?? '',
          accessToken: tokenMap['accessToken'] as String? ?? '',
          refreshToken: tokenMap['refreshToken'] as String? ?? '',
          expiresIn: tokenMap['expiresIn'] as int? ?? 0,
          createdAt: tokenMap['createdAt'] as int? ?? 0,
          tokenType: tokenMap['tokenType'] as String? ?? '',
          scope: tokenMap['scope'] as String? ?? '',
          userId: tokenMap['userId'] as int? ?? 0,
        );
      }
    } catch (e) {
      print('获取持久化Token失败: $e');
    }
    return null;
  }

  /// 清除持久化的Token
  static Future<void> clearPersistedToken() async {
    try {
      final box = await Hive.openBox(_tokenBoxName);
      await box.delete('token');
      print('已清除持久化的Token');
    } catch (e) {
      print('清除Token失败: $e');
    }
  }

  /// 释放资源
  static void dispose() {
    _subscription?.cancel();
    _codeController?.close();
    _codeController = null;
    _tokenController.close();
  }
}
