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

///播放器进度条组件
class CustomSeekBar extends StatefulWidget {
  final Player player;

  const CustomSeekBar({super.key, required this.player});

  @override
  State<CustomSeekBar> createState() => _CustomSeekBarState();
}

class _CustomSeekBarState extends State<CustomSeekBar> {
  bool _isDragging = false;
  Duration _dragPosition = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: widget.player.stream.position,
      initialData: widget.player.state.position,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: widget.player.stream.duration,
          initialData: widget.player.state.duration,
          builder: (context, durationSnapshot) {
            return StreamBuilder<Duration>(
              stream: widget.player.stream.buffer,
              initialData: widget.player.state.buffer,
              builder: (context, bufferSnapshot) {
                return StreamBuilder<bool>(
                  stream: widget.player.stream.buffering,
                  initialData: widget.player.state.buffering,
                  builder: (context, bufferingSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final buffer = bufferSnapshot.data ?? Duration.zero;

                    Duration actualDuration = duration;

                    final bufferProgress = actualDuration.inMilliseconds > 0
                        ? (buffer.inMilliseconds /
                        actualDuration.inMilliseconds)
                        .clamp(0.0, 1.0)
                        : 0.0;

                    return GestureDetector(
                      onHorizontalDragStart: (details) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                        final tapPosition = details.localPosition.dx;
                        final width = renderBox.size.width;
                        final dragProgress = (tapPosition / width).clamp(
                          0.0,
                          1.0,
                        );

                        setState(() {
                          _dragPosition = Duration(
                            milliseconds:
                            (actualDuration.inMilliseconds * dragProgress)
                                .toInt(),
                          );
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        widget.player.seek(_dragPosition);
                        setState(() {
                          _isDragging = false;
                        });
                      },
                      onTapDown: (details) {
                        final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                        final tapPosition = details.localPosition.dx;
                        final width = renderBox.size.width;
                        final tapProgress = (tapPosition / width).clamp(
                          0.0,
                          1.0,
                        );

                        final seekPosition = Duration(
                          milliseconds:
                          (actualDuration.inMilliseconds * tapProgress)
                              .toInt(),
                        );

                        widget.player.seek(seekPosition);
                      },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final currentPosition = _isDragging
                                ? _dragPosition
                                : position;
                            final currentProgress =
                            actualDuration.inMilliseconds > 0
                                ? (currentPosition.inMilliseconds /
                                actualDuration.inMilliseconds)
                                .clamp(0.0, 1.0)
                                : 0.0;

                            return Stack(
                              clipBehavior: Clip.none, // 允许子组件超出边界
                              children: [
                                // 背景轨道
                                Container(
                                  height: 6,
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // 缓冲部分
                                Container(
                                  height: 6,
                                  width: constraints.maxWidth * bufferProgress,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // 播放进度条
                                Container(
                                  height: 6,
                                  width: constraints.maxWidth * currentProgress,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                //指示器
                                Positioned(
                                  left:
                                  ((constraints.maxWidth *
                                      currentProgress) -
                                      10)
                                      .clamp(
                                    0.0,
                                    constraints.maxWidth - 20,
                                  ),
                                  top: -6,
                                  child: Material(
                                    elevation: 4, // 提升层级
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
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
