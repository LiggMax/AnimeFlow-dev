/*
  @Author Ligg
  @Time 2025/8/2
 */
import 'package:html/parser.dart' as parser;
import 'package:logging/logging.dart';

class BangumiTvAnalysis {
  static final Logger _log = Logger('BangumiTvAnalysisService');

  static const String selectNames = "ul  div > h3 > a";

  //封面
  static const String selectCovers = ".section > ul >li img";

  ///之前没找到排行榜api用的爬虫，现在用不上了先放着吧
  static Map<String, dynamic> parseRankData(String htmlData) {
    try {
      final document = parser.parse(htmlData);

      //解析条目列表
      final titleElements = document.querySelectorAll(selectNames);
      final titles = titleElements
          .map((element) => element.text.trim())
          .toList();

      //解析封面列表
      final coverElements = document.querySelectorAll(selectCovers);
      final covers = coverElements
          .map((element) {
            final src = element.attributes['src'];
            if (src == null || src.trim().isEmpty) {
              return '';
            }

            final trimmedSrc = src.trim();
            // 检查链接是否以https:开头，如果不是则拼接
            return trimmedSrc.startsWith('https:')
                ? trimmedSrc
                : 'https:$trimmedSrc';
          })
          .where((cover) => cover.isNotEmpty)
          .toList();

      //解析详情链接列表
      final linkElements = titleElements;
      final id = linkElements
          .map((element) {
            final href = element.attributes['href'];
            if (href == null) return '';

            final trimmedHref = href.trim();
            if (trimmedHref.isEmpty) return '';

            // 通过/进行字段切割获取ID
            final parts = trimmedHref.split('/');
            if (parts.length > 2) {
              // 确保获取正确的ID部分
              final idPart = parts[2];
              return idPart;
            }
            return '';
          })
          .where((link) => link.isNotEmpty)
          .toList();

      //返回解析结果
      return {'titles': titles, 'covers': covers, 'id': id};
    } catch (e) {
      _log.severe('解析动漫热度排行榜数据失败: $e');
      return {};
    }
  }
}
