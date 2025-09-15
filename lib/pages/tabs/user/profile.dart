import 'package:animeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:animeFlow/request/bangumi/bangumi_user.dart';
import 'package:animeFlow/modules/bangumi/token.dart';
import 'package:animeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'package:animeFlow/pages/tabs/user/header.dart';
import 'package:animeFlow/pages/tabs/user/no_login.dart';
import 'package:animeFlow/modules/bangumi/collections.dart';
import 'package:animeFlow/pages/tabs/user/user_collection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  BangumiToken? _persistedToken;
  UserInfo? _userInfo;
  late TabController _tabController;
  final Map<int, Collections?> _collectionsByType = {};

  // 添加加载状态管理
  final Map<int, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    // 初始化时使用默认的5个标签长度，后续会根据实际数据动态调整
    _tabController = TabController(length: 5, vsync: this);
    // 默认选择"在看"tab（index为1）
    _tabController.index = 1;
    _loadPersistedToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载持久化的Token
  Future<void> _loadPersistedToken() async {
    final token = await OAuthCallbackHandler.getPersistedToken();
    if (mounted) {
      setState(() {
        _persistedToken = token;
      });
      print('持久化Token已加载: ${_persistedToken?.accessToken}');
      // 如果有Token，获取用户信息
      if (_persistedToken != null) {
        await _loadUserInfo();
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
        // 根据实际的收藏统计条目数量计算tabs长度
        final collectionItems = userInfo?.collectionItems ?? [];
        final tabsLength = collectionItems.isNotEmpty
            ? collectionItems.length
            : 5;

        setState(() {
          _userInfo = userInfo;
          _tabController.dispose();
          _tabController = TabController(length: tabsLength, vsync: this);

          if (tabsLength >= 2) {
            _tabController.index = 1; // 默认选择标签为"在看"
          }
        });

        if (tabsLength >= 2) {
          await _loadUserCollections(3);
        }
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
  Future<void> _loadUserCollections(int type, {bool loadMore = false}) async {
    if (_persistedToken == null) {
      return;
    }

    // 设置加载状态
    if (mounted) {
      setState(() {
        _loadingStates[type] = true;
      });
    }

    try {
      // 计算offset
      final currentCollection = _collectionsByType[type];
      final offset = loadMore ? (currentCollection?.data?.length ?? 0) : 0;

      final res = await BangumiUser.getUserCollection(
        _persistedToken!,
        type,
        offset: offset,
      );

      if (mounted) {
        setState(() {
          if (loadMore && currentCollection != null) {
            // 合并新数据
            final newData = List<Data>.from(currentCollection.data ?? []);
            newData.addAll(res?.data ?? []);

            _collectionsByType[type] = Collections(
              data: newData,
              total: res?.total,
            );
          } else {
            // 替换数据
            _collectionsByType[type] = res;
          }
          _loadingStates[type] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStates[type] = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取收藏数据失败: $e')));
      }
    }
  }

  /// 接收子组件授权完成后的 Token
  Future<void> _onAuthorized(BangumiToken token) async {
    if (!mounted) return;
    setState(() {
      _persistedToken = token;
    });
    await _loadUserInfo();
  }

  /// 处理tab切换时的数据加载
  void _onTabChanged(int type) {
    // 检查是否已有数据，避免重复加载
    if (_collectionsByType.containsKey(type) &&
        _collectionsByType[type] != null &&
        (_collectionsByType[type]?.data?.isNotEmpty ?? false)) {
      // 如果已有数据，尝试加载更多
      _loadUserCollections(type, loadMore: true);
      return;
    }

    // 检查是否正在加载，避免重复请求
    if (_loadingStates[type] == true) {
      return;
    }
    _loadUserCollections(type);
  }

  /// 清除缓存并重新加载数据（用于下拉刷新）
  Future<void> _clearCacheAndReload(int type) async {
    // 清除缓存
    setState(() {
      _collectionsByType.remove(type);
    });

    // 重新加载数据（第一页）
    await _loadUserCollections(type);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _persistedToken == null
          ? NoLogin(onAuthorized: _onAuthorized)
          : _buildUserProfile(),
    );
  }

  Widget _buildUserProfile() {
    // 获取收藏统计条目
    final List<Map<String, dynamic>> collectionItems =
        _userInfo?.collectionItems ?? [];

    // 如果collectionItems为空，使用默认的标签
    final List<String> tabs = collectionItems.isNotEmpty
        ? collectionItems.map((item) => item['label'] as String).toList()
        : ['想看', '在看', '看过', '搁置', '抛弃'];

    // 确保TabController的length与tabs的长度一致
    if (_tabController.length != tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);

      // 默认选择"在看"tab
      if (tabs.length >= 2) {
        _tabController.index = 1; // "在看"tab的index
      }
    }

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: _ProfileDetailAppBar(
              userInfo: _userInfo,
              persistedToken: _persistedToken,
              innerBoxIsScrolled: innerBoxIsScrolled,
              tabController: _tabController,
              tabs: tabs,
              onLogout: _handleLogout,
              onTabChanged: _onTabChanged,
              background: _userInfo != null
                  ? UserHeader(userInfo: _userInfo!, height: 270)
                  : _buildLoadingHeader(),
            ),
          ),
        ];
      },
      body: UserCollectionView(
        tabController: _tabController,
        tabs: tabs,
        userInfo: _userInfo,
        collectionsByType: _collectionsByType,
        loadingStates: _loadingStates,
        onTabChanged: _onTabChanged,
        onRefresh: _clearCacheAndReload,
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: LinearProgressIndicator(),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('退出登录'),
          content: const Text('确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                OAuthCallbackHandler.clearPersistedToken();
                Navigator.of(context).pop();
                _loadPersistedToken();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

/// 自定义ProfileAppBar组件
class _ProfileDetailAppBar extends StatelessWidget {
  final UserInfo? userInfo;
  final BangumiToken? persistedToken;
  final bool innerBoxIsScrolled;
  final TabController tabController;
  final List<String> tabs;
  final VoidCallback onLogout;
  final Function(int) onTabChanged;
  final Widget background;

  const _ProfileDetailAppBar({
    required this.userInfo,
    required this.persistedToken,
    required this.innerBoxIsScrolled,
    required this.tabController,
    required this.tabs,
    required this.onLogout,
    required this.onTabChanged,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      title: userInfo != null
          ? Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    userInfo!.avatar.large,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${userInfo!.nickname}@${userInfo!.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : const Text('个人中心'),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      actions: [
        if (persistedToken != null)
          IconButton(onPressed: onLogout, icon: const Icon(Icons.logout)),
        const SizedBox(width: 8),
      ],
      stretch: true,
      centerTitle: false,
      // 高度设置
      expandedHeight: 225 + kToolbarHeight,
      collapsedHeight:
          kTextTabBarHeight +
          kToolbarHeight +
          MediaQuery.paddingOf(context).top,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.only(bottom: kTextTabBarHeight),
          child: background,
        ),
      ),
      forceElevated: innerBoxIsScrolled,
      bottom: _ProfileDetailTabBar(
        tabController: tabController,
        collectionItems: userInfo?.collectionItems ?? [],
        innerBoxIsScrolled: innerBoxIsScrolled,
        onTabTapped: (index) {
          final String tabName = tabs[index];
          final int type = getTypeFromTabName(tabName);
          onTabChanged(type);
        },
      ),
    );
  }
}

/// 标签栏组件
class _ProfileDetailTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController tabController;
  final List<Map<String, dynamic>> collectionItems;
  final bool innerBoxIsScrolled;
  final Function(int) onTabTapped;

  const _ProfileDetailTabBar({
    required this.tabController,
    required this.collectionItems,
    required this.innerBoxIsScrolled,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabWidgets = collectionItems.isNotEmpty
        ? collectionItems.map((item) {
            final String tabLabel = item['label'];
            final int itemCount = item['count'] ?? 0;
            return Tab(text: '$tabLabel ($itemCount)');
          }).toList()
        : [
            const Tab(text: '想看'),
            const Tab(text: '在看'),
            const Tab(text: '看过'),
            const Tab(text: '搁置'),
            const Tab(text: '抛弃'),
          ];

    return PreferredSize(
      preferredSize: const Size.fromHeight(kTextTabBarHeight),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerHeight: 0,
        tabs: tabWidgets.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;

          // 获取tab名称和对应的type值
          String tabName;
          if (collectionItems.isNotEmpty) {
            tabName = collectionItems[index]['label'] as String;
          } else {
            final defaultTabs = ['想看', '在看', '看过', '搁置', '抛弃'];
            tabName = defaultTabs[index];
          }

          final int type = getTypeFromTabName(tabName);
          final bool _ =
              tabController.index == index &&
              (context
                      .findAncestorStateOfType<_ProfilePageState>()
                      ?._loadingStates[type] ==
                  true);

          return Tab(child: Center(child: tab));
        }).toList(),
        onTap: (index) {
          onTabTapped(index);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
