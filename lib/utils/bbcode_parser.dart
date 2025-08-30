/*
  @Author Ligg
  @Time 2025/8/23
 */

/// BBCode标签解析工具类
library;

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:AnimeFlow/utils/bgm_icon.dart';
import 'package:AnimeFlow/utils/image_viewer.dart';

/// 内容元素类型
enum ContentElementType { text, image, colorText, emoji }

/// 内容元素
class ContentElement {
  final ContentElementType type;
  final String content;
  final Color? color;
  final String? imageUrl;
  final int? emojiId;

  ContentElement({
    required this.type,
    required this.content,
    this.color,
    this.imageUrl,
    this.emojiId,
  });
}

class BBCodeParser {
  static final Logger _log = Logger('BBCodeParser');

  /// 解析BBCode内容为结构化元素列表
  static List<ContentElement> parseContent(String content) {
    if (content.isEmpty) return [];

    try {
      final elements = <ContentElement>[];
      String remaining = content;

      // 处理换行符
      remaining = remaining.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      while (remaining.isNotEmpty) {
        // 查找最近的标签
        final imgMatch = RegExp(
          r'\[img\]([^\[]+?)\[/img\]',
        ).firstMatch(remaining);
        final colorMatch = RegExp(
          r'\[color=([^\]]+?)\]([^\[]*?)\[/color\]',
        ).firstMatch(remaining);
        final bgmMatch = RegExp(r'\(bgm(\d+)\)').firstMatch(remaining);

        // 找到最早出现的标签
        int earliestIndex = remaining.length;
        String tagType = 'none';
        RegExpMatch? earliestMatch;

        if (imgMatch != null && imgMatch.start < earliestIndex) {
          earliestIndex = imgMatch.start;
          tagType = 'img';
          earliestMatch = imgMatch;
        }

        if (colorMatch != null && colorMatch.start < earliestIndex) {
          earliestIndex = colorMatch.start;
          tagType = 'color';
          earliestMatch = colorMatch;
        }

        if (bgmMatch != null && bgmMatch.start < earliestIndex) {
          earliestIndex = bgmMatch.start;
          tagType = 'bgm';
          earliestMatch = bgmMatch;
        }

        // 如果没有找到任何标签，处理剩余文本
        if (earliestMatch == null) {
          final cleanText = _cleanOtherTags(remaining).trim();
          if (cleanText.isNotEmpty) {
            elements.add(
              ContentElement(type: ContentElementType.text, content: cleanText),
            );
          }
          break;
        }

        // 添加标签前的文本
        if (earliestIndex > 0) {
          final beforeText = _cleanOtherTags(
            remaining.substring(0, earliestIndex),
          ).trim();
          if (beforeText.isNotEmpty) {
            elements.add(
              ContentElement(
                type: ContentElementType.text,
                content: beforeText,
              ),
            );
          }
        }

        // 处理找到的标签
        switch (tagType) {
          case 'img':
            final imageUrl = imgMatch!.group(1);
            if (imageUrl != null && imageUrl.isNotEmpty) {
              elements.add(
                ContentElement(
                  type: ContentElementType.image,
                  content: '',
                  imageUrl: imageUrl,
                ),
              );
            }
            remaining = remaining.substring(imgMatch.end);
            break;

          case 'color':
            final colorValue = colorMatch!.group(1);
            final colorText = colorMatch.group(2);
            if (colorText != null && colorText.isNotEmpty) {
              elements.add(
                ContentElement(
                  type: ContentElementType.colorText,
                  content: colorText,
                  color: _parseColor(colorValue),
                ),
              );
            }
            remaining = remaining.substring(colorMatch.end);
            break;

          case 'bgm':
            final emojiIdStr = bgmMatch!.group(1);
            if (emojiIdStr != null) {
              final emojiId = int.tryParse(emojiIdStr);
              if (emojiId != null) {
                elements.add(
                  ContentElement(
                    type: ContentElementType.emoji,
                    content: '',
                    emojiId: emojiId,
                  ),
                );
              }
            }
            remaining = remaining.substring(bgmMatch.end);
            break;

          default:
            remaining = remaining.substring(1);
        }
      }

      return elements;
    } catch (e) {
      _log.severe('BBCode解析错误: $e');
      // 发生错误时返回纯文本
      return [
        ContentElement(
          type: ContentElementType.text,
          content: _cleanOtherTags(content),
        ),
      ];
    }
  }

