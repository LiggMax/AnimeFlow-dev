/*
  @Author Ligg
  @Time 2025/7/29
 */


import 'dart:convert';

/// 搜索数据解析模块
class SearchData {
  final int total;
  final int limit;
  final int offset;
  final List<SearchAnimeItem> data;

  SearchData({
    required this.total,
    required this.limit,
    required this.offset,
    required this.data,
  });

  /// 从API响应数据解析搜索结果
  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => SearchAnimeItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  /// 从JSON字符串解析
  factory SearchData.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return SearchData.fromJson(json);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'limit': limit,
      'offset': offset,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// 搜索动漫条目模型
class SearchAnimeItem {
  final int id;
  final String name;
  final String nameCn;
  final String summary;
  final String image;
  final AnimeImages images;
  final String? date;
  final String platform;
  final int eps;
  final AnimeRating rating;
  final AnimeCollection collection;
  final List<AnimeTag> tags;
  final List<AnimeInfoBox> infobox;
  final List<String> metaTags;
  final int volumes;
  final bool series;
  final bool locked;
  final bool nsfw;
  final int type;

  SearchAnimeItem({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.summary,
    required this.image,
    required this.images,
    this.date,
    required this.platform,
    required this.eps,
    required this.rating,
    required this.collection,
    required this.tags,
    required this.infobox,
    required this.metaTags,
    required this.volumes,
    required this.series,
    required this.locked,
    required this.nsfw,
    required this.type,
  });

  /// 从JSON解析动漫条目
  factory SearchAnimeItem.fromJson(Map<String, dynamic> json) {
    return SearchAnimeItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameCn: json['name_cn'] ?? '',
      summary: json['summary'] ?? '',
      image: json['image'] ?? '',
      images: AnimeImages.fromJson(json['images'] ?? {}),
      date: json['date'],
      platform: json['platform'] ?? '',
      eps: json['eps'] ?? 0,
      rating: AnimeRating.fromJson(json['rating'] ?? {}),
      collection: AnimeCollection.fromJson(json['collection'] ?? {}),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((tag) => AnimeTag.fromJson(tag))
              .toList() ??
          [],
      infobox:
          (json['infobox'] as List<dynamic>?)
              ?.map((box) => AnimeInfoBox.fromJson(box))
              .toList() ??
          [],
      metaTags:
          (json['meta_tags'] as List<dynamic>?)
              ?.map((tag) => tag.toString())
              .toList() ??
          [],
      volumes: json['volumes'] ?? 0,
      series: json['series'] ?? false,
      locked: json['locked'] ?? false,
      nsfw: json['nsfw'] ?? false,
      type: json['type'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_cn': nameCn,
      'summary': summary,
      'image': image,
      'images': images.toJson(),
      'date': date,
      'platform': platform,
      'eps': eps,
      'rating': rating.toJson(),
      'collection': collection.toJson(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'infobox': infobox.map((box) => box.toJson()).toList(),
      'meta_tags': metaTags,
      'volumes': volumes,
      'series': series,
      'locked': locked,
      'nsfw': nsfw,
      'type': type,
    };
  }

  /// 获取显示名称（优先中文名）
  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  /// 获取封面图片URL
  String get coverImage => images.small.isNotEmpty ? images.small : image;

  /// 获取评分
  double get score => rating.score;

  /// 获取评分人数
  int get scoreCount => rating.total;

  /// 获取收藏状态统计
  Map<String, int> get collectionStats => {
    'doing': collection.doing,
    'collect': collection.collect,
    'wish': collection.wish,
    'on_hold': collection.onHold,
    'dropped': collection.dropped,
  };
}

/// 动漫图片模型
class AnimeImages {
  final String small;
  final String grid;
  final String large;
  final String medium;
  final String common;

  AnimeImages({
    required this.small,
    required this.grid,
    required this.large,
    required this.medium,
    required this.common,
  });

