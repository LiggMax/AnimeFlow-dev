import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../utils/fullscreen_utils.dart';
import '../../routes.dart';

/// 视频播放器核心组件
class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final VoidCallback? onBackPressed;
  final bool showControls;
  final bool isFullscreen;
  final VoidCallback? onToggleFullscreen;
  final Player player; // 必需的播放器实例
  final VideoController controller; // 必需的控制器实例

  const VideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.onBackPressed,
    this.showControls = false,
    this.isFullscreen = false,
    this.onToggleFullscreen,
    required this.player,
    required this.controller,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // 不在这里释放播放器资源，由父组件管理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据全屏状态调整布局
    if (widget.isFullscreen) {
      return Material(
        color: Colors.black,
        child: SizedBox.expand(
          child: Video(
            controller: widget.controller,
            controls: widget.showControls
                ? _buildCustomControls
                : NoVideoControls,
          ),
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(
          controller: widget.controller,
          controls: widget.showControls
              ? _buildCustomControls
              : NoVideoControls,
        ),
      );
    }
  }

  // 自定义播放器控件
  Widget _buildCustomControls(VideoState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 顶部控制栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 返回按钮
                  IconButton(
                    onPressed: () {
                      if (widget.isFullscreen) {
                        // 全屏模式：退出全屏
                        if (widget.onToggleFullscreen != null) {
                          widget.onToggleFullscreen!();
                        }
                      } else {
                        // 非全屏模式：返回上一级
                        if (widget.onBackPressed != null) {
                          widget.onBackPressed!();
                        } else {
                          context.pop();
                        }
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  // 标题
                  if (widget.title != null)
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // 设置按钮
                  IconButton(
                    onPressed: () {
                      _showSettingsDialog(state.context, widget.controller);
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 底部控制栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 时间显示
                StreamBuilder<Duration>(
                  stream: widget.controller.player.stream.position,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = widget.controller.player.state.duration;

                    if (duration.inSeconds == 0) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 底部控制栏
                Row(
                  children: [
                    // 播放/暂停按钮
                    StreamBuilder<bool>(
                      stream: widget.controller.player.stream.playing,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data ?? false;
                        return IconButton(
                          onPressed: () =>
                              widget.controller.player.playOrPause(),
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 35,
                          ),
                        );
                      },
                    ),

                    // 音量控制
                    StreamBuilder<double>(
                      stream: widget.controller.player.stream.volume,
                      builder: (context, snapshot) {
                        final volume = snapshot.data ?? 100.0;
                        return IconButton(
                          onPressed: () {
                            final newVolume = volume > 0 ? 0.0 : 100.0;
                            widget.controller.player.setVolume(newVolume);
                          },
                          icon: Icon(
                            volume > 0 ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),

                    // 进度条
                    Expanded(
                      child: StreamBuilder<Duration>(
                        stream: widget.controller.player.stream.position,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration =
                              widget.controller.player.state.duration;

                          if (duration.inSeconds == 0) {
                            return const SizedBox.shrink();
                          }

                          final progress =
                              position.inMilliseconds / duration.inMilliseconds;

                          return SliderTheme(
                            data: SliderTheme.of(state.context).copyWith(
                              activeTrackColor: Colors.red,
                              inactiveTrackColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              thumbColor: Colors.red,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (value * duration.inMilliseconds).round(),
                                );
                                widget.controller.player.seek(newPosition);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // 全屏按钮
                    IconButton(
                      onPressed: () {
                        if (widget.onToggleFullscreen != null) {
                          widget.onToggleFullscreen!();
                        } else {
                          ScaffoldMessenger.of(state.context).showSnackBar(
                            const SnackBar(
                              content: Text('全屏功能不可用'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        widget.isFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 格式化时间
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  // 显示设置对话框
  void _showSettingsDialog(BuildContext context, VideoController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('播放设置', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 播放速度设置
            ListTile(
              title: const Text('播放速度', style: TextStyle(color: Colors.white)),
              subtitle: StreamBuilder<double>(
                stream: controller.player.stream.rate,
                builder: (context, snapshot) {
                  final rate = snapshot.data ?? 1.0;
                  return Text(
                    '${rate}x',
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              trailing: const Icon(Icons.speed, color: Colors.white),
              onTap: () => _showSpeedDialog(context, controller),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 显示速度选择对话框
  void _showSpeedDialog(BuildContext context, VideoController controller) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('选择播放速度', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map(
                (speed) => ListTile(
                  title: Text(
                    '${speed}x',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    controller.player.setRate(speed);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // 获取播放器实例（供外部使用）
  Player get playerInstance => widget.player;

  // 获取控制器实例（供外部使用）
  VideoController get controllerInstance => widget.controller;
}

/// 视频播放器页面
class VideoPage extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const VideoPage({Key? key, required this.videoUrl, this.title})
    : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  bool _isFullscreen = false;
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // 创建媒体对象
      final media = Media(widget.videoUrl);

      // 打开视频
      await player.open(media);

      // 设置播放列表模式为单曲循环
      await player.setPlaylistMode(PlaylistMode.single);

      // 设置音量
      await player.setVolume(100.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频加载失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    // 退出时重置系统UI和方向
    FullscreenUtils.exitFullScreen();
    player.dispose();
    super.dispose();
  }

  // 切换全屏状态
  void _toggleFullscreen() async {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // 进入全屏
      await FullscreenUtils.enterFullScreen();
    } else {
      // 退出全屏
      await FullscreenUtils.exitFullScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      // 全屏模式：直接返回VideoPlayer，不包装在Scaffold中
      return VideoPlayer(
        videoUrl: widget.videoUrl,
        title: widget.title,
        showControls: true,
        isFullscreen: _isFullscreen,
        onToggleFullscreen: _toggleFullscreen,
        player: player,
        // 传递播放器实例
        controller: controller, // 传递控制器实例
      );
    } else {
      // 正常模式：带AppBar
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: widget.title != null
              ? Text(widget.title!, style: const TextStyle(color: Colors.white))
              : null,
        ),
        body: SafeArea(
          child: VideoPlayer(
            videoUrl: widget.videoUrl,
            title: widget.title,
            showControls: true,
            isFullscreen: _isFullscreen,
            onToggleFullscreen: _toggleFullscreen,
            onBackPressed: () => Navigator.of(context).pop(),
            // 正常模式：返回上一级
            player: player,
            // 传递播放器实例
            controller: controller, // 传递控制器实例
          ),
        ),
      );
    }
  }
}
