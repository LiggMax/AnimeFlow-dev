import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'video/video_page.dart';
import '../../utils/fullscreen_utils.dart';

class PlayInfo extends StatefulWidget {
  final String? animeName;
  final int? animeId;

  const PlayInfo({Key? key, this.animeName, this.animeId}) : super(key: key);

  @override
  State<PlayInfo> createState() => _PlayInfoState();
}

class _PlayInfoState extends State<PlayInfo> {
  // 创建播放器实例（与 VideoPlayer 共享）
  late final player = Player();
  late final controller = VideoController(player);

  // 临时的视频URL常量
  static const String _tempVideoUrl =
      'https://apn.moedot.net/d/wo/2507/%E6%9B%B4%E8%A1%A304z.mp4';

  // 实际的视频URL
  String? _actualVideoUrl;
  bool _isLoadingVideo = true;

  // 全屏状态
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoadingVideo = true;
    });

    try {
      // 使用临时的视频URL
      _actualVideoUrl = _tempVideoUrl;
      await _loadVideo();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频加载失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    }
  }

  Future<void> _loadVideo() async {
    if (_actualVideoUrl == null) return;

    try {
      final media = Media(_actualVideoUrl!);
      await player.open(media);
      await player.setPlaylistMode(PlaylistMode.single);
      await player.setVolume(100.0);

      // 视频加载成功后，确保加载状态为false
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频加载失败: $e'), backgroundColor: Colors.red),
        );
        // 加载失败时也要设置加载状态为false
        setState(() {
          _isLoadingVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // 退出时重置系统UI和方向
    FullscreenUtils.exitFullScreen();
    player.dispose();
    super.dispose();
  }

  // 切换全屏状态
  void _toggleFullscreen() async {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // 进入全屏
      await FullscreenUtils.enterFullScreen();
    } else {
      // 退出全屏
      await FullscreenUtils.exitFullScreen();
    }
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
        child: Stack(
          children: [
            // 正常模式：带完整界面
            Opacity(
              opacity: _isFullscreen ? 0.0 : 1.0,
              child: Column(
                children: [
                  // 视频预览区域
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          child: _isLoadingVideo
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : _actualVideoUrl != null
                              ? VideoPlayer(
                                  videoUrl: _actualVideoUrl!,
                                  showControls: true,
                                  isFullscreen: _isFullscreen,
                                  onToggleFullscreen: _toggleFullscreen,
                                  onBackPressed: () =>
                                      Navigator.of(context).pop(),
                                  player: player,
                                  controller: controller,
                                )
                              : Center(
                                  child: Text(
                                    '视频加载失败',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // 播放信息区域
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题
                            if (widget.animeName != null)
                              Text(
                                widget.animeName!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            const SizedBox(height: 16),

                            // 播放状态信息
                            _buildPlaybackInfo(),

                            const SizedBox(height: 24),

                            // 视频信息
                            _buildVideoInfo(),

                            const SizedBox(height: 24),

                            // 控制选项
                            _buildControlOptions(),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 全屏模式：覆盖整个屏幕
            Opacity(
              opacity: _isFullscreen ? 1.0 : 0.0,
              child: VideoPlayer(
                videoUrl: _actualVideoUrl ?? '',
                title: widget.animeName,
                showControls: true,
                isFullscreen: _isFullscreen,
                onToggleFullscreen: _toggleFullscreen,
                player: player,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackInfo() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '播放状态',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '视频信息',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.animeId != null)
            _buildInfoRow('动漫ID', widget.animeId!.toString()),
          if (widget.animeName != null)
            _buildInfoRow('动漫名称', widget.animeName!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: TextStyle(color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildControlOptions() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '播放控制',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {}
  void _showSpeedDialog() {}
  void _showLoopModeDialog() {}

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}
