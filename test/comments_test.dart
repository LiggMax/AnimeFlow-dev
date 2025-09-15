import 'package:flutter_test/flutter_test.dart';
import 'package:anime_flow/modules/bangumi/episodes_comments.dart';
import 'dart:convert';

void main() {
  group('剧集评论数据模型测试', () {
    test('测试 EpisodesComments 解析单个评论', () {
      const sampleJson = '''
      {
        "id": 1917149,
        "mainID": 1525351,
        "creatorID": 941756,
        "relatedID": 0,
        "createdAt": 1755603591,
        "content": "这是一个测试评论",
        "state": 0,
        "replies": [],
        "user": {
          "id": 941756,
          "username": "941756",
          "nickname": "测试用户",
          "avatar": {
            "small": "https://example.com/avatar.jpg",
            "medium": "https://example.com/avatar.jpg",
            "large": "https://example.com/avatar.jpg"
          },
          "group": 10,
          "sign": "",
          "joinedAt": 1733838897
        },
        "reactions": [
          {
            "users": [
              {
                "id": 123,
                "username": "testuser",
                "nickname": "测试用户2"
              }
            ],
            "value": 140
          }
        ]
      }
      ''';

      final json = jsonDecode(sampleJson);
      final comment = EpisodesComments.fromJson(json);

      expect(comment.id, equals(1917149));
      expect(comment.content, equals('这是一个测试评论'));
      expect(comment.user?.nickname, equals('测试用户'));
      expect(
        comment.user?.avatar?.small,
        equals('https://example.com/avatar.jpg'),
      );
      expect(comment.reactions?.length, equals(1));
      expect(comment.reactions?.first.value, equals(140));
      expect(comment.replies?.length, equals(0));
    });

    test('测试 EpisodesComments 解析带回复的评论', () {
      const sampleJson = '''
      {
        "id": 1917443,
        "mainID": 1525351,
        "creatorID": 736440,
        "relatedID": 0,
        "createdAt": 1755623826,
        "content": "主评论内容",
        "state": 0,
        "replies": [
          {
            "id": 1919900,
            "mainID": 1525351,
            "creatorID": 736440,
            "relatedID": 1917443,
            "createdAt": 1755890161,
            "content": "这是一条回复",
            "state": 0,
            "user": {
              "id": 736440,
              "username": "736440",
              "nickname": "回复用户",
              "avatar": {
                "small": "https://example.com/avatar2.jpg",
                "medium": "https://example.com/avatar2.jpg",
                "large": "https://example.com/avatar2.jpg"
              },
              "group": 10,
              "sign": "",
              "joinedAt": 1666614992
            }
          }
        ],
        "user": {
          "id": 736440,
          "username": "736440",
          "nickname": "主评论用户",
          "avatar": {
            "small": "https://example.com/avatar3.jpg",
            "medium": "https://example.com/avatar3.jpg",
            "large": "https://example.com/avatar3.jpg"
          },
          "group": 10,
          "sign": "",
          "joinedAt": 1666614992
        }
      }
      ''';

      final json = jsonDecode(sampleJson);
      final comment = EpisodesComments.fromJson(json);

      expect(comment.id, equals(1917443));
      expect(comment.content, equals('主评论内容'));
      expect(comment.user?.nickname, equals('主评论用户'));
      expect(comment.replies?.length, equals(1));

      final reply = comment.replies?.first;
      expect(reply?.id, equals(1919900));
      expect(reply?.content, equals('这是一条回复'));
      expect(reply?.user?.nickname, equals('回复用户'));
      expect(reply?.relatedID, equals(1917443));
    });

    test('测试评论列表解析', () {
      const sampleJson = '''
      [
        {
          "id": 1,
          "mainID": 1525351,
          "creatorID": 1,
          "relatedID": 0,
          "createdAt": 1755603591,
          "content": "第一条评论",
          "state": 0,
          "replies": [],
          "user": {
            "id": 1,
            "username": "user1",
            "nickname": "用户1",
            "avatar": {
              "small": "https://example.com/1.jpg",
              "medium": "https://example.com/1.jpg",
              "large": "https://example.com/1.jpg"
            },
            "group": 10,
            "sign": "",
            "joinedAt": 1733838897
          }
        },
        {
          "id": 2,
          "mainID": 1525351,
          "creatorID": 2,
          "relatedID": 0,
          "createdAt": 1755603592,
          "content": "第二条评论",
          "state": 0,
          "replies": [],
          "user": {
            "id": 2,
            "username": "user2",
            "nickname": "用户2",
            "avatar": {
              "small": "https://example.com/2.jpg",
              "medium": "https://example.com/2.jpg",
              "large": "https://example.com/2.jpg"
            },
            "group": 10,
            "sign": "",
            "joinedAt": 1733838898
          }
        }
      ]
      ''';

      final json = jsonDecode(sampleJson) as List;
      final comments = json
          .map((item) => EpisodesComments.fromJson(item))
          .toList();

      expect(comments.length, equals(2));
      expect(comments[0].content, equals('第一条评论'));
      expect(comments[1].content, equals('第二条评论'));
      expect(comments[0].user?.nickname, equals('用户1'));
      expect(comments[1].user?.nickname, equals('用户2'));
    });
  });
}
