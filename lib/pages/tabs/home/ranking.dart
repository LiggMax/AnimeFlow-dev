import 'package:AnimeFlow/modules/bangumi/rank.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:AnimeFlow/utils/fullscreen_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:AnimeFlow/router/router_config.dart';
import 'package:lottie/lottie.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  Rank? _rankData;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false; // 控制返回顶部按钮的显示

  @override
  void initState() {
    super.initState();
    _loadRankingData();

    // 添加滚动监听器实现上拉加载更多
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // 检查是否滚动到页面底部
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 触发加载更多
      _loadMoreData();
    }

    // 控制返回顶部按钮的显示
    if (_scrollController.position.pixels > 300) {
      if (!_showBackToTop) {
        setState(() {
          _showBackToTop = true;
        });
      }
    } else {
      if (_showBackToTop) {
        setState(() {
          _showBackToTop = false;
        });
      }
    }
  }

  Future<void> _loadRankingData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await BangumiService.getRank('trends');

      if (mounted) {
        setState(() {
          _rankData = data;
          _isLoading = false;
          _currentPage = 1;
          _hasMore = true; // 重置更多数据状态
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    // 如果正在加载或没有更多数据，则不执行
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final nextPage = _currentPage + 1;
      final data = await BangumiService.getRank('trends',page: nextPage);

      if (mounted) {
        setState(() {
          _isLoadingMore = false;

          if (data == null || data.data == null || data.data!.isEmpty) {
            _hasMore = false; // 没有更多数据
          } else {
            // 追加数据
            final currentData = _rankData?.data ?? [];
            currentData.addAll(data.data!);
            _rankData = Rank(data: currentData, total: _rankData?.total);
            _currentPage = nextPage;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _error = e.toString();
        });
      }
    }
  }

  // 返回顶部方法
  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loadAnime.json',
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '加载失败: $_error',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRankingData,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    final dataList = _rankData?.data ?? [];

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // 检查是否滚动到页面底部
            if (!_isLoadingMore &&
                _hasMore &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              _loadMoreData();
              return true;
            }
            return false;
          },
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: FullscreenUtils.getCrossAxisCount(context),
              childAspectRatio: 0.7,
              crossAxisSpacing: 2,
            ),
            itemCount: dataList.length + (_hasMore ? 1 : 0),
            // 添加加载更多指示器
            itemBuilder: (context, index) {
              // 如果是最后一个item且正在加载更多，显示加载指示器
              if (_hasMore && index == dataList.length) {
                return _buildLoadingMoreIndicator();
              }

              final dataItem = dataList[index];
              return _buildRankItem(
                title: dataItem.nameCN ?? dataItem.name ?? '',
                coverUrl: dataItem.images!.bestUrl!,
                link: dataItem.id?.toInt() ?? 0,
              );
            },
          ),
        ),
        // 返回顶部按钮
        if (_showBackToTop)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.keyboard_arrow_up, size: 33),
            ),
          ),
      ],
    );
  }

  // 加载更多指示器
  Widget _buildLoadingMoreIndicator() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildRankItem({
    required String title,
    required String coverUrl,
    required int link,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 跳转到详情页面
          context.pushNamed(
            AppRouter.animeData,
            pathParameters: {'animeId': '$link'},
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面图片
            _buildCoverImage(coverUrl),

            // 底部蒙版和标题
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String coverUrl) {
    if (coverUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }

    return CachedNetworkImage(
      imageUrl: coverUrl,
      fit: BoxFit.cover,
      errorWidget: (context, error, stackTrace){
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        );
      },
    );
  }
}
