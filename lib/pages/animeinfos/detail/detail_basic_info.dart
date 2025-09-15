import 'package:flutter/material.dart';
import 'package:animeFlow/modules/bangumi/data.dart';
import 'detail_info.dart';

/// 基本信息组件
class AnimeBasicInfoSection extends StatelessWidget {
  final BangumiDetailData bangumiItem;

  const AnimeBasicInfoSection({
    super.key,
    required this.bangumiItem,
  });

  @override
  Widget build(BuildContext context) {
    if (bangumiItem.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimeInfoSection(
      title: '基本信息',
      children: [
        AnimeInfoRow(label: '原名', value: bangumiItem.name),
        AnimeInfoRow(
          label: '中文名',
          value: bangumiItem.nameCn,
        ),
        AnimeInfoRow(
          label: '类型',
          value: bangumiItem.typeText,
        ),
        AnimeInfoRow(
          label: '总集数',
          value: '${bangumiItem.totalEpisodes}话',
        ),
        AnimeInfoRow(label: '放送日期', value: bangumiItem.date),
        AnimeInfoRow(
          label: '播放平台',
          value: bangumiItem.platform,
        ),
      ],
    );
  }
}

/// 信息行组件
class AnimeInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const AnimeInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
