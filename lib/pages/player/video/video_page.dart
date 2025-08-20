///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'controls/controls.dart';

class VideoPage extends StatefulWidget {
  final String? animeName;
  const VideoPage({Key? key, this.animeName}) : super(key: key);

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
    player.open(
      Media('https://apn.moedot.net/d/wo/2507/%E6%9B%B4%E8%A1%A304z.mp4'),
    );
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
          return ControlsPage(player: player,animeName: widget.animeName,);
        },
      ),
    );
  }
}
