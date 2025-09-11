import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:AnimeFlow/utils/fullscreen_utils.dart';
import 'package:intl/intl.dart';

/// 视频控制器服务类，负责处理播放器的各种业务逻辑
class VideoControllerService {
  final Player player;

  // 控件显示状态
  bool _showControls = true;
  bool _isMouseHovering = false;
  Timer? _hideTimer;

  // 指示器状态
  bool _showSeekIndicator = false;
  bool _showPlaybackIndicator = false;
  Duration _seekPosition = Duration.zero;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

  // 亮度和音量控制
  double _currentBrightness = 0.5;
  double _currentVolume = 50.0;
  double _originalBrightness = 0.5;
  double _originalVolume = 50.0;
  bool _showBrightnessIndicator = false;
  bool _showVolumeIndicator = false;
  Timer? _brightnessIndicatorTimer;
  Timer? _volumeIndicatorTimer;

  // 播放速度控制
  double _playbackSpeed = 1.0;
  double _originalPlaybackSpeed = 1.0; // 记录长按前的原始速度
  bool _showPlaybackSpeedIndicator = false;
  Timer? _playbackSpeedIndicatorTimer;
  Timer? _longPressTimer;

  // 回调函数
  VoidCallback? onStateChanged;

  VideoControllerService(this.player);

  // Getters
  bool get showControls => _showControls;

  bool get isMouseHovering => _isMouseHovering;

  bool get showSeekIndicator => _showSeekIndicator;

  bool get showPlaybackIndicator => _showPlaybackIndicator;

  bool get showBrightnessIndicator => _showBrightnessIndicator;

  bool get showPlaybackSpeedIndicator => _showPlaybackSpeedIndicator;

  bool get showVolumeIndicator => _showVolumeIndicator;

  Duration get seekPosition => _seekPosition;

  Duration get currentPosition => _currentPosition;

  Duration get duration => _duration;

  double get currentBrightness => _currentBrightness;

  double get currentVolume => _currentVolume;

  double get playbackSpeed => _playbackSpeed;

