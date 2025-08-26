///@Author Ligg
///@Time 2025/8/26
///滑动进度指示器
library;

import 'package:flutter/material.dart';

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
