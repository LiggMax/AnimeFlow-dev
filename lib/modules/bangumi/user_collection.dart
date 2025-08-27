///@Author Ligg
///@Time 2025/8/8
library;

class UserCollection {
  final List<UserCollectionItem> data;
  final int total;
  final int? limit;
  final int? offset;

  UserCollection({
    required this.data,
    required this.total,
    this.limit,
    this.offset,
  });

  factory UserCollection.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data'] as List<dynamic>? ?? [];
    return UserCollection(
      data: list
          .map((e) => UserCollectionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
    );
  }
}

class UserCollectionItem {
  final String? updatedAt;
  final String? comment;
  final List<dynamic> tags;
  final SubjectSummary subject;
  final int subjectId;
  final int volStatus;
  final int epStatus;
  final int subjectType;
  final int type; // 1/2/3/4/5
  final int rate;
  final bool private;

  UserCollectionItem({
    required this.updatedAt,
    required this.comment,
    required this.tags,
    required this.subject,
    required this.subjectId,
    required this.volStatus,
    required this.epStatus,
    required this.subjectType,
    required this.type,
    required this.rate,
    required this.private,
  });

  factory UserCollectionItem.fromJson(Map<String, dynamic> json) {
    return UserCollectionItem(
      updatedAt: json['updated_at'] as String?,
      comment: json['comment'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? const []),
      subject: SubjectSummary.fromJson(json['subject'] as Map<String, dynamic>),
      subjectId: json['subject_id'] as int? ?? json['subjectId'] as int? ?? 0,
      volStatus: json['vol_status'] as int? ?? 0,
      epStatus: json['ep_status'] as int? ?? 0,
      subjectType:
          json['subject_type'] as int? ?? json['subjectType'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      rate: json['rate'] as int? ?? 0,
      private: json['private'] as bool? ?? false,
    );
  }
}

class SubjectSummary {
  final int id;
  final String name;
  final String? nameCN;
  final String? date;
  final int type;
  final int? eps;
  final int? volumes;
  final double? score;
  final int? rank;
  final int? collectionTotal;
  final String? shortSummary;
  final SubjectImages images;

  SubjectSummary({
    required this.id,
    required this.name,
    required this.nameCN,
    required this.date,
    required this.type,
    required this.eps,
    required this.volumes,
    required this.score,
    required this.rank,
    required this.collectionTotal,
    required this.shortSummary,
    required this.images,
  });

  factory SubjectSummary.fromJson(Map<String, dynamic> json) {
    return SubjectSummary(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameCN: json['name_cn'] as String?,
      date: json['date'] as String?,
      type: json['type'] as int? ?? 0,
      eps: json['eps'] as int?,
      volumes: json['volumes'] as int?,
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : null,
      rank: json['rank'] as int?,
      collectionTotal: json['collection_total'] as int?,
      shortSummary: json['short_summary'] as String?,
      images: SubjectImages.fromJson(json['images'] as Map<String, dynamic>),
    );
  }
}

class SubjectImages {
  final String small;
  final String grid;
  final String large;
  final String medium;
  final String common;

  SubjectImages({
    required this.small,
    required this.grid,
    required this.large,
    required this.medium,
    required this.common,
  });

  factory SubjectImages.fromJson(Map<String, dynamic> json) {
    return SubjectImages(
      small: json['small'] as String? ?? '',
      grid: json['grid'] as String? ?? '',
      large: json['large'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      common: json['common'] as String? ?? '',
    );
  }
}
