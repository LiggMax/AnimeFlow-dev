import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:AnimeFlow/modules/bangumi/data.dart';
import 'anime_head.dart';
import 'detail/detail_info.dart';
import 'anime_comments.dart';

class AnimeDataPage extends StatefulWidget {
  final int animeId;
  final String? animeName;

  const AnimeDataPage({super.key, required this.animeId, this.animeName});

  @override
  State<AnimeDataPage> createState() => _AnimeDataPageState();
}

class _AnimeDataPageState extends State<AnimeDataPage>
    with TickerProviderStateMixin {
  /// 控制器模式
  final InfoController infoController = InfoController();
  late TabController infoTabController;

  // 响应式布局常量
  final double maxWidth = 950.0;

  @override
  void initState() {
    super.initState();
    // 初始化数据 创建空的BangumiDetailData实例
    infoController.bangumiItem = BangumiDetailData(
      id: widget.animeId,
      name: '',
      nameCn: widget.animeName ?? '动漫详情',
      summary: '',
      date: '',
      platform: '',
      images: BangumiImages(
        small: '',
        grid: '',
        large: '',
        medium: '',
        common: '',
      ),
      rating: null,
      collection: null,
      tags: [],
      infobox: [],
      metaTags: [],
      totalEpisodes: 0,
      eps: 0,
      volumes: 0,
      type: 2,
      // 默认为TV动画
      series: false,
      locked: false,
      nsfw: false,
    );

    // 标签页设置
    infoTabController = TabController(length: 2, vsync: this);

    // 加载详情数据
    queryBangumiInfoByID(widget.animeId);
  }

  @override
  void dispose() {
    infoTabController.dispose();
    super.dispose();
  }

  /// 查询方法
  Future<void> queryBangumiInfoByID(int id, {String type = "init"}) async {
    try {
      await infoController.queryBangumiInfoByID(id, type: type);
      setState(() {});
    } catch (e) {
      // 加载动漫数据错误: $e
    }
  }

  @override
  Widget build(BuildContext context) {
    // 标签页配置
    final List<String> tabs = <String>['详情', '讨论'];

    return PopScope(
      canPop: true,
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                      sliver: AnimeDetailAppBar(
                        id: widget.animeId,
                        title: infoController.bangumiItem.displayName.isEmpty
                            ? (widget.animeName ?? '动漫详情')
                            : infoController.bangumiItem.displayName,
                        innerBoxIsScrolled: innerBoxIsScrolled,
                        tabController: infoTabController,
                        tabs: tabs,
                        background: AnimeDetailHeader(
                          bangumiItem: infoController.bangumiItem,
                          isLoading: infoController.isLoading,
                          maxWidth: maxWidth,
                        ),
                      ),
                    ),
                  ];
                },
            body: AnimeInfoTabView(
              tabController: infoTabController,
              bangumiItem: infoController.bangumiItem,
              isLoading: infoController.isLoading,
              maxWidth: maxWidth,
            ),
          ),
        ),
      ),
    );
  }
}

/// 控制器模式
class InfoController {
  late BangumiDetailData bangumiItem;
  bool isLoading = false;

  Future<void> queryBangumiInfoByID(int id, {String type = "init"}) async {
    isLoading = true;
    try {
      final data = await BangumiService.getInfoByID(id);
      if (data != null) {
        bangumiItem = data;
      }
    } finally {
      isLoading = false;
    }
  }
}

/// 标签页视图组件
class AnimeInfoTabView extends StatefulWidget {
  const AnimeInfoTabView({
    super.key,
    required this.tabController,
    required this.bangumiItem,
    required this.isLoading,
    required this.maxWidth,
  });

  final TabController tabController;
  final BangumiDetailData bangumiItem;
  final bool isLoading;
  final double maxWidth;

  @override
  State<AnimeInfoTabView> createState() => _AnimeInfoTabViewState();
}

class _AnimeInfoTabViewState extends State<AnimeInfoTabView>
    with SingleTickerProviderStateMixin {
  bool _isCommentsLoadingMore = false;
  // 使用 GlobalKey 来访问 AnimeCommentsContent 的方法
  final GlobalKey<AnimeCommentsContentState> _commentsKey =
      GlobalKey<AnimeCommentsContentState>();

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: [_buildDetailInfoTab(), _buildCommentsTab()],
    );
  }

  /// 详情标签页
  Widget _buildDetailInfoTab() {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          key: const PageStorageKey<String>('详情'),
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                bottom: false,
                child: _buildDetailInfoContent(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 评论标签页
  Widget _buildCommentsTab() {
    return Builder(
      builder: (BuildContext context) {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // 检查是否滚动到页面底部，触发加载更多
            if (!_isCommentsLoadingMore &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              // 触发加载更多
              _triggerLoadMore();
            }
            return false;
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('评论'),
            // 优化滚动性能
            cacheExtent: 500,
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: AnimeCommentsContent(
                    key: _commentsKey,
                    animeId: widget.bangumiItem.id,
                    onLoadingStateChanged: _onLoadingStateChanged,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 触发加载更多
  void _triggerLoadMore() {
    if (!_isCommentsLoadingMore) {
      // 直接调用 AnimeCommentsContent 的加载更多方法
      _commentsKey.currentState?.loadMoreComments();
    }
  }

  /// 加载状态改变回调
  void _onLoadingStateChanged(bool isLoading) {
    setState(() {
      _isCommentsLoadingMore = isLoading;
    });
  }

  /// 详情内容实现
  Widget _buildDetailInfoContent() {
    return AnimeDetailContent(
      bangumiItem: widget.bangumiItem,
      maxWidth: widget.maxWidth,
    );
  }
}
