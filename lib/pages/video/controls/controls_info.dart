///播放器控件ui
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';
import 'package:intl/intl.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:AnimeFlow/utils/fullscreen_utils.dart';
import 'battery_indicator.dart';
import 'custom_seek_bar.dart';
import 'seek_indicator.dart';

class ControlsPage extends StatefulWidget {
  final String? animeName;
  final Player player;

  const ControlsPage({super.key, required this.player, this.animeName});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool _showControls = true;
  bool _isMouseHovering = false;
  Timer? _hideTimer;
  Timer? _batteryUpdateTimer;
  bool _showSeekIndicator = false;
  bool _showPlaybackIndicator = false;
  Duration _seekPosition = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  late Stream<String> _timeStream;

  // 亮度和音量控制相关
  double _currentBrightness = 0.5;
  double _currentVolume = 50.0;
  double _originalBrightness = 0.5;
  double _originalVolume = 50.0;
  bool _showBrightnessIndicator = false;
  bool _showVolumeIndicator = false;
  Timer? _brightnessIndicatorTimer;
  Timer? _volumeIndicatorTimer;

  // 防抖相关
  Timer? _volumeDebounceTimer;

  // 统一的指示器管理方法
  void _showIndicator(String indicatorType) {
    // 先隐藏所有指示器
    setState(() {
      _showBrightnessIndicator = false;
      _showVolumeIndicator = false;
      _showSeekIndicator = false;
      _showPlaybackIndicator = false;
    });

    // 取消所有定时器
    _brightnessIndicatorTimer?.cancel();
    _volumeIndicatorTimer?.cancel();

    // 显示指定的指示器
    setState(() {
      switch (indicatorType) {
        case 'brightness':
          _showBrightnessIndicator = true;
          break;
        case 'volume':
          _showVolumeIndicator = true;
          break;
        case 'seek':
          _showSeekIndicator = true;
          break;
        case 'playback':
          _showPlaybackIndicator = true;
          break;
      }
    });
  }

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

    // 如果鼠标没有悬停，则设置自动隐藏
    if (!_isMouseHovering) {
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && !_isMouseHovering) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  // 鼠标进入事件
  void _onMouseEnter(PointerEvent event) {
    setState(() {
      _isMouseHovering = true;
      _showControls = true;
    });
    // 取消自动隐藏定时器
    _hideTimer?.cancel();
  }

  // 鼠标离开事件
  void _onMouseExit(PointerEvent event) {
    setState(() {
      _isMouseHovering = false;
    });
    // 重新启动自动隐藏定时器
    _showControlsTemporarily();
  }

  // 切换控件显示状态
  void _toggleControls() {
    if (_showControls) {
      // 如果控件正在显示，且鼠标未悬停，则隐藏
      if (!_isMouseHovering) {
        setState(() {
          _showControls = false;
        });
        // 取消自动隐藏定时器
        _hideTimer?.cancel();
      }
    } else {
      // 如果控件隐藏，则显示并设置自动隐藏
      _showControlsTemporarily();
    }
  }

  // 双击切换播放/暂停状态
  void _togglePlayback() {
    widget.player.playOrPause();
    _showPlaybackIndicatorTemporarily();
  }

