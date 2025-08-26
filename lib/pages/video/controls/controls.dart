///播放器控件ui
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';

import 'custom_seek_bar.dart';

class ControlsPage extends StatefulWidget {
  final String? animeName;
  final Player player;

  const ControlsPage({super.key, required this.player, this.animeName});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool _showControls = true;
  Timer? _hideTimer;

  // 时间格式化方法
  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:$seconds';
  }

  // 显示控件并设置自动隐藏
  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    // 取消之前的定时器
    _hideTimer?.cancel();

    // 自动隐藏时间
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  // 切换控件显示状态
  void _toggleControls() {
    if (_showControls) {
      // 如果控件正在显示，则隐藏
      setState(() {
        _showControls = false;
      });
      // 取消自动隐藏定时器
      _hideTimer?.cancel();
    } else {
      // 如果控件隐藏，则显示并设置自动隐藏
      _showControlsTemporarily();
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化时显示控件
    _showControlsTemporarily();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 透明的点击检测层，覆盖整个屏幕
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
        ),

        // 控件层
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _showControls
              ? Stack(
                  key: const ValueKey('controls_visible'),
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
                              Text(
                                widget.animeName ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('信息按钮点击')),
                                ),
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
                              final position =
                                  positionSnapshot.data ?? Duration.zero;
                              final duration =
                                  durationSnapshot.data ?? Duration.zero;
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
                              Expanded(
                                child: CustomSeekBar(player: widget.player),
                              ),

                              const SizedBox(width: 8),
                              MaterialFullscreenButton(iconSize: 30),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('controls_hidden')),
        ),

        StreamBuilder<bool>(
          stream: widget.player.stream.buffering,
          initialData: widget.player.state.buffering,
          builder: (context, snapshot) {
            final isBuffering = snapshot.data ?? false;
            return IgnorePointer(
              child: Center(
                child: Visibility(
                  visible: isBuffering,
                  child: SizedBox(
                    width: 120,
                    height: 100,
                    child:  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            '缓冲中...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
