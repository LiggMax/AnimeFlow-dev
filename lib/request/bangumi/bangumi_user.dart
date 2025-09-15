///@Author Ligg
///@Time 2025/8/7
library;
import 'package:animeFlow/modules/bangumi/collections.dart';
import 'package:animeFlow/modules/bangumi/user_info.dart';
import 'package:animeFlow/request/request.dart';
import 'package:dio/dio.dart';
import 'package:animeFlow/modules/bangumi/token.dart';
import '../api/bangumi/p1_api.dart';
import '../api/common_api.dart';

class BangumiUser {
  ///获取用户信息
  static Future<UserInfo?> getUserinfo(String username, {token}) async {
    final response = await httpRequest.get(
      BangumiP1Api.bangumiUserInfo.replaceAll('{username}', username),
      options: Options(headers: {'User-Agent': CommonApi.bangumiUserAgent}),
    );
    return UserInfo.fromJson(response.data);
  }

  ///获取用户收藏
  static Future<Collections?> getUserCollection(
    BangumiToken token,
    int type, {
    int subjectType = 2,
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await httpRequest.get(
      BangumiP1Api.bangumiUserCollection.replaceAll(
        '{username}',
        token.userId.toString(),
      ),
      options: Options(
        headers: {
          'User-Agent': CommonApi.bangumiUserAgent,
          'Authorization': '${token.tokenType} ${token.accessToken}',
        },
      ),
      queryParameters: {
        'subjectType': subjectType,
        'type': type,
        'limit': limit,
        'offset': offset,
      },
    );
    return Collections.fromJson(response.data);
  }
}
