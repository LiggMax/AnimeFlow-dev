import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/data.dart';
import 'detail_related.dart';
import 'detail_summary.dart';
import 'detail_tags.dart';
import 'detail_basic_info.dart';
import 'detail_character.dart';

/// 详情内容主组件
class AnimeDetailContent extends StatefulWidget {
  final BangumiDetailData bangumiItem;
  final double maxWidth;

  const AnimeDetailContent({
    super.key,
    required this.bangumiItem,
    required this.maxWidth,
  });

  @override
  State<AnimeDetailContent> createState() => _AnimeDetailContentState();
}

class _AnimeDetailContentState extends State<AnimeDetailContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width > widget.maxWidth
              ? widget.maxWidth
              : MediaQuery.sizeOf(context).width - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 简介组件
              AnimeSummarySection(summary: widget.bangumiItem.summary),

              // 标签组件
              AnimeTagsSection(tags: widget.bangumiItem.mainTags),

              // 基本信息组件
              AnimeBasicInfoSection(bangumiItem: widget.bangumiItem),

              // 角色信息组件
              AnimeCharacter(animeId: widget.bangumiItem.id),

              // 相关条目组件
              AnimeRelatedSection(subjectId: widget.bangumiItem.id),
            ],
          ),
        ),
      ),
    );
  }
}

/// 布局容器
class AnimeInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AnimeInfoSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Column(children: children),
        ),
      ],
    );
  }
}
