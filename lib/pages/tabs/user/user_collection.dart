///@Author Ligg
///@Time 2025/8/30
library;

import 'package:animeFlow/router/router_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animeFlow/modules/bangumi/collections.dart';
import 'package:animeFlow/modules/bangumi/user_info.dart';
import 'package:go_router/go_router.dart';

/// 根据tab名称获取对应的type值
int getTypeFromTabName(String tabName) {
  switch (tabName) {
    case '想看':
      return 1;
    case '看过':
      return 2;
    case '在看':
      return 3;
    case '搁置':
      return 4;
    case '抛弃':
      return 5;
    default:
      return 3; // 默认为"在看"
  }
}

/// 标签页视图组件
class UserCollectionView extends StatefulWidget {
  final TabController tabController;
  final List<String> tabs;
  final UserInfo? userInfo;
  final Map<int, Collections?> collectionsByType;
  final Map<int, bool> loadingStates;
  final Function(int) onTabChanged;
  final Function(int) onRefresh;

  const UserCollectionView({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.userInfo,
    required this.collectionsByType,
    required this.loadingStates,
    required this.onTabChanged,
    required this.onRefresh,
  });

  @override
  State<UserCollectionView> createState() => _UserCollectionViewState();
}

class _UserCollectionViewState extends State<UserCollectionView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: widget.tabs.map((tab) => _buildTabContent(tab)).toList(),
    );
  }

  /// tab标签页内容
  Widget _buildTabContent(String tabName) {
    return Builder(
      builder: (BuildContext context) {
        return RefreshIndicator(
          onRefresh: () async {
            // 获取当前tab的type值
            final int type = getTypeFromTabName(tabName);
            print('🔄 下拉刷新$tabName类型 $type 的数据');

            // 调用父组件的方法刷新数据
            widget.onRefresh(type);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              // 检查是否滚动接近底部
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 100) {
                final int type = getTypeFromTabName(tabName);
                _loadMoreData(type);
                return true;
              }
              return false;
            },
            child: CustomScrollView(
              key: PageStorageKey<String>(tabName),
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
                    child: _buildTabContentList(tabName, widget.userInfo),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 加载更多数据
  void _loadMoreData(int type) {
    final collection = widget.collectionsByType[type];
    final isLoading = widget.loadingStates[type] ?? false;

    // 如果正在加载或没有更多数据则不加载
    if (isLoading ||
        (collection != null &&
            collection.data != null &&
            collection.total != null &&
            collection.data!.length >= collection.total!)) {
      return;
    }

    // 调用父组件方法加载更多数据
    widget.onTabChanged(type);
  }

  /// 标签页列表内容
  Widget _buildTabContentList(String tabName, UserInfo? userInfo) {
    // 根据tab名称确定type值
    int type = getTypeFromTabName(tabName);

    // 获取对应类型的收藏数据
    final Collections? collection = widget.collectionsByType[type];
    final List<Data> items = collection?.data ?? [];

    // 检查是否正在加载
    final bool isLoading = widget.loadingStates[type] == true;

    // 如果正在加载且没有数据，显示加载指示器
    if (isLoading && items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                '未收藏$tabName的动漫',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 2.3,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: items.length + (isLoading ? 1 : 0),
      // 如果正在加载，增加一个加载指示器
      itemBuilder: (context, index) {
        // 如果是最后一个项目且正在加载，显示加载指示器
        if (index == items.length && isLoading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        }

        final item = items[index];
        // 当前项目
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            onTap: () {
              context.pushNamed(
                AppRouter.animeData,
                pathParameters: {'animeId': '${item.id}'},
              );
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 封面图片
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: item.images!.large!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // 内容信息
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 上
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.nameCN?.isNotEmpty == true
                                    ? item.nameCN!
                                    : item.name ?? '未知标题',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (item.rating?.score != null &&
                                item.rating!.score! > 0) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating!.score!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 中
                        Row(
                          children: [
                              Text(
                                '排名: ${item.rating!.rank}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 下
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => {},
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                '播放',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 14,
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
            ),
          ),
        );
      },
    );
  }

  /// 根据屏幕宽度获取列数
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 1;
    } else if (width < 900) {
      return 2;
    } else if (width < 1200) {
      return 3;
    } else {
      return 4;
    }
  }
}
