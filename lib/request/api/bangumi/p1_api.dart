/*
  @Author Ligg
  @Time 2025/8/5
 */
class BangumiP1Api {
  ///获取条目评论
  static const String bangumiComment =
      'https://next.bgm.tv/p1/subjects/{subject_id}/comments';

  /// 每日放送
  static const String bangumiCalendar = 'https://next.bgm.tv/p1/calendar';

  ///条目角色
  static const String bangumiCharacter =
      'https://next.bgm.tv/p1/subjects/{subject_id}/characters';

  ///用户信息
  static const String bangumiUserInfo =
      'https://next.bgm.tv/p1/users/{username}';

  ///剧集评论
  static const String bangumiEpisodeComment =
      'https://next.bgm.tv/p1/episodes/{episode_id}/comments';
}
