/*
  @Author Ligg
  @Time 2025/8/15
 */
import 'package:flutter/material.dart';

import '../Play/play_data.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const VideoData()),
                ),
                child: const Text('打开视频播放器示例'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
