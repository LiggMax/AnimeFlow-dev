import 'dart:async';
import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:go_router/go_router.dart';

import '../../utils/fullscreen_utils.dart';

// 数据状态类
class CalendarState {
  final Map<String, dynamic>? data;
  final bool isLoading;

  CalendarState({this.data, this.isLoading = false});
}

// 数据提供者类
class CalendarProvider {
  final _stateController = StreamController<CalendarState>();

  Stream<CalendarState> get stateStream => _stateController.stream;

  // 静态缓存
  static Map<String, dynamic>? _cachedData;
  static DateTime? _cacheTime;
  static const Duration _cacheExpiration = Duration(minutes: 3); // 缓存时间

  CalendarProvider() {
    // 检查是否有有效缓存
    if (_hasValidCache()) {
      _stateController.add(CalendarState(data: _cachedData, isLoading: false));
    } else {
      _stateController.add(CalendarState(isLoading: true));
      loadCalendar();
    }
  }

  // 检查缓存是否有效
  bool _hasValidCache() {
    return _cachedData != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheExpiration;
  }

  Future<void> loadCalendar({bool forceRefresh = false}) async {
    // 如果不是强制刷新且有有效缓存，直接返回缓存数据
    if (!forceRefresh && _hasValidCache()) {
      _stateController.add(CalendarState(data: _cachedData, isLoading: false));
      return;
    }

    _stateController.add(CalendarState(isLoading: true));

    try {
      final data = await BangumiService.getCalendar();
      // 更新缓存
      _cachedData = data;
      _cacheTime = DateTime.now();

      _stateController.add(CalendarState(data: data, isLoading: false));
    } catch (e) {
      _stateController.add(CalendarState(isLoading: false));
    }
  }

  // 强制刷新数据
  Future<void> refreshCalendar() async {
    await loadCalendar(forceRefresh: true);
  }

  // 清除缓存
  static void clearCache() {
    _cachedData = null;
    _cacheTime = null;
  }

  void dispose() {
    _stateController.close();
  }
}

// 动漫卡片组件
class AnimeCard extends StatelessWidget {
  final dynamic animeData;
  final Function(int id)? onTap; // 添加点击回调

  const AnimeCard({super.key, required this.animeData, this.onTap});

  @override
  Widget build(BuildContext context) {
    final subject = animeData['subject'];
    final id = subject['id'] as int;
    final name = subject['nameCN']?.isNotEmpty == true
        ? subject['nameCN']
        : subject['name'];
    final imageUrl = subject['images']?['large'] ?? '';

    return GestureDetector(
      onTap: () => onTap?.call(id), // 点击时传递 id
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // 确保内容不会超出圆角
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 封面图片
            _buildImage(imageUrl),
            // 底部渐变蒙版和标题
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black26,
                      Colors.black45,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name ?? '未知动漫',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 255, 255, 0.8),
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.movie, size: 30, color: Colors.grey),
    );
  }
}

// 星期动漫网格组件
class WeeklyAnimeGrid extends StatefulWidget {
  final Map<String, dynamic> calendarData;
  final VoidCallback? onRefresh;

  const WeeklyAnimeGrid({
    super.key,
    required this.calendarData,
    this.onRefresh,
  });

  @override
  State<WeeklyAnimeGrid> createState() => _WeeklyAnimeGridState();
}

class _WeeklyAnimeGridState extends State<WeeklyAnimeGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 keep alive
    //获取当前星期(1-7）并计算 Tab 的初始索引（0-6）
    final todayWeekday = DateTime.now().weekday;
    final initialIndex = todayWeekday - 1; // weekday 1 对应 index 0

    return DefaultTabController(
      initialIndex: initialIndex, // 设置初始索引
      length: 7,
      child: Column(
        children: [
          // 星期标签栏
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _buildWeekTabs(),
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // 星期内容
          Expanded(child: TabBarView(children: _buildWeekViews())),
        ],
      ),
    );
  }

  List<Widget> _buildWeekTabs() {
    const weekNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekNames.asMap().entries.map((entry) {
      final dayIndex = entry.key + 1; // 1-7
      final dayName = entry.value;
      final animeCount = widget.calendarData[dayIndex.toString()]?.length ?? 0;

      return Tab(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dayName),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              child: Text('$animeCount', style: const TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildWeekViews() {
    return List.generate(7, (index) {
      final dayIndex = index + 1; // 1-7
      final dayAnimes =
          widget.calendarData[dayIndex.toString()] as List<dynamic>? ?? [];

      if (dayAnimes.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async =>
              widget.onRefresh != null ? widget.onRefresh!() : Future.value(),
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tv_off, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '今天没有新番',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '下拉刷新试试',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async =>
            widget.onRefresh != null ? widget.onRefresh!() : Future.value(),
        child: AnimeGrid(
          key: ValueKey('day_$dayIndex'), // 添加唯一key
          animes: dayAnimes,
        ),
      );
    });
  }
}

// 单日动漫网格组件
class AnimeGrid extends StatelessWidget {
  final List<dynamic> animes;

  const AnimeGrid({super.key, required this.animes});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(5),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: FullscreenUtils.getCrossAxisCount(context),
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final animeData = animes[index];
              final subject = animeData['subject'];
              final id = subject['id'] as int;
              final animeName = subject['nameCN']?.isNotEmpty == true
                  ? subject['nameCN']
                  : subject['name'];
              final imageUrl = subject['images']?['large'];

              return AnimeCard(
                key: ValueKey('anime_$id'), // 添加唯一key
                animeData: animeData,
                onTap: (id) {
                  context.pushNamed(
                    'anime_data',
                    pathParameters: {'animeId': '$id'},
                    extra: {
                      'animeName': animeName,
                      'imageUrl': imageUrl,
                    },
                  );
                },
              );
            }, childCount: animes.length),
          ),
        ),
      ],
    );
  }
}

// 主页面组件
class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage>
    with AutomaticKeepAliveClientMixin {
  late CalendarProvider _calendarProvider;

  @override
  void initState() {
    super.initState();
    _calendarProvider = CalendarProvider();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以支持 keep alive
    return Scaffold(
      appBar: AppBar(
        title: const Text('时间表'),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<CalendarState>(
        stream: _calendarProvider.stateStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data!;
            return _buildContent(state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildContent(CalendarState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.data != null) {
      return WeeklyAnimeGrid(
        calendarData: state.data!,
        onRefresh: () => _calendarProvider.refreshCalendar(),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () => _calendarProvider.refreshCalendar(),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: Center(child: Text("加载数据失败，下拉重试")),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _calendarProvider.dispose();
    super.dispose();
  }
}
