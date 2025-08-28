import 'package:AnimeFlow/pages/player/detail/details_info.dart';
import 'package:AnimeFlow/pages/video/video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayInfo extends StatefulWidget {
  final String? animeName;
  final int? animeId;

  const PlayInfo({Key? key, this.animeName, this.animeId}) : super(key: key);

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
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // 设置状态栏为深色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isLandscape) {
              // 横屏模式
              const double detailWidth = 350;
              return Stack(
                children: [
                  // 视频播放器
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    right: _isDetailVisible ? detailWidth : 0,
                    child: VideoPage(
                      key: _videoKey,
                      animeName: widget.animeName,
                      url: _currentVideoUrl,
                      onToggleDetailVisibility: _toggleDetailVisibility, // 传递回调函数
                    ),
                  ),
                  // 内容区域
                  if (_isDetailVisible)
                    Positioned(
                      right: 0,
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
              );
            } else {
              // 竖屏模式
              return Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPage(
                      key: _videoKey,
                      animeName: widget.animeName,
                      url: _currentVideoUrl,
                    ),
                  ),
                  // 内容区域
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
            }
          },
        ),
      ),
    );
  }
}
