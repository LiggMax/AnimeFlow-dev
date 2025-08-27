/*
  @Author Ligg
  @Time 2025/8/27
 */

/// 剧集源数据模型
class EpisodeSource {
  final String title;
  final String link;
  final List<EpisodeRoute> routes;
  final List<List<Episode>> episodes;

  EpisodeSource({
    required this.title,
    required this.link,
    required this.routes,
    required this.episodes,
  });

  factory EpisodeSource.fromJson(Map<String, dynamic> json) {
    return EpisodeSource(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      routes: (json['routes'] as List<dynamic>? ?? [])
          .map((route) => EpisodeRoute.fromJson(route))
          .toList(),
      episodes: (json['episodes'] as List<dynamic>? ?? [])
          .map(
            (episodeList) => (episodeList as List<dynamic>)
                .map((episode) => Episode.fromJson(episode))
                .toList(),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'routes': routes.map((route) => route.toJson()).toList(),
      'episodes': episodes
          .map(
            (episodeList) =>
                episodeList.map((episode) => episode.toJson()).toList(),
          )
          .toList(),
    };
  }

  /// 获取指定线路的剧集列表
  List<Episode> getEpisodesForRoute(int routeIndex) {
    if (routeIndex >= 0 && routeIndex < episodes.length) {
      return episodes[routeIndex];
    }
    return [];
  }

  /// 获取线路数量
  int get routeCount => routes.length;

  /// 获取总剧集数（取所有线路中剧集数最多的）
  int get totalEpisodeCount {
    return episodes.fold(
      0,
      (max, episodeList) => episodeList.length > max ? episodeList.length : max,
    );
  }

  /// 检查是否有有效数据
  bool get hasValidData =>
      title.isNotEmpty && routes.isNotEmpty && episodes.isNotEmpty;
}

/// 剧集线路模型
class EpisodeRoute {
  final String name;
  final String original;

  EpisodeRoute({required this.name, required this.original});

  factory EpisodeRoute.fromJson(Map<String, dynamic> json) {
    return EpisodeRoute(
      name: json['name'] ?? '',
      original: json['original'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'original': original};
  }

  /// 获取显示名称（优先使用name，fallback到original）
  String get displayName => name.isNotEmpty ? name : original;
}

/// 剧集信息模型
class Episode {
  final String title;
  final String url;
  final String number;

  Episode({required this.title, required this.url, required this.number});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      number: json['number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'url': url, 'number': number};
  }

  /// 获取显示标题（优先使用number，fallback到title）
  String get displayTitle => number.isNotEmpty ? '第$number话' : title;

  /// 检查剧集是否有效
  bool get isValid => title.isNotEmpty && url.isNotEmpty;

  /// 获取剧集序号（数字形式）
  int? get episodeNumber {
    if (number.isEmpty) return null;
    return int.tryParse(number);
  }
}

/// 剧集源列表包装类
class EpisodeSourceList {
  final List<EpisodeSource> sources;

  EpisodeSourceList({required this.sources});

  factory EpisodeSourceList.fromJsonList(List<Map<String, dynamic>> jsonList) {
    return EpisodeSourceList(
      sources: jsonList.map((json) => EpisodeSource.fromJson(json)).toList(),
    );
  }

  List<Map<String, dynamic>> toJsonList() {
    return sources.map((source) => source.toJson()).toList();
  }

  /// 获取源数量
  int get sourceCount => sources.length;

  /// 获取有效源（有数据的源）
  List<EpisodeSource> get validSources =>
      sources.where((source) => source.hasValidData).toList();

  /// 检查是否有有效数据
  bool get hasValidData => validSources.isNotEmpty;

  /// 根据标题查找源
  EpisodeSource? findSourceByTitle(String title) {
    try {
      return sources.firstWhere(
        (source) => source.title.toLowerCase().contains(title.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取所有源的标题列表
  List<String> get sourceTitles =>
      sources.map((source) => source.title).toList();
}
