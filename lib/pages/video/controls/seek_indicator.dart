///@Author Ligg
///@Time 2025/8/26
///指示器
library;

import 'package:flutter/material.dart';

/// 快进后退指示器
class SeekIndicator extends StatelessWidget {
  final bool visible;
  final Duration currentPosition;
  final Duration seekPosition;

  const SeekIndicator({
    super.key,
    required this.visible,
    required this.currentPosition,
    required this.seekPosition,
  });

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Visibility(
          visible: visible,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  seekPosition > currentPosition
                      ? Icons.fast_forward
                      : Icons.fast_rewind,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(seekPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///播放暂停按钮指示器
class PlaybackToggleIndicator extends StatelessWidget {
  final bool visible;
  final bool isPlaying;

  const PlaybackToggleIndicator({
    super.key,
    required this.visible,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Visibility(
          visible: visible,
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            width: 100,
            height: 100,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white70,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }
}

///缓冲指示器
class BufferingIndicator extends StatelessWidget {
  final bool isBuffering;

  const BufferingIndicator({super.key, required this.isBuffering});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Visibility(
          visible: isBuffering,
          child: SizedBox(
            width: 120,
            height: 100,
            child: Center(
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
  }
}

// 亮度指示器组件
class BrightnessIndicator extends StatelessWidget {
  final bool visible;
  final double brightness;

  const BrightnessIndicator({
    super.key,
    required this.visible,
    required this.brightness,
  });

  IconData _getBrightnessIcon(brightness) {
    if (brightness == 0) {
      return Icons.brightness_5_rounded;
    } else if (brightness < 0.5) {
      return Icons.brightness_6_rounded;
    } else if (brightness < 0.8) {
      return Icons.brightness_4_rounded;
    } else {
      return Icons.brightness_7_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getBrightnessIcon(brightness), color: Colors.white, size: 24),
            const SizedBox(width: 5),
            SizedBox(
              width: 80,
              height: 5,
              //圆角
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(5),
                value: brightness,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 50,
              child: Text(
                '${(brightness * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 音量指示器组件
class VolumeIndicator extends StatelessWidget {
  final bool visible;
  final double volume;

  const VolumeIndicator({
    super.key,
    required this.visible,
    required this.volume,
  });

  IconData _getVolumeIcon(double volume) {
    if (volume == 0) {
      return Icons.volume_off;
    } else if (volume < 0.5) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getVolumeIcon(volume), color: Colors.white, size: 24),
            const SizedBox(width: 5),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: volume,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: 50,
              child: Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 播放速度指示器
class PlaybackSpeedIndicator extends StatelessWidget {
  final bool visible;
  final double speed;

  const PlaybackSpeedIndicator({
    super.key,
    required this.visible,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Visibility(
          visible: visible,
          child: Container(
            margin: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.fast_forward_rounded,
                  color: Colors.white,
                  size: 60,
                ),
                Text(
                  '${speed.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
