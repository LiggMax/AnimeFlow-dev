import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/data.dart';
import 'detail_info.dart';

/// 标签组件
class AnimeTagsSection extends StatelessWidget {
  final List<BangumiTag> tags;

  const AnimeTagsSection({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimeInfoSection(
      title: '标签',
      children: [AnimeTagsRow(tags: tags)],
    );
  }
}

/// 标签行组件
class AnimeTagsRow extends StatefulWidget {
  final List<BangumiTag> tags;
  final int maxInitialTags; // 默认显示的标签数量

  const AnimeTagsRow({
    super.key,
    required this.tags,
    this.maxInitialTags = 6, // 默认显示6个标签
  });

  @override
  State<AnimeTagsRow> createState() => _AnimeTagsRowState();
}

class _AnimeTagsRowState extends State<AnimeTagsRow> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 判断是否需要展开功能
    final bool needsExpansion = widget.tags.length > widget.maxInitialTags;
    final List<BangumiTag> tagsToShow = needsExpansion && !isExpanded
        ? widget.tags.take(widget.maxInitialTags).toList()
        : widget.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: tagsToShow
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tag.name} (${tag.count})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // 展开/收起按钮
        if (needsExpansion) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded
                        ? '收起'
                        : '展开 (+${widget.tags.length - widget.maxInitialTags})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
