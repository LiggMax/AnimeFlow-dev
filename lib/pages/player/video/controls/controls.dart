///播放器控件ui
library;

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';

import 'custom_seek_bar.dart';

class ControlsPage extends StatefulWidget {
  final Player player;

  const ControlsPage({super.key, required this.player});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  // 时间格式化方法
  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        //顶部控件模板
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // 顶部自定义控件
        Positioned(
          left: 5,
          right: 5,
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

        //底部模板
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 65,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        //时间信息
        Positioned(
          bottom: 40,
          left: 10,
          right: 0,
          child: StreamBuilder<Duration>(
            stream: widget.player.stream.position,
            initialData: widget.player.state.position,
            builder: (context, positionSnapshot) {
              return StreamBuilder<Duration>(
                stream: widget.player.stream.duration,
                initialData: widget.player.state.duration,
                builder: (context, durationSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  final duration = durationSnapshot.data ?? Duration.zero;
                  Duration actualDuration = duration;

                  return Text(
                    '${_formatTime(position)}/${_formatTime(actualDuration)}',
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
          bottom: -5,
          left: 5,
          right: 5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialPlayOrPauseButton(iconSize: 30),
                  const SizedBox(width: 8),

                  // 进度条
                  Expanded(child: CustomSeekBar(player: widget.player)),

                  const SizedBox(width: 8),
                  MaterialFullscreenButton(iconSize: 30),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
