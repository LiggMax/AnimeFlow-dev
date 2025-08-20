///进度条组件
library;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

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
                                // 播放进度部分
                                Container(
                                  height: 6,
                                  width: constraints.maxWidth * currentProgress,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Positioned(
                                  left:
                                      ((constraints.maxWidth *
                                                  currentProgress) -
                                              10)
                                          .clamp(
                                            0.0,
                                            constraints.maxWidth - 20,
                                          ),
                                  top: -5,
                                  child: Material(
                                    elevation: 4, // 提升层级
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 16,
                                      height: 16,
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

  // ... existing code ...
}
