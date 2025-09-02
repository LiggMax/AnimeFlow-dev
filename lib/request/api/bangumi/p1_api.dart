/*
  @Author Ligg
  @Time 2025/8/5
 */
class BangumiP1Api {
  static const String nextBgm = 'https://next.bgm.tv';
  ///获取条目评论
  static const String bangumiComment = '$nextBgm/p1/subjects/{subject_id}/comments';

  /// 每日放送
  static const String bangumiCalendar = '$nextBgm/p1/calendar';

  ///条目角色
  static const String bangumiCharacter = '$nextBgm/p1/subjects/{subject_id}/characters';

  ///用户信息
  static const String bangumiUserInfo = '$nextBgm/p1/users/{username}';

  ///剧集评论
  static const String bangumiEpisodeComment = '$nextBgm/p1/episodes/{episode_id}/comments';

  ///用户收藏
  static const String bangumiUserCollection = '$nextBgm/p1/users/{username}/collections/subjects';

  ///排行榜
  static const String bangumiRank = '$nextBgm/p1/subjects';
}
