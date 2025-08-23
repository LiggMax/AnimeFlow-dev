import 'package:flutter/material.dart';
import 'tabs/home/home.dart';
import 'tabs/user/profile.dart';
import './tabs/time.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  // 用于跟踪已访问的页面
  final List<bool> _visited = [false, false, false];

  // 页面标题列表（用于底部导航标签）
  final List<String> _pageTitles = ["首页", "时间表", "个人中心"];

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
    // 如果页面已被访问或当前正在显示，则构建页面
    if (_visited[index] || _currentIndex == index) {
      switch (index) {
        case 0:
          return HomePage();
        case 1:
          return TimePage();
        case 2:
          return ProfilePage();
        default:
          return Container();
      }
    }
    // 否则返回空容器
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    // 确保当前页面被标记为已访问
    if (!_visited[_currentIndex]) {
      _visited[_currentIndex] = true;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPage(0),
          _buildPage(1),
          _buildPage(2),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateTo,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home,color: Theme.of(context).colorScheme.primary),
            label: _pageTitles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline,color: Theme.of(context).colorScheme.primary),
            label: _pageTitles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person,color: Theme.of(context).colorScheme.primary),
            label: _pageTitles[2],
          ),
        ],
      ),
    );
  }
}
