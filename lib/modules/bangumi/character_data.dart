/*
  @Author Ligg
  @Time 2025/8/5
 */

/// 角色类型枚举
enum CharacterRole {
  main(1, '主角'),
  supporting(2, '配角'),
  guest(3, '客串');

  const CharacterRole(this.value, this.label);
  final int value;
  final String label;

  static CharacterRole fromValue(int value) {
    return CharacterRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => CharacterRole.guest,
    );
  }
}

class CharacterData {
  final List<CharacterItem> data;

  CharacterData({required this.data});

  factory CharacterData.fromJson(Map<String, dynamic> json) {
    return CharacterData(
      data: (json['data'] as List)
          .map((item) => CharacterItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}

class CharacterItem {
  final Character character;
  final List<Actor> actors;
  final int type;
  final int order;

  CharacterItem({
    required this.character,
    required this.actors,
    required this.type,
    required this.order,
  });

  factory CharacterItem.fromJson(Map<String, dynamic> json) {
    return CharacterItem(
      character: Character.fromJson(json['character']),
      actors: (json['actors'] as List)
          .map((actor) => Actor.fromJson(actor))
          .toList(),
      type: json['type'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character.toJson(),
      'actors': actors.map((actor) => actor.toJson()).toList(),
      'type': type,
      'order': order,
    };
  }
}

class Character {
  final int id;
  final String name;
  final String nameCN;
  final int role;
  final String info;
  final int comment;
  final bool lock;
  final bool nsfw;
  final CharacterImages images;

  Character({
    required this.id,
    required this.name,
    required this.nameCN,
    required this.role,
    required this.info,
    required this.comment,
    required this.lock,
    required this.nsfw,
    required this.images,
  });

  /// 获取角色类型名称
  String get roleName => CharacterRole.fromValue(role).label;

  /// 获取角色显示名称（优先使用中文名）
  String get characterDisplayName => nameCN.isNotEmpty ? nameCN : name;

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      nameCN: json['nameCN'],
      role: json['role'],
      info: json['info'],
      comment: json['comment'],
      lock: json['lock'],
      nsfw: json['nsfw'],
      images: CharacterImages.fromJson(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameCN': nameCN,
      'role': role,
      'info': info,
      'comment': comment,
      'lock': lock,
      'nsfw': nsfw,
      'images': images.toJson(),
    };
  }
}

class Actor {
  final int id;
  final String name;
  final String nameCN;
  final int type;
  final String info;
  final int comment;
  final bool lock;
  final bool nsfw;
  final CharacterImages images;

  Actor({
    required this.id,
    required this.name,
    required this.nameCN,
    required this.type,
    required this.info,
    required this.comment,
    required this.lock,
    required this.nsfw,
    required this.images,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'],
      nameCN: json['nameCN'],
      type: json['type'],
      info: json['info'],
      comment: json['comment'],
      lock: json['lock'],
      nsfw: json['nsfw'],
      images: CharacterImages.fromJson(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameCN': nameCN,
      'type': type,
      'info': info,
      'comment': comment,
      'lock': lock,
      'nsfw': nsfw,
      'images': images.toJson(),
    };
  }

  /// 获取声优显示名称（优先使用中文名）
  String get actorDisplayName => nameCN.isNotEmpty ? nameCN : name;
}

class CharacterImages {
  final String large;
  final String medium;
  final String small;
  final String grid;

  CharacterImages({
    required this.large,
    required this.medium,
    required this.small,
    required this.grid,
  });

  factory CharacterImages.fromJson(Map<String, dynamic> json) {
    return CharacterImages(
      large: json['large'],
      medium: json['medium'],
      small: json['small'],
      grid: json['grid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'large': large, 'medium': medium, 'small': small, 'grid': grid};
  }
}
