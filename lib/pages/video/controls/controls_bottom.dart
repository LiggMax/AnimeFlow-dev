///@Author Ligg
///@Time 2025/8/28
///底部控件
library;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../controller/video_service.dart';

///视频时间信息
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

///弹幕输入框
class BarrageInput extends StatelessWidget {
  const BarrageInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.comment,
                color: Colors.white70,
                size: 20,
              ),
            ),
            Expanded(
              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '发送弹幕动能施工中...',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                onSubmitted: (value) {
                  /// 实现弹幕发送功能
                  if (value.isNotEmpty) {
                    // 发送弹幕的代码
                    print('发送弹幕: $value');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
