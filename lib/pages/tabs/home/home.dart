import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../router/router_config.dart';
import 'recommend.dart';
import 'ranking.dart';
import 'package:provider/provider.dart';
import '../../../controllers/theme_controller.dart';
import '../../../utils/theme_extensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () => context.pushNamed(AppRouter.search),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              await Provider.of<ThemeController>(
                context,
                listen: false,
              ).toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TabBar 导航
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '推荐'),
                Tab(text: '排行榜'),
              ],
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // TabBarView 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [RecommendPage(), RankingPage()],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
