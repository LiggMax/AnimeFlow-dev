/// id : 1912362
/// mainID : 1484164
/// creatorID : 1043955
/// relatedID : 0
/// createdAt : 1755188782
/// content : "观感最好的一集"
/// state : 0
/// replies : []
/// user : {"id":1043955,"username":"1043955","nickname":"我的朋友不可能看二次元","avatar":{"small":"https://lain.bgm.tv/pic/user/s/001/04/39/1043955.jpg?r=1753280548&hd=1","medium":"https://lain.bgm.tv/pic/user/m/001/04/39/1043955.jpg?r=1753280548&hd=1","large":"https://lain.bgm.tv/pic/user/l/001/04/39/1043955.jpg?r=1753280548&hd=1"},"group":10,"sign":"按时毕业(♯｀∧´)","joinedAt":1750303495}
/// reactions : [{"users":[{"id":277833,"username":"277833","nickname":"カレン"}],"value":140}]
library;

class EpisodesComments {
  EpisodesComments({
      num? id,
      num? mainID,
      num? creatorID,
      num? relatedID,
      num? createdAt,
      String? content,
      num? state,
      List<EpisodesComments>? replies,
      User? user,
      List<Reactions>? reactions,}){
    _id = id;
    _mainID = mainID;
    _creatorID = creatorID;
    _relatedID = relatedID;
    _createdAt = createdAt;
    _content = content;
    _state = state;
    _replies = replies;
    _user = user;
    _reactions = reactions;
}

  EpisodesComments.fromJson(dynamic json) {
    _id = json['id'];
    _mainID = json['mainID'];
    _creatorID = json['creatorID'];
    _relatedID = json['relatedID'];
    _createdAt = json['createdAt'];
    _content = json['content'];
    _state = json['state'];
    if (json['replies'] != null) {
      _replies = [];
      json['replies'].forEach((v) {
        _replies?.add(EpisodesComments.fromJson(v));
      });
    }
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['reactions'] != null) {
      _reactions = [];
      json['reactions'].forEach((v) {
        _reactions?.add(Reactions.fromJson(v));
      });
    }
  }
  num? _id;
  num? _mainID;
  num? _creatorID;
  num? _relatedID;
  num? _createdAt;
  String? _content;
  num? _state;
  List<EpisodesComments>? _replies;
  User? _user;
  List<Reactions>? _reactions;
EpisodesComments copyWith({  num? id,
  num? mainID,
  num? creatorID,
  num? relatedID,
  num? createdAt,
  String? content,
  num? state,
  List<EpisodesComments>? replies,
  User? user,
  List<Reactions>? reactions,
}) => EpisodesComments(  id: id ?? _id,
  mainID: mainID ?? _mainID,
  creatorID: creatorID ?? _creatorID,
  relatedID: relatedID ?? _relatedID,
  createdAt: createdAt ?? _createdAt,
  content: content ?? _content,
  state: state ?? _state,
  replies: replies ?? _replies,
  user: user ?? _user,
  reactions: reactions ?? _reactions,
);
  num? get id => _id;
  num? get mainID => _mainID;
  num? get creatorID => _creatorID;
  num? get relatedID => _relatedID;
  num? get createdAt => _createdAt;
  String? get content => _content;
  num? get state => _state;
  List<EpisodesComments>? get replies => _replies;
  User? get user => _user;
  List<Reactions>? get reactions => _reactions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['mainID'] = _mainID;
    map['creatorID'] = _creatorID;
    map['relatedID'] = _relatedID;
    map['createdAt'] = _createdAt;
    map['content'] = _content;
    map['state'] = _state;
    if (_replies != null) {
      map['replies'] = _replies?.map((v) => v.toJson()).toList();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_reactions != null) {
      map['reactions'] = _reactions?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// users : [{"id":277833,"username":"277833","nickname":"カレン"}]
/// value : 140

class Reactions {
  Reactions({
      List<Users>? users,
      num? value,}){
    _users = users;
    _value = value;
}

  Reactions.fromJson(dynamic json) {
    if (json['users'] != null) {
      _users = [];
      json['users'].forEach((v) {
        _users?.add(Users.fromJson(v));
      });
    }
    _value = json['value'];
  }
  List<Users>? _users;
  num? _value;
Reactions copyWith({  List<Users>? users,
  num? value,
}) => Reactions(  users: users ?? _users,
  value: value ?? _value,
);
  List<Users>? get users => _users;
  num? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_users != null) {
      map['users'] = _users?.map((v) => v.toJson()).toList();
    }
    map['value'] = _value;
    return map;
  }

}