  /// 时间格式化
  String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:$seconds';
  }

  /// 创建时间流
  Stream<String> createTimeStream() {
    return Stream.periodic(
      const Duration(minutes: 1),
      (_) => DateFormat("HH:mm").format(DateTime.now()),
    ).asBroadcastStream();
  }

  /// 统一的指示器管理方法
  void _showIndicator(String indicatorType) {
    // 先隐藏所有指示器
    _showBrightnessIndicator = false;
    _showVolumeIndicator = false;
    _showSeekIndicator = false;
    _showPlaybackIndicator = false;

    // 取消所有定时器
    _brightnessIndicatorTimer?.cancel();
    _volumeIndicatorTimer?.cancel();

    // 显示指定的指示器
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
      case 'speed':
        _showPlaybackSpeedIndicator = true;
        break;
    }

    _notifyStateChanged();
  }

  /// 显示控件并设置自动隐藏
  void showControlsTemporarily() {
    _showControls = true;
    _notifyStateChanged();

    // 取消之前的定时器
    _hideTimer?.cancel();

    // 如果鼠标没有悬停，则设置自动隐藏
    if (!_isMouseHovering) {
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (!_isMouseHovering) {
          _showControls = false;
          _notifyStateChanged();
        }
      });
    }
  }

  /// 鼠标进入事件处理
  void onMouseEnter() {
    _isMouseHovering = true;
    _showControls = true;
    _notifyStateChanged();

    // 取消自动隐藏定时器
    _hideTimer?.cancel();
  }

  /// 鼠标离开事件处理
  void onMouseExit() {
    _isMouseHovering = false;
    _notifyStateChanged();

    // 重新启动自动隐藏定时器
    showControlsTemporarily();
  }

  /// 切换控件显示状态
  void toggleControls() {
    if (_showControls) {
      // 如果控件正在显示，且鼠标未悬停，则隐藏
      if (!_isMouseHovering) {
        _showControls = false;
        _notifyStateChanged();
        // 取消自动隐藏定时器
        _hideTimer?.cancel();
      }
    } else {
      // 如果控件隐藏，则显示并设置自动隐藏
      showControlsTemporarily();
    }
  }

  /// 双击切换播放/暂停状态
  void togglePlayback() {
    player.playOrPause();
    showPlaybackIndicatorTemporarily();
  }

  /// 显示播放/暂停指示器并自动隐藏
  void showPlaybackIndicatorTemporarily() {
    _showIndicator('playback');

    // 2秒后自动隐藏
    Future.delayed(const Duration(seconds: 2), () {
      _showPlaybackIndicator = false;
      _notifyStateChanged();
    });
  }

  /// 开始水平拖拽（进度调节）
  void onHorizontalDragStart(DragStartDetails details) {
    // 开始拖拽时获取当前播放位置和总时长
    _currentPosition = player.state.position;
    _duration = player.state.duration;
    _seekPosition = _currentPosition;
    _showIndicator('seek');
  }

  /// 水平拖拽更新（进度调节）
  void onHorizontalDragUpdate(DragUpdateDetails details, BuildContext context) {
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

    _seekPosition = Duration(milliseconds: clampedSeekPosition.toInt());
    _notifyStateChanged();
  }

  /// 水平拖拽结束（进度调节）
  void onHorizontalDragEnd(DragEndDetails details) {
    // 拖拽结束时跳转到指定位置
    player.seek(_seekPosition);

    _showSeekIndicator = false;
    _notifyStateChanged();
  }

  /// 初始化亮度和音量
  Future<void> initBrightnessAndVolume() async {
    try {
      _currentBrightness = await ScreenBrightnessPlatform.instance.application;
      _currentVolume = player.state.volume;

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

  /// 恢复原始亮度和音量设置
  /// TODO 暂时还未使用，后续需要在退出播放页(销毁player)时调用
  Future<void> restoreOriginalSettings() async {
    try {
      if (!FullscreenUtils.isDesktop()) {
        // await ScreenBrightness().setApplicationScreenBrightness(
        //   _originalBrightness,
        // );
        debugPrint('恢复原始亮度: $_originalBrightness');
      }

      await player.setVolume(_originalVolume);
      debugPrint('恢复原始音量: $_originalVolume');
    } catch (e) {
      debugPrint('恢复原始设置失败: $e');
    }
  }

  /// 显示播放速度指示器并自动隐藏
  void showPlaybackSpeedIndicatorTemporarily() {
    _showIndicator('speed');

    _playbackSpeedIndicatorTimer?.cancel();
  }

  /// 处理长按开始事件
  void onLongPressStart() {
    // 未播放时不处理
    if (!player.state.playing) {
      return;
    }

    // 记录当前播放速度作为原始速度
    _originalPlaybackSpeed = _playbackSpeed;
    adjustPlaybackSpeed(2.0);
    // 显示播放速度指示器
    showPlaybackSpeedIndicatorTemporarily();
  }

  /// 处理长按结束事件
  void onLongPressEnd() {
    _longPressTimer?.cancel();
    _playbackSpeedIndicatorTimer?.cancel();

    // 只在播放时才处理速度恢复
    if (!player.state.playing) {
      return;
    }

    // 恢复到长按前的原始播放速度
    _playbackSpeed = _originalPlaybackSpeed;
    player.setRate(_originalPlaybackSpeed);

    // 立即关闭指示器
    _showPlaybackSpeedIndicator = false;
    _notifyStateChanged();
  }

  ///调节播放倍速
  Future<void> adjustPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await player.setRate(speed);
  }

  /// 调节亮度
  Future<void> adjustBrightness(double delta) async {
    final newBrightness = (_currentBrightness + delta).clamp(0.0, 1.0);
    try {
      if (FullscreenUtils.isDesktop()) return;

      await ScreenBrightnessPlatform.instance.setApplicationScreenBrightness(
        newBrightness,
      );

      _currentBrightness = newBrightness;
      _showIndicator('brightness');

      // 设置自动隐藏定时器
      _brightnessIndicatorTimer = Timer(const Duration(seconds: 2), () {
        _showBrightnessIndicator = false;
        _notifyStateChanged();
      });
    } catch (e) {
      // 处理错误
      debugPrint('调节亮度失败: $e');
    }
  }

  /// 调节音量
  Future<void> adjustVolume(double delta) async {
    final deltaVolume = delta * 100;
    final newVolume = (_currentVolume + deltaVolume).clamp(0.0, 100.0);

    // 立即更新UI显示
    _currentVolume = newVolume;
    _showIndicator('volume');

    // 使用media_kit设置音量
    await player.setVolume(_currentVolume);

    // 设置自动隐藏定时器
    _volumeIndicatorTimer = Timer(const Duration(seconds: 2), () {
      _showVolumeIndicator = false;
      _notifyStateChanged();
    });
  }

  /// 垂直滑动处理（亮度和音量调节）
  void onVerticalDragUpdate(DragUpdateDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final screenWidth = box.size.width;
    final tapPosition = details.globalPosition.dx;

    // 计算滑动的变化量（负值表示向上，正值表示向下）
    final delta = -details.delta.dy / 300; // 除以300调节敏感度

    // 判断是左侧还是右侧
    if (tapPosition < screenWidth / 2) {
      // 左侧 - 调节亮度
      adjustBrightness(delta);
    } else {
      // 右侧 - 调节音量
      adjustVolume(delta);
    }
  }

  /// 初始化服务
  Future<void> initialize() async {
    // 初始化时显示控件
    showControlsTemporarily();

    // 初始化亮度和音量
    await initBrightnessAndVolume();
  }

  /// 释放资源
  void dispose() {
    // 清理定时器
    _hideTimer?.cancel();
    _brightnessIndicatorTimer?.cancel();
    _volumeIndicatorTimer?.cancel();
    _playbackSpeedIndicatorTimer?.cancel();
  }

  /// 通知状态变化
  void _notifyStateChanged() {
    onStateChanged?.call();
  }
}
