import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:AnimeFlow/pages/tabs/user/header.dart';
import 'package:AnimeFlow/pages/tabs/user/no_login.dart';
import 'package:AnimeFlow/utils/theme_extensions.dart';
import 'package:AnimeFlow/modules/bangumi/collections.dart';

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
        setState(() {
          _userInfo = userInfo;
          // 根据实际的收藏统计条目数量重新初始化TabController
          final collectionItems = userInfo?.collectionItems ?? [];
          final tabsLength = collectionItems.isNotEmpty
              ? collectionItems.length
              : 5;
          _tabController.dispose();
          _tabController = TabController(length: tabsLength, vsync: this);

          if (tabsLength >= 2) {
            _tabController.index = 1;
          }
        });

        _loadUserCollections(2);
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
  Future<void> _loadUserCollections(int type) async {
    if (_persistedToken == null) {
      return;
    }
    try {
      final res = await BangumiUser.getUserCollection(_persistedToken!, type);
      if (mounted) {
        setState(() {
          _collectionsByType[type] = res;
        });
      }
    } catch (e) {
      if (mounted) {
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
    _loadUserCollections(type);
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
      body: _ProfileTabView(
        tabController: _tabController,
        tabs: tabs,
        userInfo: _userInfo,
        collectionsByType: _collectionsByType,
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
                    userInfo!.nickname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : const Text('个人中心'),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: context.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
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
        labelColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
        indicatorColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue
            : Theme.of(context).primaryColor,
        tabs: tabWidgets,
        onTap: (index) {
          onTabTapped(index);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// 标签页视图组件
class _ProfileTabView extends StatefulWidget {
  final TabController tabController;
  final List<String> tabs;
  final UserInfo? userInfo;
  final Map<int, Collections?> collectionsByType;

  const _ProfileTabView({
    required this.tabController,
    required this.tabs,
    required this.userInfo,
    required this.collectionsByType,
  });

  @override
  State<_ProfileTabView> createState() => _ProfileTabViewState();
}

class _ProfileTabViewState extends State<_ProfileTabView> {
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
        return CustomScrollView(
          key: PageStorageKey<String>(tabName),
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                bottom: false,
                child: _buildTabContentList(tabName, widget.userInfo),
              ),
            ),
          ],
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
