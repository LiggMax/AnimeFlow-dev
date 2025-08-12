import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/related.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:go_router/go_router.dart';
import 'detail_info.dart';
import 'package:AnimeFlow/utils/fullscreen_utils.dart';

/// 相关条目展示组件
class AnimeRelatedSection extends StatefulWidget {
  final int subjectId;

  const AnimeRelatedSection({super.key, required this.subjectId});

  @override
  State<AnimeRelatedSection> createState() => _AnimeRelatedSectionState();
}

class _AnimeRelatedSectionState extends State<AnimeRelatedSection> {
  RelatedData? _relatedData;

  @override
  void initState() {
    super.initState();
    _loadRelatedData();
  }

  /// 加载相关条目数据
  Future<void> _loadRelatedData() async {
    final data = await BangumiService.getRelated(widget.subjectId);
    if (mounted) {
      setState(() {
        _relatedData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_relatedData == null || _relatedData!.data.isEmpty) {
      return const SizedBox.shrink(); // 如果没有数据，直接隐藏整个组件
    }

    return AnimeInfoSection(
      title: '相关条目',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: FullscreenUtils.getCrossAxisCount(context),
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
          ),
          itemCount: _relatedData!.data.length,
          itemBuilder: (context, index) {
            final item = _relatedData!.data[index];
            return RelatedItemCard(item: item);
          },
        ),
      ],
    );
  }
}

/// 相关条目卡片组件
class RelatedItemCard extends StatelessWidget {
  final RelatedItem item;

  const RelatedItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 导航到条目详情页面
        context.pushNamed(
          'anime_data',
          pathParameters: {'animeId': item.id.toString()},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 0.7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 封面图片
                item.images.defaultImage.isNotEmpty
                    ? Image.network(
                        item.images.defaultImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 48,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 48,
                      ),

                // 底部渐变蒙版
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                //关系标签
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white38.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.relation,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // 标题信
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题
                        Flexible(
                          child: Text(
                            item.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
