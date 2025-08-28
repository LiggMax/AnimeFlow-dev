///@Author Ligg
///@Time 2025/8/28
///底部控件
library;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../controller/video_service.dart';

class VideoTimeInfo extends StatelessWidget {
  final Player player;
  final VideoControllerService videoService;

  const VideoTimeInfo({
    super.key,
    required this.player,
    required this.videoService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData:
      player.state.position,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream:
          player.stream.duration,
          initialData:
          player.state.duration,
          builder: (context, durationSnapshot) {
            final position =
                positionSnapshot.data ??
                    Duration.zero;
            final duration =
                durationSnapshot.data ??
                    Duration.zero;
            Duration actualDuration =
                duration;

            return Text(
              '${videoService.formatTime(position)}/${videoService.formatTime(actualDuration)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        );
      },
    );
  }
}
