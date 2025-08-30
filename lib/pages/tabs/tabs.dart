import 'package:flutter/material.dart';
import 'home/home.dart';
import 'user/profile.dart';
import 'time/time.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  // 用于跟踪已访问的页面
  final List<bool> _visited = [false, false, false];

  // 页面标题列表
  final List<String> _pageTitles = ["首页", "时间表", "个人中心"];

  // 使用GlobalKey保持页面状态，实现懒加载
  final List<GlobalKey> _pageKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  @override
  void initState() {
    super.initState();
    // 标记首页为已访问
    _visited[0] = true;
  }

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
      // 标记页面为已访问
      if (!_visited[index]) {
        _visited[index] = true;
      }
    });
  }

  // 懒加载页面组件
  Widget _buildPage(int index) {
    // 只有页面已被访问才创建实例
    if (_visited[index]) {
      switch (index) {
        case 0:
          return HomePage(key: _pageKeys[0]);
        case 1:
          return TimePage(key: _pageKeys[1]);
        case 2:
          return ProfilePage(key: _pageKeys[2]);
        default:
          return Container();
      }
    }
    // 未访问的页面返回空容器
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = orientation == Orientation.landscape;
    final isWideScreen = screenWidth > 800; // 宽屏判断阈值
    final shouldUseSideNavigation = isLandscape || isWideScreen;

    return Scaffold(
      body: Row(
        children: [
          // 左侧导航栏
          if (shouldUseSideNavigation) _buildSideNavigationRail(theme),
          // 主内容区域
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [_buildPage(0), _buildPage(1), _buildPage(2)],
            ),
          ),
        ],
      ),
      bottomNavigationBar: shouldUseSideNavigation
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateTo,
              backgroundColor: theme.colorScheme.surfaceDim,
              indicatorColor: theme.colorScheme.primaryContainer,
              destinations: _buildNavigationDestinations(),
            ),
    );
  }

  /// 侧边导航栏
  Widget _buildSideNavigationRail(ThemeData theme) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: _navigateTo,
      backgroundColor: theme.colorScheme.surfaceDim,
      indicatorColor: theme.colorScheme.primaryContainer,
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      // 将导航项对齐
      groupAlignment: 1.0,
      // -1.0 表示顶部对齐，1.0 表示底部部对齐，0.0 表示居中
      // 添加底部间距
      trailing: const SizedBox(height: 32),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
          label: Text(_pageTitles[0]),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.timeline_outlined),
          selectedIcon: Icon(
            Icons.timeline,
            color: Theme.of(context).primaryColor,
          ),
          label: Text(_pageTitles[1]),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
          label: Text(_pageTitles[2]),
        ),
      ],
    );
  }

  /// 导航项
  List<NavigationDestination> _buildNavigationDestinations() {
    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
        label: _pageTitles[0],
      ),
      NavigationDestination(
        icon: const Icon(Icons.timeline_outlined),
        selectedIcon: Icon(
          Icons.timeline,
          color: Theme.of(context).primaryColor,
        ),
        label: _pageTitles[1],
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
        label: _pageTitles[2],
      ),
    ];
  }
}
