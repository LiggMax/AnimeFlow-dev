///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'controls/controls.dart';

class VideoPage extends StatefulWidget {
  final String? animeName;
  final String? url;

  const VideoPage({
    super.key,
    this.animeName,
    this.url,
  });

  @override
  State<VideoPage> createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  // 创建一个[Player]来控制播放.
  late final player = Player();

  // 创建一个[videoController]来处理[player]的视频输出。
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // 播放[媒体]或[播放列表]。
    if (widget.url != null && widget.url!.isNotEmpty) {
      player.open(Media(widget.url!));
    }
  }

  @override
  void didUpdateWidget(VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当URL发生变化时，更新播放器
    if (widget.url != null &&
        widget.url != oldWidget.url &&
        widget.url!.isNotEmpty) {
      player.open(Media(widget.url!));
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
      // 使用[Video]小部件显示视频输出.
      child: Video(
        controller: controller,
        controls: (state) {
          return ControlsPage(player: player, animeName: widget.animeName);
        },
      ),
    );
  }
}
