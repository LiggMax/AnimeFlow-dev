class BangumiV0Api {

  /// 从条目ID获取详细信息
  static const String bangumiInfoByID = 'https://api.bgm.tv/v0/subjects';
  /// 从条目ID获取剧集ID
  static const String bangumiEpisodeByID = 'https://api.bgm.tv/v0/episodes';
  /// 条目搜索
  static const String bangumiRankSearch = 'https://api.bgm.tv/v0/search/subjects?limit={0}&offset={1}';
  ///相关条目
  static const String bangumiRelated = 'https://api.bgm.tv/v0/subjects/{subject_id}/subjects';

}
