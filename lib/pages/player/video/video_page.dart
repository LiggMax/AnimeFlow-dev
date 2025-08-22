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
  final Function(String)? onVideoUrlReceived; // 添加视频URL回调

  const VideoPage({
    super.key,
    this.animeName,
    this.url,
    this.onVideoUrlReceived,
  });

  @override
  State<VideoPage> createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  // Create a [Player] to control playback.
  late final player = Player();

  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
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
      // Use [Video] widget to display video output.
      child: Video(
        controller: controller,
        controls: (state) {
          return ControlsPage(player: player, animeName: widget.animeName);
        },
      ),
    );
  }
}
