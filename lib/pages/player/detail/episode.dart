///  @Author Ligg
///  @Time 2025/7/26
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/episodes.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';

class EpisodeItem extends StatefulWidget {
  final int? animeId;
  final String? animeName;
  final VoidCallback? onTap;

  const EpisodeItem(
      {super.key, required this.animeId, this.onTap, this.animeName,});

  @override
  State<EpisodeItem> createState() => _EpisodeItemState();

}

class _EpisodeItemState extends State<EpisodeItem> {
  Episodes? episodes;
  bool _isLoading = true;

  Future<Episodes?> _getEpisodes() async {
    if (widget.animeId != null) {
      episodes = await BangumiService.getEpisodesByID(widget.animeId!);
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _getEpisodes();
  }

  //数据源卡片组件
  Widget _buildDataSourceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 数据源标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '数据源',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              // 更换按钮
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.swap_horiz, size: 20),
                label: const Text('更换'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 数据源信息
          Row(
            children: [
              // 图标
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.pink[500],
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://example.com/logo.png'), // 替换为实际图标URL
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 数据源名称
              Text(
                'girigiri愛動漫', // 这里可以动态设置
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 描述信息
          Text(
            '我们不可能成为恋人！绝对不行。（※似乎可行？） 07', // 这里可以动态设置
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Text('剧集Id${widget.animeId}, 名称${widget.animeName}'),

          /// 数据源卡片
          _buildDataSourceCard()
        ]
    );
  }
}
