import 'package:AnimeFlow/router/router_config.dart';
import 'package:AnimeFlow/utils/fullscreen_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:AnimeFlow/utils/theme_extensions.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:AnimeFlow/modules/bangumi/search_data.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchHistory = [];
  SearchData? _searchData;
  bool _isSearching = false;
  String _currentQuery = '';
  bool _isGridView = false; // 布局切换状态：false为列表布局，true为网格布局

  // 动画控制器
  late AnimationController _layoutAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);

    // 初始化动画控制器
    _layoutAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _layoutAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _layoutAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // 启动初始动画
    _layoutAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _layoutAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('search_history');
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        setState(() {
          _searchHistory = historyList.cast<String>();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('加载搜索历史失败: $e');
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchData = null;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final result = await BangumiService.search(query);
      if (mounted && _currentQuery == query) {
        setState(() {
          _isSearching = false;
          if (result != null) {
            _searchData = result;
          } else {
            _searchData = null;
          }
        });
      }
    } catch (e) {
      if (mounted && _currentQuery == query) {
        setState(() {
          _isSearching = false;
          _searchData = null;
        });
      }
      if (kDebugMode) {
        print('搜索失败: $e');
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _addToHistory(query.trim()); // 异步调用，
      _performSearch(query.trim());
    }
  }

  Future<void> _addToHistory(String query) async {
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });

      // 保存到本地存储
      await _saveSearchHistory();
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_searchHistory);
      await prefs.setString('search_history', historyJson);
    } catch (e) {
      print('保存搜索历史失败: $e');
    }
  }

  Future<void> _clearHistory() async {
    setState(() {
      _searchHistory.clear();
    });

    // 清除本地存储
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
    } catch (e) {
      print('清除搜索历史失败: $e');
    }
  }

  // 布局切换动画方法
  void _toggleLayout() async {
    // 先执行淡出动画
    await _layoutAnimationController.reverse();

    // 切换布局状态
    setState(() {
      _isGridView = !_isGridView;
    });

    // 执行淡入动画
    _layoutAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索'), centerTitle: true),
      body: Column(
        children: [
          // 搜索框
          _buildSearchBar(),

          // 搜索内容
          Expanded(child: _buildSearchContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '搜索动漫...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocusNode.requestFocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: _onSearchSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchContent() {
    if (_searchController.text.isEmpty) {
      return _buildSearchHistory();
    } else {
      return _buildSearchResults();
    }
  }

  Widget _buildSearchHistory() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: _clearHistory, child: const Text('清空')),
            ],
          ),
          ..._searchHistory.map((history) => _buildHistoryItem(history)),
        ],

        // 热门搜索
        Text(
          '热门搜索',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            '进击的巨人',
            '鬼灭之刃',
            '咒术回战',
            '间谍过家家',
            '海贼王',
            '火影忍者',
            '死神',
            '龙珠',
          ].map((tag) => _buildHotSearchTag(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('搜索中...'),
          ],
        ),
      );
    }

    if (_searchData == null || _searchData!.data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '没有找到相关结果',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 搜索结果统计和操作按钮
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Text(
                '找到 ${_searchData!.total} 个结果',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const Spacer(),
              // 布局切换按钮
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                onPressed: _toggleLayout,
              ),
              // 排序按钮
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  _sortResults(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'score', child: Text('按评分排序')),
                  const PopupMenuItem(value: 'date', child: Text('按日期排序')),
                  const PopupMenuItem(
                    value: 'collection',
                    child: Text('按收藏数排序'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 搜索结果列表
        Expanded(
          child: AnimatedBuilder(
            animation: _layoutAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _isGridView ? _buildGridView() : _buildListView(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      itemCount: _searchData!.data.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchData!.data[index]);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: FullscreenUtils.getCrossAxisCount(context),
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: _searchData!.data.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_searchData!.data[index]);
      },
    );
  }

  Widget _buildGridItem(SearchAnimeItem anime) {
    return GestureDetector(
      onTap: () => _onAnimeTap(anime),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // 封面图片
              Positioned.fill(
                child: anime.coverImage.isNotEmpty
                    ? Image.network(
                        anime.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              // 底部渐变背景和标题
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
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    anime.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
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
      ),
    );
  }

  void _sortResults(String sortType) {
    if (_searchData == null) return;

    setState(() {
      switch (sortType) {
        case 'score':
          _searchData!.data.sort((a, b) => b.score.compareTo(a.score));
          break;
        case 'date':
          _searchData!.data.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return b.date!.compareTo(a.date!);
          });
          break;
        case 'collection':
          _searchData!.data.sort(
            (a, b) => b.collection.collect.compareTo(a.collection.collect),
          );
          break;
      }
    });
  }

  Widget _buildHistoryItem(String history) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(history),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _searchController.text = history;
        _onSearchSubmitted(history);
      },
    );
  }

  Widget _buildHotSearchTag(String tag) {
    return ActionChip(
      label: Text(tag),
      onPressed: () {
        _searchController.text = tag;
        _onSearchSubmitted(tag);
      },
      backgroundColor: context.isDarkMode ? Colors.grey[700] : Colors.grey[200],
    );
  }

  Widget _buildSearchResultItem(SearchAnimeItem anime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onAnimeTap(anime),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧封面图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: anime.coverImage.isNotEmpty
                    ? Image.network(
                        anime.coverImage,
                        width: 110,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 110,
                            height: 160,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 110,
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),

              const SizedBox(width: 12),

              // 右侧信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      anime.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 基本信息
                    Row(
                      children: [
                        if (anime.date != null && anime.date!.isNotEmpty) ...[
                          Text(
                            anime.date!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (anime.eps > 0) ...[
                          Text(
                            '全${anime.eps}话',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // 标签信息
                    if (anime.tags.isNotEmpty) ...[
                      Text(
                        anime.tags.take(3).map((tag) => tag.name).join('/'),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // 制作信息
                    if (anime.infobox.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final director = anime.infobox.firstWhere(
                            (box) => box.key == '导演' || box.key == '监督',
                            orElse: () => AnimeInfoBox(key: '', value: ''),
                          );
                          if (director.key.isNotEmpty) {
                            return Text(
                              '制作: ${director.valueString}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],

                    // 评分信息
                    Row(
                      children: [
                        if (anime.score > 0) ...[
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            anime.score.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '#${anime.rating.rank}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${anime.rating.total}人评',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 搜索结果跳转
  void _onAnimeTap(SearchAnimeItem anime) {
    context.pushNamed(
      AppRouter.animeData,
      pathParameters: {'animeId': anime.id.toString()},
    );
  }
}
