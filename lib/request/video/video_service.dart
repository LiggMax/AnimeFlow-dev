/*
  @Author Ligg
  @Time 2025/7/26
 */
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import '../request.dart';
import 'package:AnimeFlow/utils/analysis.dart';
import '../api/common_api.dart';
import 'package:AnimeFlow/modules/video/episode_source.dart';

class VideoService {
  static final Logger _log = Logger('VideoService');

  static const String websiteUrl = 'https://dm1.xfdm.pro';
  static const String searchUrl = 'https://dm1.xfdm.pro/search.html?wd=';
  static const int requestInterval = 1;

  ///  获取剧集源
  static Future<EpisodeSourceList?> getEpisodeSource(String keyword) async {
    try {
      _log.info('搜索关键词: $keyword');

      //搜索条目
      final response = await httpRequest.get(
        searchUrl + keyword,
        options: Options(headers: {'User-Agent': CommonApi.userAgent}),
      );

      if (response.data != null) {
        // 解析条目名称列表和条目链接列表
        final parseResult = VideoAnalysis.parseSearchResults(
          response.data.toString(),
        );

        // 搜索条目数据
        final episodeDataList = <Map<String, dynamic>>[];
        final titles = parseResult['titles'] ?? [];
        final links = parseResult['links'] ?? [];

        // 根据links数量进行循环发送请求
        for (int i = 0; i < links.length; i++) {
          final link = links[i];
          final title = i < titles.length ? titles[i] : '未知标题';

          //搜索剧集
          final linkResponse = await httpRequest.get(
            websiteUrl + link,
            options: Options(headers: {'User-Agent': CommonApi.userAgent}),
          );

          if (linkResponse.data != null) {
            // 剧集数据解析
            final episodeData = VideoAnalysis.parseEpisodeData(
              linkResponse.data.toString(),
            );

            // 添加条目信息到剧集数据中
            episodeData['title'] = title;
            episodeData['link'] = link;

            episodeDataList.add(episodeData);
          }

          // 请求间隔，避免过于频繁的请求
          if (i < links.length - 1) {
            await Future.delayed(const Duration(seconds: requestInterval));
          }
        }

        return EpisodeSourceList.fromJsonList(episodeDataList);
      }

      return null;
    } catch (e) {
      _log.severe('获取视频源失败: $e');
      return null;
    }
  }

  ///获取播放地址
  static Future<String?> getPlayUrl(String url) async {
    try {
      final response = await httpRequest.get(
        websiteUrl + url,
        options: Options(headers: {'User-Agent': CommonApi.userAgent}),
      );

      //  解析视频链接
      final videoUrl = VideoAnalysis.parsePlayUrl(response.data.toString());

      if (videoUrl != null) {
        _log.info('成功获取播放地址: $videoUrl');
        return videoUrl;
      } else {
        _log.warning('未能解析出有效的视频链接');
        return null;
      }
    } catch (e) {
      _log.severe('获取播放地址失败: $e');
    }
    return null;
  }
}