  // 显示播放/暂停指示器并自动隐藏
  void _showPlaybackIndicatorTemporarily() {
    _showIndicator('playback');

    // 2秒后自动隐藏
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showPlaybackIndicator = false;
        });
      }
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    // 开始拖拽时获取当前播放位置和总时长
    _currentPosition = widget.player.state.position;
    _duration = widget.player.state.duration;
    _seekPosition = _currentPosition;
    _showIndicator('seek');
  }

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
    BuildContext context,
  ) {
    if (_duration.inMilliseconds <= 0) return;

    // 计算拖拽距离对应的时间变化
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final dx = details.delta.dx;

    // 根据屏幕宽度计算单位时间，这里设置为屏幕宽度代表总时长的10%
    final millisecondsPerPixel = (_duration.inMilliseconds * 0.1) / width;
    final millisecondsChange = dx * millisecondsPerPixel;

    // 更新预览位置
    final newSeekPosition = _seekPosition.inMilliseconds + millisecondsChange;
    final clampedSeekPosition = newSeekPosition.clamp(
      0.0,
      _duration.inMilliseconds.toDouble(),
    );

    setState(() {
      _seekPosition = Duration(milliseconds: clampedSeekPosition.toInt());
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // 拖拽结束时跳转到指定位置
    widget.player.seek(_seekPosition);

    setState(() {
      _showSeekIndicator = false;
    });
  }

  // 初始化亮度和音量
  Future<void> _initBrightnessAndVolume() async {
    try {
      _currentBrightness = await ScreenBrightness().application;

      _currentVolume = widget.player.state.volume;

      // 记录原始值，用于退出时恢复
      _originalBrightness = _currentBrightness;
      _originalVolume = _currentVolume;
    } catch (e) {
      // 如果获取失败，使用默认值
      _currentBrightness = 0.5;
      _currentVolume = 50.0;
      _originalBrightness = 0.5;
      _originalVolume = 50.0;
      debugPrint('初始化亮度和音量失败: $e');
    }
  }

  // 恢复原始亮度和音量设置
  Future<void> _restoreOriginalSettings() async {
    try {
      if (!FullscreenUtils.isDesktop()) {
        await ScreenBrightness().setApplicationScreenBrightness(
          _originalBrightness,
        );
        debugPrint('恢复原始亮度: $_originalBrightness');
      }

      await widget.player.setVolume(_originalVolume);
      debugPrint('恢复原始音量: $_originalVolume');
    } catch (e) {
      debugPrint('恢复原始设置失败: $e');
    }
  }

  // 调节亮度
  Future<void> _adjustBrightness(double delta) async {
    final newBrightness = (_currentBrightness + delta).clamp(0.0, 1.0);
    try {
      if (!FullscreenUtils.isDesktop()) {
        await ScreenBrightness().setApplicationScreenBrightness(newBrightness);
      }

      _currentBrightness = newBrightness;
      _showIndicator('brightness');

      // 设置自动隐藏定时器
      _brightnessIndicatorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showBrightnessIndicator = false;
          });
        }
      });
    } catch (e) {
      // 处理错误
      debugPrint('调节亮度失败: $e');
    }
  }

  // 调节音量
  Future<void> _adjustVolume(double delta) async {
    final deltaVolume = delta * 100;
    final newVolume = (_currentVolume + deltaVolume).clamp(0.0, 100.0);

    // 立即更新UI显示
    setState(() {
      _currentVolume = newVolume;
    });
    _showIndicator('volume');

    // 使用media_kit设置音量
    await widget.player.setVolume(_currentVolume);

    // 设置自动隐藏定时器
    _volumeIndicatorTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
        });
      }
    });
  }

  // 垂直滑动处理（亮度和音量调节）
  void _onVerticalDragUpdate(DragUpdateDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final screenWidth = box.size.width;
    final tapPosition = details.globalPosition.dx;

    // 计算滑动的变化量（负值表示向上，正值表示向下）
    final delta = -details.delta.dy / 300; // 除以300调节敏感度

    // 判断是左侧还是右侧
    if (tapPosition < screenWidth / 2) {
      // 左侧 - 调节亮度
      _adjustBrightness(delta);
    } else {
      // 右侧 - 调节音量
      _adjustVolume(delta);
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化时显示控件
    _showControlsTemporarily();

    _timeStream = Stream.periodic(
      const Duration(minutes: 1),
      (_) => DateFormat("HH:mm").format(DateTime.now()),
    ).asBroadcastStream();

    // 初始化亮度和音量
    _initBrightnessAndVolume();
  }

  @override
  void dispose() {
    // 清理定时器
    _hideTimer?.cancel();
    _batteryUpdateTimer?.cancel();
    _brightnessIndicatorTimer?.cancel();
    _volumeIndicatorTimer?.cancel();
    _volumeDebounceTimer?.cancel();

    // 恢复原始设置（异步执行）
    _restoreOriginalSettings();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 检测是否为全屏（横屏）模式
    final orientation = MediaQuery.of(context).orientation;
    final isFullscreen = orientation == Orientation.landscape;

    return MouseRegion(
      onEnter: _onMouseEnter,
      onExit: _onMouseExit,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 透明的点击检测层，覆盖整个屏幕
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleControls,
              onDoubleTap: _togglePlayback,
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: (details) =>
                  _onHorizontalDragUpdate(details, context),
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onVerticalDragUpdate: (details) =>
                  _onVerticalDragUpdate(details, context),
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
                          children: [
                            // 左侧区域：返回按钮和动漫名称
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Flexible(
                                    child: isFullscreen
                                        ? Text(
                                            widget.animeName ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                            // 中间区域：系统时间（只在全屏模式下显示）
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: isFullscreen
                                    ? StreamBuilder<String>(
                                        stream: _timeStream,
                                        initialData: DateFormat(
                                          "HH:mm",
                                        ).format(DateTime.now()),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            // 右侧区域：电池电量和信息按钮
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // 电池电量显示（只在全屏模式下显示）
                                  if (isFullscreen) ...[BatteryIndicator()],
                                  IconButton(
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () =>
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('信息按钮点击'),
                                          ),
                                        ),
                                  ),
                                ],
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

                      //视频时间信息
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

          /// 添加缓冲动画指示器
          StreamBuilder<bool>(
            stream: widget.player.stream.buffering,
            initialData: widget.player.state.buffering,
            builder: (context, snapshot) {
              final isBuffering = snapshot.data ?? false;
              return BufferingIndicator(isBuffering: isBuffering);
            },
          ),

          ///滑动进度指示器
          SeekIndicator(
            visible: _showSeekIndicator,
            currentPosition: _currentPosition,
            seekPosition: _seekPosition,
          ),

          ///播放/暂停指示器
          StreamBuilder<bool>(
            stream: widget.player.stream.playing,
            initialData: widget.player.state.playing,
            builder: (context, snapshot) {
              final isPlaying = snapshot.data ?? false;
              return PlaybackToggleIndicator(
                visible: _showPlaybackIndicator,
                isPlaying: isPlaying,
              );
            },
          ),

          /// 亮度指示器
          BrightnessIndicator(
            visible: _showBrightnessIndicator,
            brightness: _currentBrightness,
          ),

          /// 音量指示器
          VolumeIndicator(
            visible: _showVolumeIndicator,
            volume: _currentVolume / 100.0,
          ),
        ],
      ),
    );
  }
}