/// id : 277833
/// username : "277833"
/// nickname : "カレン"

class Users {
  Users({
      num? id,
      String? username,
      String? nickname,}){
    _id = id;
    _username = username;
    _nickname = nickname;
}

  Users.fromJson(dynamic json) {
    _id = json['id'];
    _username = json['username'];
    _nickname = json['nickname'];
  }
  num? _id;
  String? _username;
  String? _nickname;
Users copyWith({  num? id,
  String? username,
  String? nickname,
}) => Users(  id: id ?? _id,
  username: username ?? _username,
  nickname: nickname ?? _nickname,
);
  num? get id => _id;
  String? get username => _username;
  String? get nickname => _nickname;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = _username;
    map['nickname'] = _nickname;
    return map;
  }

}

/// id : 1043955
/// username : "1043955"
/// nickname : "我的朋友不可能看二次元"
/// avatar : {"small":"https://lain.bgm.tv/pic/user/s/001/04/39/1043955.jpg?r=1753280548&hd=1","medium":"https://lain.bgm.tv/pic/user/m/001/04/39/1043955.jpg?r=1753280548&hd=1","large":"https://lain.bgm.tv/pic/user/l/001/04/39/1043955.jpg?r=1753280548&hd=1"}
/// group : 10
/// sign : "按时毕业(♯｀∧´)"
/// joinedAt : 1750303495

class User {
  User({
      num? id,
      String? username,
      String? nickname,
      Avatar? avatar,
      num? group,
      String? sign,
      num? joinedAt,}){
    _id = id;
    _username = username;
    _nickname = nickname;
    _avatar = avatar;
    _group = group;
    _sign = sign;
    _joinedAt = joinedAt;
}

  User.fromJson(dynamic json) {
    _id = json['id'];
    _username = json['username'];
    _nickname = json['nickname'];
    _avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    _group = json['group'];
    _sign = json['sign'];
    _joinedAt = json['joinedAt'];
  }
  num? _id;
  String? _username;
  String? _nickname;
  Avatar? _avatar;
  num? _group;
  String? _sign;
  num? _joinedAt;
User copyWith({  num? id,
  String? username,
  String? nickname,
  Avatar? avatar,
  num? group,
  String? sign,
  num? joinedAt,
}) => User(  id: id ?? _id,
  username: username ?? _username,
  nickname: nickname ?? _nickname,
  avatar: avatar ?? _avatar,
  group: group ?? _group,
  sign: sign ?? _sign,
  joinedAt: joinedAt ?? _joinedAt,
);
  num? get id => _id;
  String? get username => _username;
  String? get nickname => _nickname;
  Avatar? get avatar => _avatar;
  num? get group => _group;
  String? get sign => _sign;
  num? get joinedAt => _joinedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = _username;
    map['nickname'] = _nickname;
    if (_avatar != null) {
      map['avatar'] = _avatar?.toJson();
    }
    map['group'] = _group;
    map['sign'] = _sign;
    map['joinedAt'] = _joinedAt;
    return map;
  }

}

/// small : "https://lain.bgm.tv/pic/user/s/001/04/39/1043955.jpg?r=1753280548&hd=1"
/// medium : "https://lain.bgm.tv/pic/user/m/001/04/39/1043955.jpg?r=1753280548&hd=1"
/// large : "https://lain.bgm.tv/pic/user/l/001/04/39/1043955.jpg?r=1753280548&hd=1"

class Avatar {
  Avatar({
      String? small,
      String? medium,
      String? large,}){
    _small = small;
    _medium = medium;
    _large = large;
}

  Avatar.fromJson(dynamic json) {
    _small = json['small'];
    _medium = json['medium'];
    _large = json['large'];
  }
  String? _small;
  String? _medium;
  String? _large;
Avatar copyWith({  String? small,
  String? medium,
  String? large,
}) => Avatar(  small: small ?? _small,
  medium: medium ?? _medium,
  large: large ?? _large,
);
  String? get small => _small;
  String? get medium => _medium;
  String? get large => _large;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['small'] = _small;
    map['medium'] = _medium;
    map['large'] = _large;
    return map;
  }

}
