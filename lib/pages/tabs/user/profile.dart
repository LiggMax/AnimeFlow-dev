import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:AnimeFlow/pages/tabs/user/header.dart';
import 'package:AnimeFlow/pages/tabs/user/no_login.dart';
import 'package:AnimeFlow/modules/bangumi/user_collection.dart';

import 'collection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  BangumiToken? _persistedToken;
  UserInfo? _userInfo;
  final Map<int, UserCollection> _collections = {};
  bool _isLoadingCollections = false;

  late TabController _tabController;
  List<Map<String, dynamic>> _tabs = const [];

  // 吸附相关
  final GlobalKey _tabBarKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedToken();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    if (mounted && _tabs.isNotEmpty) {
      _tabController.dispose();
    }
    super.dispose();
  }

  void _initTabs() {
    if (_userInfo == null) return;
    _tabs = _userInfo!.collectionItems;
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  void _onScroll() {
    final ctx = _tabBarKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final threshold = MediaQuery.of(context).padding.top + kToolbarHeight;
    final shouldPin = top <= threshold;
    if (shouldPin != _pinned) {
      setState(() => _pinned = shouldPin);
    }
  }

  /// 加载持久化的Token
  Future<void> _loadPersistedToken() async {
    final token = await OAuthCallbackHandler.getPersistedToken();
    if (mounted) {
      setState(() {
        _persistedToken = token;
      });

      // 如果有Token，获取用户信息
      if (_persistedToken != null) {
        await _loadUserInfo();
        _initTabs();
        _loadUserCollections();
      }
    }
  }

  /// 获取用户信息
  Future<void> _loadUserInfo() async {
    if (_persistedToken == null) return;

    try {
      // 使用Token中的userId获取用户信息
      final userInfo = await BangumiUser.getUserinfo(
        _persistedToken!.userId.toString(),
        token: _persistedToken!.accessToken,
      );

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取用户信息失败: $e')));
      }
    }
  }

  /// 获取用户收藏（想看1、在看2、看过3、搁置4、抛弃5）
  Future<void> _loadUserCollections() async {
    if (_persistedToken == null) return;
    setState(() => _isLoadingCollections = true);
    try {
      final types = [1, 2, 3, 4, 5];
      for (final t in types) {
        final col = await BangumiUser.getUserCollection(
          _persistedToken!,
          t,
          subjectType: 2,
          offset: 0,
        );
        if (!mounted) return;
        setState(() {
          if (col != null) _collections[t] = col;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取收藏失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingCollections = false);
    }
  }

  /// 接收子组件授权完成后的 Token
  Future<void> _onAuthorized(BangumiToken token) async {
    if (!mounted) return;
    setState(() {
      _persistedToken = token;
    });
    await _loadUserInfo();
    _initTabs();
    await _loadUserCollections();
  }

  /// 下拉刷新：重新获取用户信息与收藏
  Future<void> _refreshProfile() async {
    if (_persistedToken == null) return;
    await _loadUserInfo();
    _initTabs();
    await _loadUserCollections();
  }

  @override
  Widget build(BuildContext context) {
    final appBarBg = _pinned
        ? Theme.of(context).scaffoldBackgroundColor
        : Colors.transparent;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarBg,
        elevation: _pinned ? 2 : 0,

        //当导航栏不透明时展示的内容
        title: _pinned && _userInfo != null
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _userInfo!.avatar.medium,
                      width: 30,
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_userInfo!.nickname}@${_userInfo!.username}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              )
            : null,
        actions: [
          if (_persistedToken != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('注销登录'),
                      content: Text('确定要注销登录吗？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            OAuthCallbackHandler.clearPersistedToken();
                            Navigator.of(context).pop();
                            _loadPersistedToken();
                          },
                          child: Text('确定'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              _onScroll();
              return false;
            },
            child: RefreshIndicator(
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_persistedToken == null) ...[
                      NoLogin(onAuthorized: _onAuthorized),
                    ] else if (_userInfo != null) ...[
                      // 头部信息
                      UserHeader(userInfo: _userInfo!),
                      // 顶部 Tab 标签
                      if (_tabs.isNotEmpty)
                        TabBar(
                          key: _tabBarKey,
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: _tabs
                              .map((t) => Tab(text: t['label'] as String))
                              .toList(),
                        ),
                      const SizedBox(height: 12),
                      // 当前标签内容
                      if (_isLoadingCollections)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_tabs.isNotEmpty)
                        Collection(
                          userInfo: _userInfo!,
                          collections: _collections,
                          currentType: _tabs[_tabController.index]['id'] as int,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 吸附 TabBar：当触顶时固定在 AppBar 底部
          if (_tabs.isNotEmpty && _pinned)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              left: 0,
              right: 0,
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                elevation: 2,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _tabs
                      .map((t) => Tab(text: t['label'] as String))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
