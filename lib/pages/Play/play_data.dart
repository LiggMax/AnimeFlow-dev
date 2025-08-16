///@Author Ligg
///@Time 2025/8/16
library;

import 'package:AnimeFlow/pages/video/video.dart';
import 'package:flutter/material.dart';

class VideoData extends StatefulWidget {
  const VideoData({super.key});

  @override
  State<VideoData> createState() => _VideoDataState();
}

class _VideoDataState extends State<VideoData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放数据'),
      ),
      body: Column(
        children: [
          _videoView()
        ],
      ),
    );
  }
  _videoView() {
    String url = 'https://apn.moedot.net/d/wo/2507/DDD01.mp4';
    String cover = 'https://play.xfvod.pro/images/hb/ddd.webp';
    return VideoView(url, cover: cover);
  }
}

