import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String url;
  final String cover;
  final bool autoPlay;
  final bool looping;
  final double aspectRatio;

  const VideoView(
    this.url, {
    super.key,
    required this.cover,
    this.autoPlay = true,
    this.looping = false,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  //封面
  get  _placenolder => FractionallySizedBox(
    widthFactor: 1,
    child: Image.network(widget.cover),
  );
  @override
  void initState() {
    super.initState();

    /// 初始化播放器
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: widget.aspectRatio,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      placeholder: _placenolder,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screeWidth = MediaQuery.of(context).size.width;
    double playerHeight = screeWidth / widget.aspectRatio;
    return Container(
      width: screeWidth,
      height: playerHeight,
      child: Chewie(controller: _chewieController),
    );
  }
}
