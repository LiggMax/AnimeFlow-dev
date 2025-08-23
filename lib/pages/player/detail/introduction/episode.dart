///  @Author Ligg
///  @Time 2025/7/26
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/episodes.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:lottie/lottie.dart';

class EpisodeItem extends StatefulWidget {
  final int? animeId;
  final String? animeName;
  final Function(int)? onEpisodeIdReceived;

  const EpisodeItem({
    super.key,
    required this.animeId,
    this.animeName,
    this.onEpisodeIdReceived,
  });

  @override
  State<EpisodeItem> createState() => _EpisodeItemState();
}

class _EpisodeItemState extends State<EpisodeItem> {
  Episodes? episodes;
  bool _isLoading = true;
  Data? _selectedEpisode; // 当前选择的剧集
  int? _currentEpisodeNumber; // 当前选中的剧集索引

  /// 获取剧集
  Future<void> _getEpisodes() async {
    if (widget.animeId == null) return;
    try {
      final res = await BangumiService.getEpisodesByID(widget.animeId!);
      if (!mounted) return;
      setState(() {
        episodes = res;
        _isLoading = false;
        // 自动选择第一集
        if (res?.data?.isNotEmpty == true) {
          _selectedEpisode = res!.data!.first;
          _currentEpisodeNumber = 1;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 选择剧集
  void _selectEpisode(Data episode, int episodeNumber) {
    setState(() {
      _selectedEpisode = episode;
      _currentEpisodeNumber = episodeNumber;
      widget.onEpisodeIdReceived!(episode.id!.toInt());
    });
  }

  /// 显示剧集列表抽屉弹窗
  void _showEpisodeList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许全屏显示
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // 初始显示
          minChildSize: 0.4, // 最小
          maxChildSize: 0.95, // 最大
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // 拖拽手柄
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          '剧集列表',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '共 ${episodes?.data?.length ?? 0} 集',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 剧集列表
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : episodes?.data?.isNotEmpty == true
                        ? ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: episodes!.data!.length,
                            itemBuilder: (context, index) {
                              final episode = episodes!.data![index];
                              return _buildEpisodeItem(
                                context,
                                episode,
                                index + 1,
                              );
                            },
                          )
                        : const Center(child: Text('暂无剧集信息')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 构建单个剧集项
  Widget _buildEpisodeItem(
    BuildContext context,
    Data episode,
    int episodeNumber,
  ) {
    final isSelected = _selectedEpisode?.id == episode.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 40,
          child: Center(
            child: Text(
              '第$episodeNumber集',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          (episode.nameCn?.isNotEmpty == true)
              ? episode.nameCn!
              : (episode.name?.isNotEmpty == true)
              ? episode.name!
              : '未播出',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected
                ? Container(
                    //选中动画
                    child: Lottie.asset(
                      'assets/animations/playAnime.json',
                      height: 33,
                      width: 38,
                      //替换动画颜色
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(const [
                            '**',
                          ], value: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                    ),
                  )
                : Icon(
                    Icons.play_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),

            // 评论数
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${episode.comment}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // 处理剧集选择
          _selectEpisode(episode, episodeNumber);
          Navigator.pop(context); // 关闭弹窗
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '选择了第$episodeNumber集: ${(episode.nameCn?.isNotEmpty == true)
                    ? episode.nameCn!
                    : (episode.name?.isNotEmpty == true)
                    ? episode.name!
                    : "未知剧集"}',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getEpisodes();
  }

  Widget _buildDataSourceCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${_currentEpisodeNumber.toString().padLeft(2, '0')}-${(_selectedEpisode?.nameCn?.isNotEmpty == true)
                    ? _selectedEpisode!.nameCn!
                    : (_selectedEpisode?.name?.isNotEmpty == true)
                    ? _selectedEpisode!.name!
                    : ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),

            // 剧集列表按钮
            ElevatedButton.icon(
              onPressed: () => _showEpisodeList(context),
              icon: const Icon(Icons.list, size: 25),
              label: const Text('剧集'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 数据源卡片
        _buildDataSourceCard(),
      ],
    );
  }
}
