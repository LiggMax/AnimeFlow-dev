///@Author Ligg
///@Time 2025/8/19
///简介页面
library;

import 'package:AnimeFlow/pages/player/detail/introduction/video_resources.dart';
import 'package:flutter/material.dart';
import 'episode.dart';

class Introduction extends StatefulWidget {
  final String? animeName;
  final int? animeId;
  final Function(String)? onVideoUrlReceived; // 添加视频URL回调

  const Introduction({
    super.key,
    this.animeName,
    this.animeId,
    this.onVideoUrlReceived,
  });

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  bool _isBottomSheetOpen = false;

  //抽屉弹窗
  void _showBottomSheet(BuildContext context) {
    setState(() {
      _isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, //允许全屏显示
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          // 初始显示
          minChildSize: 0.4,
          // 最小
          maxChildSize: 0.95,
          // 最大
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // 拖拽手柄拖
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // 内容列表
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '番剧详情施工中...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Icon(Icons.handyman_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // 当bottom sheet关闭时，更新状态
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              flex: 9,
              child: Text(
                widget.animeName ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                _isBottomSheetOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 30,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                _showBottomSheet(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        ///剧集组件
        EpisodeItem(animeId: widget.animeId, animeName: widget.animeName),

        ///视频资源组件
        Resources(
          animeName: widget.animeName,
          episodeNumber: 1,
          onVideoUrlReceived: widget.onVideoUrlReceived,
        ),
      ],
    );
  }
}
