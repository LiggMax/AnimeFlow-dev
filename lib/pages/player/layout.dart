import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // package：media_kit 的必要初始化。
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

/// 模拟播放器
// class VideoPlayerWidget extends StatelessWidget {
//   const VideoPlayerWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     debugPrint("VideoPlayer build"); // 打印是否重建
//     return Container(
//       color: Colors.black,
//       child: const Center(
//         child: Text(
//           "视频播放器",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});
  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  // Create a [Player] to control playback.
  late final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media('https://p3-dcd-sign.byteimg.com/tos-cn-i-f042mdwyw7/beee3dd9ec804f73b03a042dab782e52~tplv-jxcbcipi3j-image.image?lk3s=13ddc783&x-expires=1756927306&x-signature=yQua3QNNErIuRKPW1b7eTakvOPQ%3D'));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
        // Use [Video] widget to display video output.
        child: Video(controller: controller),
      ),
    );
  }
}
/// 模拟详情
class DetailWidget extends StatelessWidget {
  const DetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Detail build"); // 打印是否重建
    return Container(
      color: Colors.blueGrey,
      child: const Center(
        child: Text(
          "详情内容",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: ResponsivePlayerPage(),
      ),
    );
  }
}

class ResponsivePlayerPage extends StatefulWidget {
  const ResponsivePlayerPage({super.key});

  @override
  State<ResponsivePlayerPage> createState() => _ResponsivePlayerPageState();
}

class _ResponsivePlayerPageState extends State<ResponsivePlayerPage> {
  // 提前实例化，避免重建
  final _videoPlayer = const VideoPlayerWidget();
  final _detail = const DetailWidget();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;

        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              flex: 2,
              child: _videoPlayer,
            ),
            Expanded(
              flex: 3,
              child: _detail,
            ),
          ],
        );
      },
    );
  }
}
