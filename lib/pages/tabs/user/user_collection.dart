///@Author Ligg
///@Time 2025/8/30
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/collections.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';

/// 根据tab名称获取对应的type值
int getTypeFromTabName(String tabName) {
  switch (tabName) {
    case '想看':
      return 1;
    case '在看':
      return 2;
    case '看过':
      return 3;
    case '搁置':
      return 4;
    case '抛弃':
      return 5;
    default:
      return 2; // 默认为"在看"
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
  final Function(int) onRefresh; // 添加刷新回调

  const UserCollectionView({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.userInfo,
    required this.collectionsByType,
    required this.loadingStates,
    required this.onTabChanged,
    required this.onRefresh, // 添加刷新回调
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

  /// 构建tab标签页内容
  Widget _buildTabContent(String tabName) {
    return Builder(
      builder: (BuildContext context) {
        return RefreshIndicator(
          onRefresh: () async {
            // 获取当前tab的type值
            final int type = getTypeFromTabName(tabName);
            print('🔄 下拉刷新类型 $type 的数据');

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

  /// 构建标签页列表内容
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
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '正在加载$tabName的动漫...',
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
                '暂无$tabName的动漫',
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: item.images?.large?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        item.images!.large!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.movie,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.movie,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
            title: Text(
              item.nameCN?.isNotEmpty == true
                  ? item.nameCN!
                  : item.name ?? '未知标题',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.info?.isNotEmpty == true)
                  Text(
                    item.info!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item.rating?.score != null && item.rating!.score! > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating!.score!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    if (item.rating?.score != null &&
                        item.rating!.score! > 0 &&
                        item.rating?.rank != null)
                      const SizedBox(width: 16),
                    if (item.rating?.rank != null && item.rating!.rank! > 0)
                      Text(
                        '排名: ${item.rating!.rank}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
