///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'controls/custom_seek_bar.dart';

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

  // 时间格式化方法
  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:$seconds';
  }


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
                left: 0,
                right: 0,
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

              //时间信息
              Positioned(
                bottom: 40,
                left: 10,
                right: 0,
                child: StreamBuilder<Duration>(
                  stream: player.stream.position,
                  builder: (context, positionSnapshot) {
                    return StreamBuilder<Duration>(
                      stream: player.stream.duration,
                      builder: (context, durationSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        final duration = durationSnapshot.data ?? Duration.zero;

                        return Text(
                          '${_formatTime(position)}/${_formatTime(duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 底部控件栏
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialPlayOrPauseButton(),
                          const SizedBox(width: 8),
                          // 进度条
                          Expanded(child: CustomSeekBar(player: player)),
                          const SizedBox(width: 8),
                          MaterialFullscreenButton(),
                        ]
                    ),
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
