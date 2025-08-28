///播放器控件ui
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/material.dart';
import 'package:intl/intl.dart';
import 'package:AnimeFlow/pages/video/controller/video_service.dart';
import 'battery_indicator.dart';
import 'controls_bottom.dart';
import 'seek_indicator.dart';

class ControlsPage extends StatefulWidget {
  final String? animeName;
  final Player player;

  const ControlsPage({super.key, required this.player, this.animeName});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  late VideoControllerService _videoService;
  Timer? _batteryUpdateTimer;
  late Stream<String> _timeStream;

  /// 状态更新回调
  void _onServiceStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _videoService = VideoControllerService(widget.player);
    _videoService.onStateChanged = _onServiceStateChanged;
    _videoService.initialize();
    _timeStream = _videoService.createTimeStream();
  }

  @override
  void dispose() {
    // 清理定时器
    _batteryUpdateTimer?.cancel();
    // 释放视频服务资源
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 检测是否为全屏（横屏）模式
    final orientation = MediaQuery
        .of(context)
        .orientation;
    final isFullscreen = orientation == Orientation.landscape;

    return MouseRegion(
      onEnter: (event) => _videoService.onMouseEnter(),
      onExit: (event) => _videoService.onMouseExit(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 透明的点击检测层，覆盖整个屏幕
          Positioned.fill(
            child: GestureDetector(
              onTap: _videoService.toggleControls,
              onDoubleTap: _videoService.togglePlayback,
              onHorizontalDragStart: _videoService.onHorizontalDragStart,
              onHorizontalDragUpdate: (details) =>
                  _videoService.onHorizontalDragUpdate(details, context),
              onHorizontalDragEnd: _videoService.onHorizontalDragEnd,
              onVerticalDragUpdate: (details) =>
                  _videoService.onVerticalDragUpdate(details, context),
              onLongPressStart: (_) => _videoService.onLongPressStart(),
              onLongPressEnd: (_) => _videoService.onLongPressEnd(),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

          // 控件层
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _videoService.showControls
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

                // 底部控件栏
                Positioned(
                  bottom: 0,
                  left: 5,
                  right: 5,
                  child: Column(
                    children: [
                      isFullscreen
                          ?
                      /// 全屏/宽屏模式下的底部控件ui
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: VideoTimeInfo(
                                //视频时间信息
                                player: widget.player,
                                videoService: _videoService,
                              ),
                            ),

                            // 进度条
                            CustomSeekBar(player: widget.player),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                MaterialPlayOrPauseButton(
                                  iconSize: 30,
                                ),
                                //弹幕输入框
                                BarrageInput(),

                                MaterialFullscreenButton(
                                  iconSize: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          :
                      /// 非全屏/宽屏模式下的底部控件ui
                      Column(
                        children: [
                          //视频时间信息
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(left: 15),
                              child: VideoTimeInfo(
                                player: widget.player,
                                videoService: _videoService,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              MaterialPlayOrPauseButton(
                                iconSize: 30,
                              ),
                              const SizedBox(width: 8),

                              // 进度条
                              Expanded(
                                child: CustomSeekBar(
                                  player: widget.player,
                                ),
                              ),

                              const SizedBox(width: 8),
                              MaterialFullscreenButton(
                                iconSize: 30,
                              ),
                            ],
                          ),
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
          BufferingIndicator(
            stream: widget.player.stream.buffering,
            initialData: widget.player.state.buffering,
          ),

          ///滑动进度指示器
          SeekIndicator(
            visible: _videoService.showSeekIndicator,
            currentPosition: _videoService.currentPosition,
            seekPosition: _videoService.seekPosition,
          ),

          ///播放/暂停指示器
          PlaybackToggleIndicator(
            visible: _videoService.showPlaybackIndicator,
            stream: widget.player.stream.playing,
            initialData: widget.player.state.playing,
          ),

          /// 亮度指示器
          BrightnessIndicator(
            visible: _videoService.showBrightnessIndicator,
            brightness: _videoService.currentBrightness,
          ),

          /// 音量指示器
          VolumeIndicator(
            visible: _videoService.showVolumeIndicator,
            volume: _videoService.currentVolume / 100.0,
          ),

          /// 快进/快退指示器
          PlaybackSpeedIndicator(
            visible: _videoService.showPlaybackSpeedIndicator,
            speed: _videoService.playbackSpeed,
          ),
        ],
      ),
    );
  }
}