  factory AnimeImages.fromJson(Map<String, dynamic> json) {
    return AnimeImages(
      small: json['small'] ?? '',
      grid: json['grid'] ?? '',
      large: json['large'] ?? '',
      medium: json['medium'] ?? '',
      common: json['common'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'grid': grid,
      'large': large,
      'medium': medium,
      'common': common,
    };
  }
}

/// 动漫评分模型
class AnimeRating {
  final int rank;
  final int total;
  final double score;
  final Map<String, int> count;

  AnimeRating({
    required this.rank,
    required this.total,
    required this.score,
    required this.count,
  });

  factory AnimeRating.fromJson(Map<String, dynamic> json) {
    return AnimeRating(
      rank: json['rank'] ?? 0,
      total: json['total'] ?? 0,
      score: (json['score'] ?? 0.0).toDouble(),
      count: Map<String, int>.from(json['count'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'rank': rank, 'total': total, 'score': score, 'count': count};
  }
}

/// 动漫收藏模型
class AnimeCollection {
  final int doing;
  final int collect;
  final int wish;
  final int onHold;
  final int dropped;

  AnimeCollection({
    required this.doing,
    required this.collect,
    required this.wish,
    required this.onHold,
    required this.dropped,
  });

  factory AnimeCollection.fromJson(Map<String, dynamic> json) {
    return AnimeCollection(
      doing: json['doing'] ?? 0,
      collect: json['collect'] ?? 0,
      wish: json['wish'] ?? 0,
      onHold: json['on_hold'] ?? 0,
      dropped: json['dropped'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doing': doing,
      'collect': collect,
      'wish': wish,
      'on_hold': onHold,
      'dropped': dropped,
    };
  }
}

/// 动漫标签模型
class AnimeTag {
  final String name;
  final int count;
  final int totalCont;

  AnimeTag({required this.name, required this.count, required this.totalCont});

  factory AnimeTag.fromJson(Map<String, dynamic> json) {
    return AnimeTag(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      totalCont: json['total_cont'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'count': count, 'total_cont': totalCont};
  }
}

/// 动漫信息框模型
class AnimeInfoBox {
  final String key;
  final dynamic value;

  AnimeInfoBox({required this.key, required this.value});

  factory AnimeInfoBox.fromJson(Map<String, dynamic> json) {
    return AnimeInfoBox(key: json['key'] ?? '', value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value};
  }

  /// 获取值的字符串表示
  String get valueString {
    if (value is String) {
      return value;
    } else if (value is List) {
      return value.map((item) => item.toString()).join(', ');
    }
    return value?.toString() ?? '';
  }
}

/// 搜索数据解析工具类
class SearchDataParser {
  /// 解析搜索响应数据
  static SearchData parseSearchResponse(Map<String, dynamic> response) {
    return SearchData.fromJson(response);
  }

  /// 解析搜索响应数据（从JSON字符串）
  static SearchData parseSearchResponseFromString(String jsonString) {
    return SearchData.fromJsonString(jsonString);
  }

  /// 获取热门标签
  static List<String> getPopularTags(List<SearchAnimeItem> items) {
    final tagCount = <String, int>{};

    for (final item in items) {
      for (final tag in item.tags) {
        tagCount[tag.name] = (tagCount[tag.name] ?? 0) + tag.count;
      }
    }

    final sortedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(10).map((entry) => entry.key).toList();
  }

  /// 按评分排序
  static List<SearchAnimeItem> sortByScore(List<SearchAnimeItem> items) {
    final sorted = List<SearchAnimeItem>.from(items);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// 按日期排序
  static List<SearchAnimeItem> sortByDate(List<SearchAnimeItem> items) {
    final sorted = List<SearchAnimeItem>.from(items);
    sorted.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return sorted;
  }

  /// 按收藏数排序
  static List<SearchAnimeItem> sortByCollection(List<SearchAnimeItem> items) {
    final sorted = List<SearchAnimeItem>.from(items);
    sorted.sort((a, b) => b.collection.collect.compareTo(a.collection.collect));
    return sorted;
  }
}
