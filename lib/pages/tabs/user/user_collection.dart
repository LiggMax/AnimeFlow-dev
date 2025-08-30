///@Author Ligg
///@Time 2025/8/30
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/collections.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';

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
        );
      },
    );
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

    // 如果正在加载，显示加载指示器
    if (isLoading) {
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
                    Theme
                        .of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '正在加载$tabName的动漫...',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onSurfaceVariant,
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
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无$tabName的动漫',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 使用GridView.builder渲染内容
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图片 - 占据左侧3分之一
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
                      )
                  ),
                ),
              ),

              // 内容信息 - 占据右侧3分之二
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        item.nameCN?.isNotEmpty == true
                            ? item.nameCN!
                            : item.name ?? '未知标题',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 评分和排名
                      Row(
                        children: [
                          if (item.rating?.score != null &&
                              item.rating!.score! > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.rating!.score!.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme
                                        .of(
                                      context,
                                    )
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ],
                            ),

                          if (item.rating?.score != null &&
                              item.rating!.score! > 0 &&
                              item.rating?.rank != null)
                            const SizedBox(width: 8),

                          if (item.rating?.rank != null &&
                              item.rating!.rank! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                '排名: ${item.rating!.rank}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Theme
                                      .of(
                                    context,
                                  )
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => {},
                            style: TextButton.styleFrom(
                              backgroundColor: Theme
                                  .of(
                                context,
                              )
                                  .colorScheme
                                  .primary,
                            ),
                            child: Text(
                              '播放',
                              style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onPrimary,
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
        );
      },
    );
  }

  /// 根据屏幕宽度获取列数
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;
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
