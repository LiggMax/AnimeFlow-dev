import 'package:AnimeFlow/pages/player/detail/details_info.dart';
import 'package:AnimeFlow/pages/video/video_page.dart';
import 'package:flutter/material.dart';

class PlayInfo extends StatefulWidget {
  final String? animeName;
  final int? animeId;

  const PlayInfo({super.key, this.animeName, this.animeId});

  @override
  State<PlayInfo> createState() => _PlayInfoState();
}

class _PlayInfoState extends State<PlayInfo> with TickerProviderStateMixin {
  String? _currentVideoUrl; // 添加视频URL状态
  final GlobalKey _videoKey = GlobalKey();
  final GlobalKey _detailKey = GlobalKey();
  bool _isDetailVisible = true;

  @override
  void initState() {
    super.initState();
  }

  /// 处理视频URL回调
  void _handleVideoUrlReceived(String videoUrl) {
    setState(() {
      _currentVideoUrl = videoUrl;
    });
  }

  /// 切换详情区域可见性
  void _toggleDetailVisibility() {
    setState(() {
      _isDetailVisible = !_isDetailVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false, // 让内容延伸到底部
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;
            const double detailWidth = 300;
            return isWide
                ?
                  // 横屏模式
                  Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        right: _isDetailVisible ? detailWidth : 0,
                        child: VideoPage(
                          key: _videoKey,
                          animeName: widget.animeName,
                          url: _currentVideoUrl,
                          onToggleDetailVisibility:
                              _toggleDetailVisibility, // 传递回调函数
                        ),
                      ),
                      Positioned(
                        // 通过调整right值实现显示/隐藏
                        right: _isDetailVisible ? 0 : -detailWidth,
                        top: 0,
                        bottom: 0,
                        width: detailWidth,
                        child: DetailPage(
                          key: _detailKey,
                          animeName: widget.animeName,
                          animeId: widget.animeId,
                          onVideoUrlReceived: _handleVideoUrlReceived,
                        ),
                      ),
                    ],
                  )
                :
                  // 竖屏模式
                  Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPage(
                          key: _videoKey,
                          animeName: widget.animeName,
                          url: _currentVideoUrl,
                        ),
                      ),
                      Expanded(
                        child: DetailPage(
                          key: _detailKey,
                          animeName: widget.animeName,
                          animeId: widget.animeId,
                          onVideoUrlReceived: _handleVideoUrlReceived,
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
