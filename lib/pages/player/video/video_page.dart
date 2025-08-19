///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

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
          return Stack(
            fit: StackFit.expand,
            children: [
              // 顶部自定义控件
              Positioned(
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          '自定义标题',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('信息按钮点击'))),
                    ),
                  ],
                ),
              ),
              // 底部控件栏
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialPlayOrPauseButton(),
                    const SizedBox(width: 8),
                    // 进度条
                    Expanded(child: MaterialSeekBar()),
                    const SizedBox(width: 8),
                    MaterialFullscreenButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