  /// 清理其他不支持的标签
  static String _cleanOtherTags(String text) {
    return text
        // 移除 [url] 相关标签
        .replaceAll(RegExp(r'\[url=[^\]]*?\]'), '')
        .replaceAll(RegExp(r'\[/url\]'), '')
        .replaceAll(RegExp(r'\[url\]'), '')
        // 移除 [right] 标签
        .replaceAll(RegExp(r'\[right\]'), '')
        .replaceAll(RegExp(r'\[/right\]'), '')
        // 移除 [size] 标签
        .replaceAllMapped(RegExp(r'\[size=[^\]]*?\]([^\[]*?)\[/size\]'), (
          match,
        ) {
          return match.group(1) ?? '';
        })
        // 移除 [b] [i] [u] 标签但保留内容
        .replaceAllMapped(RegExp(r'\[b\]([^\[]*?)\[/b\]'), (match) {
          return match.group(1) ?? '';
        })
        .replaceAllMapped(RegExp(r'\[i\]([^\[]*?)\[/i\]'), (match) {
          return match.group(1) ?? '';
        })
        .replaceAllMapped(RegExp(r'\[u\]([^\[]*?)\[/u\]'), (match) {
          return match.group(1) ?? '';
        })
        // 移除其他单独的闭合标签
        .replaceAll(RegExp(r'\[/[^\]]+?\]'), '')
        // 移除其他未闭合的开始标签
        .replaceAll(RegExp(r'\[[^\]]+?\]'), '')
        // 清理多余空白
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 解析颜色值
  static Color? _parseColor(String? colorValue) {
    if (colorValue == null || colorValue.isEmpty) return null;

    try {
      // 移除 # 号
      String hex = colorValue.replaceAll('#', '');

      // 如果是3位颜色值，扩展为6位
      if (hex.length == 3) {
        hex = hex.split('').map((char) => char + char).join('');
      }

      // 确保是6位十六进制
      if (hex.length == 6) {
        final int value = int.parse(hex, radix: 16);
        return Color(0xFF000000 + value);
      }
    } catch (e) {
      _log.warning('颜色解析失败: $colorValue, 错误: $e');
    }

    return null;
  }

  /// 构建内容组件列表
  static List<Widget> buildContentWidgets(
    List<ContentElement> elements,
    BuildContext context, {
    bool isReply = false,
  }) {
    final widgets = <Widget>[];

    for (final element in elements) {
      switch (element.type) {
        case ContentElementType.text:
          if (element.content.isNotEmpty) {
            widgets.add(
              _buildTextWidget(element.content, context, isReply: isReply),
            );
          }
          break;

        case ContentElementType.colorText:
          if (element.content.isNotEmpty) {
            widgets.add(
              _buildColorTextWidget(
                element.content,
                element.color,
                context,
                isReply: isReply,
              ),
            );
          }
          break;

        case ContentElementType.image:
          if (element.imageUrl?.isNotEmpty == true) {
            widgets.add(
              _buildImageWidget(element.imageUrl!, context, isReply: isReply),
            );
          }
          break;

        case ContentElementType.emoji:
          if (element.emojiId != null) {
            widgets.add(
              _buildEmojiWidget(element.emojiId!, context, isReply: isReply),
            );
          }
          break;
      }
    }

    return widgets;
  }

  /// 构建普通文本组件
  static Widget _buildTextWidget(
    String text,
    BuildContext context, {
    bool isReply = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: isReply ? 13 : 14,
          height: 1.4,
        ),
      ),
    );
  }

  /// 构建彩色文本组件
  static Widget _buildColorTextWidget(
    String text,
    Color? color,
    BuildContext context, {
    bool isReply = false,
  }) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: isReply ? 13 : 14,
        height: 1.4,
        color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }

  /// 构建BGM表情组件
  static Widget _buildEmojiWidget(
    int emojiId,
    BuildContext context, {
    bool isReply = false,
  }) {
    final iconData = BgmIconParser.parseIcon(emojiId);

    if (iconData is String) {
      // 返回网络图片
      final heroTag = 'emoji_${iconData.hashCode}_${Random().nextInt(10000)}';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: () => ImageViewer.show(context, iconData, heroTag: heroTag),
          child: Hero(
            tag: heroTag,
            child: CachedNetworkImage(
              imageUrl: iconData,
              width: isReply ? 16 : 20,
              height: isReply ? 16 : 20,
              fit: BoxFit.contain,
              placeholder: (context, url) => SizedBox(
                width: isReply ? 16 : 20,
                height: isReply ? 16 : 20,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
              errorWidget: (context, url, error) => Container(
                width: isReply ? 16 : 20,
                height: isReply ? 16 : 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.running_with_errors_sharp,
                  size: isReply ? 12 : 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 返回默认图标
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.sentiment_very_satisfied,
          size: isReply ? 16 : 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  /// 构建图片组件
  static Widget _buildImageWidget(
    String imageUrl,
    BuildContext context, {
    bool isReply = false,
  }) {
    // 为Hero动画生成唯一标签
    final heroTag = 'image_${imageUrl.hashCode}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      constraints: BoxConstraints(
        maxWidth: isReply ? 200 : 300,
        maxHeight: isReply ? 150 : 200,
      ),
      child: GestureDetector(
        onTap: () => ImageViewer.show(context, imageUrl, heroTag: heroTag),
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: isReply ? 60 : 80,
                height: isReply ? 40 : 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: isReply ? 20 : 24,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '加载失败',
                        style: TextStyle(
                          fontSize: isReply ? 8 : 10,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
