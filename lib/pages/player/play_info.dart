import 'package:AnimeFlow/pages/player/detail/details_info.dart';
import 'package:AnimeFlow/pages/player/video/video_page.dart';
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


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: Column(
          children: [
            /// 视频播放器
            VideoPage(animeName: widget.animeName),

            ///内容区域
            DetailPage(animeName: widget.animeName, animeId: widget.animeId),
          ],
        ),
      ),
    );
  }
}
