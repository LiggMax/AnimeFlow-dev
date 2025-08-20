///  @Author Ligg
///  @Time 2025/7/26
library;
import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/episodes.dart';

class EpisodeItem extends StatelessWidget {
  final Data? episode;
  final VoidCallback? onTap;

  const EpisodeItem({super.key, required this.episode, this.onTap});


  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          episode!.nameCn!.isNotEmpty
              ? episode!.nameCn!
              : episode!.name!.isNotEmpty
              ? episode!.name!
              : '待播出',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('第${episode!.ep}集'),
            if (episode!.airdate!.isNotEmpty) Text('播出日期: ${episode!.airdate}'),
            if (episode!.duration!.isNotEmpty) Text('时长: ${episode!.duration}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.comment, size: 25),
                const SizedBox(width: 5),
                Text('${episode!.comment}'),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class EpisodeList extends StatelessWidget {
  final Episodes episodes;
  final ScrollController? scrollController;
  final bool closeOnTap;
  final Function(Data)? onEpisodeSelected;

  const EpisodeList({
    super.key,
    required this.episodes,
    this.scrollController,
    this.closeOnTap = false,
    this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: scrollController != null
          ? null
          : const NeverScrollableScrollPhysics(),
      itemCount: episodes.data!.length,
      itemBuilder: (context, index) {
        final episode = episodes.data![index];
        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          child: EpisodeItem(
            episode: episode,
            onTap: () {
              // 调用回调函数
              onEpisodeSelected?.call(episode);
              //关闭弹窗
              if (closeOnTap) {
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }
}

class EpisodeCountRow extends StatelessWidget {
  final int episodeCount;
  final VoidCallback onRefresh;
  final Episodes episodes;
  final Function(Data)? onEpisodeSelected;

  const EpisodeCountRow({
    super.key,
    required this.episodeCount,
    required this.onRefresh,
    required this.episodes,
    this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('剧集数量: $episodeCount', style: TextStyle(fontSize: 16)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.format_align_right_rounded),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return EpisodeDrawer(
                  episodes: episodes,
                  onEpisodeSelected: onEpisodeSelected,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class EpisodeDrawer extends StatelessWidget {
  final Episodes episodes;
  final Function(Data)? onEpisodeSelected;

  const EpisodeDrawer({
    super.key,
    required this.episodes,
    this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  '剧集列表',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: EpisodeList(
                  episodes: episodes,
                  scrollController: scrollController,
                  closeOnTap: true,
                  onEpisodeSelected: onEpisodeSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
