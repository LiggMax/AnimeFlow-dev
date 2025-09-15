/*
  @Author Ligg
  @Time 2025/8/7
 */
class BangumiOAuthApi {
  ///登录授权地址
  static const String oauthUrl = 'https://bgm.tv/oauth/authorize?response_type=code&client_id=bgm42366890dd59f2baf&redirect_uri=animeflow://auth/callback';
  ///animeFlow 后端获取token接口
  static const String tokenUrl = 'http://129.204.224.233:1024/oauth/access_token';
}
