import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/video/video_service.dart';
import 'package:AnimeFlow/modules/video/episode_source.dart';
import 'package:lottie/lottie.dart';

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
  EpisodeSourceList? _episodeSourceList;
  int _selectedSourceIndex = 0; // 选中的数据源索引
  int _selectedRouteIndex = 0; // 选中的线路索引
  int _selectedEpisodeIndex = 0; // 选中的剧集索引

  ///获取剧集列表
  Future<void> _getEpisodes() async {
    if (widget.episodeNumber != null) {
      print('接收到的剧集编号${widget.episodeNumber}');
      final response = await VideoService.getEpisodeSource(
        widget.animeName ?? '',
      );
      setState(() {
        _episodeSourceList = response;
        _isAutoSelecting = false;
      });
      _autoSelectEpisode();
    }
  }

  void _autoSelectEpisode() {
    if (_episodeSourceList?.hasValidData == true &&
        widget.episodeNumber != null) {
      final episodeNumber = widget.episodeNumber!;

      // 遍历所有数据源
      for (
        int sourceIndex = 0;
        sourceIndex < _episodeSourceList!.sources.length;
        sourceIndex++
      ) {
        final source = _episodeSourceList!.sources[sourceIndex];

        // 遍历所有线路
        for (
          int routeIndex = 0;
          routeIndex < source.routes.length;
          routeIndex++
        ) {
          if (routeIndex < source.episodes.length) {
            final episodes = source.episodes[routeIndex];

            // 查找匹配的剧集
            for (
              int episodeIndex = 0;
              episodeIndex < episodes.length;
              episodeIndex++
            ) {
              final episode = episodes[episodeIndex];
              // 比较episode.number和episodeNumber，episode.number中个位数是0开头补全
              if (int.tryParse(episode.number) == episodeNumber ||
                  episode.number == episodeNumber.toString().padLeft(2, '0') ||
                  episode.number == episodeNumber.toString().padLeft(3, '0')) {
                setState(() {
                  _selectedSourceIndex = sourceIndex;
                  _selectedRouteIndex = routeIndex;
                  _selectedEpisodeIndex = episodeIndex;
                });

                // 自动播放选中的剧集
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _selectedEpisode();
                });

                return;
              }
            }
          }
        }
      }
    }
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
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.95,
              expand: false,
              snap: true,
              snapSizes: const [0.3, 0.6, 0.95],
              builder:
                  (BuildContext context, ScrollController scrollController) {
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 数据源选择
                          if (_episodeSourceList?.hasValidData == true) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                      itemCount:
                                          _episodeSourceList?.sourceCount ?? 0,
                                      itemBuilder: (context, index) {
                                        final source =
                                            _episodeSourceList!.sources[index];
                                        final isSelected =
                                            _selectedSourceIndex == index;
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: ChoiceChip(
                                            label: Text(
                                              source.title.isNotEmpty
                                                  ? source.title
                                                  : '未知源',
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
                                              });
                                            },
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
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
                            if (_episodeSourceList != null &&
                                _selectedSourceIndex <
                                    _episodeSourceList!.sourceCount &&
                                _episodeSourceList!
                                    .sources[_selectedSourceIndex]
                                    .routes
                                    .isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                        itemCount: _episodeSourceList!
                                            .sources[_selectedSourceIndex]
                                            .routes
                                            .length,
                                        itemBuilder: (context, index) {
                                          final route = _episodeSourceList!
                                              .sources[_selectedSourceIndex]
                                              .routes[index];
                                          final isSelected =
                                              _selectedRouteIndex == index;
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: ChoiceChip(
                                              label: Text(
                                                route.displayName,
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
                                                });
                                              },
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
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
                              const SizedBox(height: 10),
                            ],

                            // 剧集列表
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                      child: SingleChildScrollView(
                                        controller: scrollController,
                                        physics: const ClampingScrollPhysics(),
                                        child: _buildEpisodeList(setModalState),
                                      ),
                                    ),
                                  ],
                                ),
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
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
    if (_episodeSourceList?.hasValidData != true) {
      return const SizedBox.shrink();
    }

    final selectedSource = _episodeSourceList!.sources[_selectedSourceIndex];
    final routes = selectedSource.routes;
    final episodes = selectedSource.episodes;

    if (routes.isEmpty || episodes.isEmpty) {
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

    final routeEpisodes = episodes[_selectedRouteIndex];

    return Column(
      children: [
        ...List.generate(routeEpisodes.length, (index) {
          final episode = routeEpisodes[index];
          final isSelected = _selectedEpisodeIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
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
                  // 直接播放选中的剧集并关闭抽屉
                  _selectedEpisode();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 播放图标
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.play_circle_filled
                              : Icons.play_circle_outline,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 剧集信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              episode.number,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          //选中动画
                          child: Lottie.asset(
                            'assets/animations/playAnime.json',
                            height: 33,
                            width: 38,
                            //替换动画颜色
                            delegates: LottieDelegates(
                              values: [
                                ValueDelegate.color(
                                  const ['**'],
                                  value: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 选中的剧集
  /// 传递选中的播放剧集链接获取实际的播放地址
  void _selectedEpisode() async {
    if (_episodeSourceList?.hasValidData != true) return;

    final selectedSource = _episodeSourceList!.sources[_selectedSourceIndex];
    final routes = selectedSource.routes;
    final episodes = selectedSource.episodes;

    if (routes.isEmpty ||
        episodes.isEmpty ||
        _selectedRouteIndex >= routes.length ||
        _selectedRouteIndex >= episodes.length) {
      return;
    }

    final routeEpisodes = episodes[_selectedRouteIndex];
    if (_selectedEpisodeIndex >= routeEpisodes.length) return;

    final episode = routeEpisodes[_selectedEpisodeIndex];
    final episodeUrl = episode.url;

    if (episodeUrl.isNotEmpty) {
      final playUrl = await _getPlayUrl(episodeUrl);
      if (playUrl != null && widget.onVideoUrlReceived != null) {
        // 调用回调函数，将播放URL传递给父组件
        widget.onVideoUrlReceived!(playUrl);
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
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '资源',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
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
                  ],
                ),
                // 显示选中的剧集信息
                if (!_isAutoSelecting &&
                    _episodeSourceList?.hasValidData == true &&
                    _episodeSourceList!.sources.length > _selectedSourceIndex &&
                    _episodeSourceList!
                            .sources[_selectedSourceIndex]
                            .episodes
                            .length >
                        _selectedRouteIndex &&
                    _episodeSourceList!
                            .sources[_selectedSourceIndex]
                            .episodes[_selectedRouteIndex]
                            .length >
                        _selectedEpisodeIndex)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '当前选中: 第${_episodeSourceList!.sources[_selectedSourceIndex].episodes[_selectedRouteIndex][_selectedEpisodeIndex].number}集',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
