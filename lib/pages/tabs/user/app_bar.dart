///@Author Ligg
///@Time 2025/8/26
library;

import 'package:AnimeFlow/utils/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../modules/bangumi/token.dart';
import '../../../modules/bangumi/user_info.dart';

class ProfileDetailAppBar extends StatelessWidget {
  final UserInfo? userInfo;
  final BangumiToken? persistedToken;
  final bool innerBoxIsScrolled;
  final TabController tabController;
  final List<String> tabs;
  final VoidCallback onLogout;
  final Widget background;

  const ProfileDetailAppBar({
    required this.userInfo,
    required this.persistedToken,
    required this.innerBoxIsScrolled,
    required this.tabController,
    required this.tabs,
    required this.onLogout,
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
      expandedHeight: 270 + kTextTabBarHeight + kToolbarHeight,
      collapsedHeight:
      kTextTabBarHeight +
          kToolbarHeight +
          MediaQuery.paddingOf(context).top,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: background,
      ),
      forceElevated: innerBoxIsScrolled,
      bottom: _ProfileDetailTabBar(
        tabController: tabController,
        tabs: tabs,
        innerBoxIsScrolled: innerBoxIsScrolled,
      ),
    );
  }
}

/// 标签栏组件
class _ProfileDetailTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController tabController;
  final List<String> tabs;
  final bool innerBoxIsScrolled;

  const _ProfileDetailTabBar({
    required this.tabController,
    required this.tabs,
    required this.innerBoxIsScrolled,
  });

  @override
  Widget build(BuildContext context) {
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
        tabs: tabs.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
