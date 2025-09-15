import 'package:flutter_test/flutter_test.dart';
import 'package:anime_flow/utils/bbcode_parser.dart';
import 'package:flutter/material.dart';

void main() {
  group('BBCode解析器测试', () {
    test('测试彩色文本标签解析', () {
      const testContent =
          '[color=#f7aba6]反[/color][color=#f5aba6]交[/color][color=#f3aaa5]尾[/color][color=#f1aaa5]势[/color][color=#eeaaa4]力[/color][color=#eca9a4]（[/color][color=#eaa9a3]刚[/color]';

      final elements = BBCodeParser.parseContent(testContent);

      print('解析到 ${elements.length} 个元素:');
      for (int i = 0; i < elements.length; i++) {
        final element = elements[i];
        print(
          '元素$i: 类型=${element.type}, 内容="${element.content}", 颜色=${element.color}',
        );
      }

      // 验证解析结果
      expect(elements.length, greaterThan(0));

      // 验证包含彩色文本元素
      final colorElements = elements
          .where((e) => e.type == ContentElementType.colorText)
          .toList();
      expect(colorElements.length, greaterThan(0));

      // 验证第一个彩色文本元素
      expect(colorElements.first.content, equals('反'));
      expect(colorElements.first.color, isNotNull);
    });

    test('测试混合内容解析', () {
      const testContent = '''这集一样有男主的PP(bgm35)
[img]https://p.sda1.dev/26/c29d1f9edf5460f91839d71f75a8a39c/NUKITASHI.THE.ANIMATION.S01E06.Bang.Away.1080p.UNCENSORED.OV.WEB-DL.JPN.AAC2.0.H.264.ESub-ToonsHub.mkv_001327.603.png[/img]   
丝丝子可爱捏～[img]https://lsky.ry.mk/i/2025/08/23/68a905fdde2b8.png[/img]
🐦口水流挺多''';

      final elements = BBCodeParser.parseContent(testContent);

      print('\\n混合内容解析到 ${elements.length} 个元素:');
      for (int i = 0; i < elements.length; i++) {
        final element = elements[i];
        print(
          '元素$i: 类型=${element.type}, 内容="${element.content.length > 20 ? element.content.substring(0, 20) + "..." : element.content}"',
        );
        if (element.imageUrl != null) {
          print('  图片URL: ${element.imageUrl}');
        }
      }

      // 验证包含文本和图片元素
      final textElements = elements
          .where((e) => e.type == ContentElementType.text)
          .toList();
      final imageElements = elements
          .where((e) => e.type == ContentElementType.image)
          .toList();

      expect(textElements.length, greaterThan(0));
      expect(imageElements.length, equals(2)); // 应该有两个图片
    });

    test('测试复杂标签组合', () {
      const testContent =
          '[right][url=https://bgm.tv/group/topic/406820][color=#A6A6A6][size=10]IP属地:人間[/size][/color][/url][/right]';

      final elements = BBCodeParser.parseContent(testContent);

      print('\\n复杂标签解析到 ${elements.length} 个元素:');
      for (int i = 0; i < elements.length; i++) {
        final element = elements[i];
        print('元素$i: 类型=${element.type}, 内容="${element.content}"');
      }

      // 应该提取出文本内容并移除不支持的标签
      expect(elements.length, greaterThan(0));
      final textContent = elements.map((e) => e.content).join('').trim();
      expect(textContent, contains('IP属地:人間'));
    });

    test('测试颜色值解析', () {
      // 测试不同格式的颜色值
      expect(
        BBCodeParser.parseContent('[color=#ff0000]红色[/color]').first.color,
        equals(const Color(0xFFFF0000)),
      );

      expect(
        BBCodeParser.parseContent('[color=ff0000]红色[/color]').first.color,
        equals(const Color(0xFFFF0000)),
      );

      expect(
        BBCodeParser.parseContent('[color=#f00]红色[/color]').first.color,
        equals(const Color(0xFFFF0000)),
      );
    });

    test('测试空内容和错误内容', () {
      // 测试空内容
      expect(BBCodeParser.parseContent('').length, equals(0));

      // 测试纯文本
      final plainText = BBCodeParser.parseContent('这是纯文本');
      expect(plainText.length, equals(1));
      expect(plainText.first.type, equals(ContentElementType.text));
      expect(plainText.first.content, equals('这是纯文本'));
    });
  });
}
