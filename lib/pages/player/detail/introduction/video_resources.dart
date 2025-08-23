import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/video/video_service.dart';

class Resources extends StatefulWidget {
  final String? animeName;
  final int? episodeNumber;
  final VoidCallback? onTap;
  final Function(String)? onVideoUrlReceived; // URL回调

  const Resources({
    super.key,
    this.onTap,
    this.animeName,
    this.episodeNumber,
    this.onVideoUrlReceived,
  });

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  bool _isAutoSelecting = true;
  List<Map<String, dynamic>> _episodes = [];
  int _selectedSourceIndex = 0; // 选中的数据源索引
  int _selectedRouteIndex = 0; // 选中的线路索引
  int _selectedEpisodeIndex = 0; // 选中的剧集索引

  ///获取剧集列表
  Future<void> _getEpisodes() async {
    final response = await VideoService.getEpisodeSource(
      widget.animeName ?? '败犬女主',
      widget.episodeNumber ?? 1,
    );
    setState(() {
      _episodes = response ?? [];
      _isAutoSelecting = false;
    });
  }

  ///获取视频源Url
  Future<String?> _getPlayUrl(String url) async {
    final playUrl = await VideoService.getPlayUrl(url);
    return playUrl;
  }

  //抽屉弹窗
  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // 标题
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.video_library,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '选择播放源',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 数据源选择
                      if (_episodes.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '数据源',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _episodes.length,
                                  itemBuilder: (context, index) {
                                    final source = _episodes[index];
                                    final isSelected =
                                        _selectedSourceIndex == index;
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(
                                          source['title'] ?? '未知源',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                          ),
                                        ),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setModalState(() {
                                            _selectedSourceIndex = index;
                                            _selectedRouteIndex = 0;
                                            _selectedEpisodeIndex = 0;
                                          });
                                        },
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        selectedColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 线路选择
                        if (_episodes[_selectedSourceIndex]['routes'] !=
                            null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '线路',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        (_episodes[_selectedSourceIndex]['routes']
                                                as List)
                                            .length,
                                    itemBuilder: (context, index) {
                                      final route =
                                          _episodes[_selectedSourceIndex]['routes'][index];
                                      final isSelected =
                                          _selectedRouteIndex == index;
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          label: Text(
                                            route['name'] ?? '未知线路',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                            ),
                                          ),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setModalState(() {
                                              _selectedRouteIndex = index;
                                              _selectedEpisodeIndex = 0;
                                            });
                                          },
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                          selectedColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],

                        // 剧集列表
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '剧集',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: _buildEpisodeList(setModalState),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 底部按钮
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('取消'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _selectedEpisode();
                                    Navigator.pop(context);
                                  },
                                  child: Text('播放'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // 无数据时的显示
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无可用播放源',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// 构建剧集列表
  Widget _buildEpisodeList([StateSetter? setModalState]) {
    if (_episodes.isEmpty) return const SizedBox.shrink();

    final selectedSource = _episodes[_selectedSourceIndex];
    final routes = selectedSource['routes'] as List?;
    final episodes = selectedSource['episodes'] as List?;

    if (routes == null ||
        episodes == null ||
        routes.isEmpty ||
        episodes.isEmpty) {
      return Center(
        child: Text(
          '暂无剧集数据',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    if (_selectedRouteIndex >= routes.length ||
        _selectedRouteIndex >= episodes.length) {
      return Center(
        child: Text(
          '线路数据异常',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    final routeEpisodes = episodes[_selectedRouteIndex] as List;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: routeEpisodes.length,
      itemBuilder: (context, index) {
        final episode = routeEpisodes[index];
        final isSelected = _selectedEpisodeIndex == index;

        return GestureDetector(
          onTap: () {
            if (setModalState != null) {
              setModalState(() {
                _selectedEpisodeIndex = index;
              });
            } else {
              setState(() {
                _selectedEpisodeIndex = index;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected
                        ? Icons.play_circle_filled
                        : Icons.play_circle_outline,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode['episode'] ?? '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 选中的剧集
  /// 传递选中的播放剧集链接获取实际的播放地址
  void _selectedEpisode() async {
    if (_episodes.isEmpty) return;

    final selectedSource = _episodes[_selectedSourceIndex];
    final routes = selectedSource['routes'] as List?;
    final episodes = selectedSource['episodes'] as List?;

    if (routes == null ||
        episodes == null ||
        _selectedRouteIndex >= routes.length ||
        _selectedRouteIndex >= episodes.length) {
      return;
    }

    final routeEpisodes = episodes[_selectedRouteIndex] as List;
    if (_selectedEpisodeIndex >= routeEpisodes.length) return;

    final episode = routeEpisodes[_selectedEpisodeIndex];
    final episodeUrl = episode['url'];

    if (episodeUrl != null && episodeUrl.isNotEmpty) {
      final playUrl = await _getPlayUrl(episodeUrl);
      if (playUrl != null && widget.onVideoUrlReceived != null) {
        // 调用回调函数，将播放URL传递给父组件
        widget.onVideoUrlReceived!(playUrl);

        // 显示提示信息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '已选择播放源: ${episode['title'] ?? '第${episode['episode']}集'}',
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '资源',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _isAutoSelecting
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(),
                          )
                        : Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 25,
                          ),
                    const SizedBox(width: 8),
                    Text(
                      _isAutoSelecting ? '正在自动选择' : '已选择数据源',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showDrawer(context);
                      },
                      icon: Icon(
                        Icons.repeat,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        '手动选择',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
