///@Author Ligg
///@Time 2025/8/19
///简介页面
library;

import 'package:flutter/material.dart';

import 'detail_episode.dart';

class Introduction extends StatelessWidget {
  final String? animeName;

  const Introduction({super.key, this.animeName});

  //抽屉弹窗
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, //允许全屏显示
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // 初始显示
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
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Row(
                              children: [
                                Image.network('https://lain.bgm.tv/r/400/pic/cover/l/b8/0d/513345_jv4wM.jpg'),
                              ]
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                animeName ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showBottomSheet(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // EpisodeItem(episode: null,)
      ],
    );
  }
}
