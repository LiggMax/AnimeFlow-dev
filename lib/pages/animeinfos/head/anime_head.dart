import 'dart:ui';
import 'package:animeFlow/pages/animeinfos/menu/menu.dart';
import 'package:animeFlow/router/router_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animeFlow/modules/bangumi/data.dart';
import '../skeleton/head_skeleton.dart';

/// 自定义AppBar组件
class AnimeDetailAppBar extends StatefulWidget {
  final int id;
  final String title;
  final BangumiImages images;
  final bool innerBoxIsScrolled;
  final TabController tabController;
  final List<String> tabs;
  final Widget background;

  const AnimeDetailAppBar({
    super.key,
    required this.id,
    required this.title,
    required this.innerBoxIsScrolled,
    required this.tabController,
    required this.tabs,
    required this.background,
    required this.images,
  });

  @override
  State<AnimeDetailAppBar> createState() => _AnimeDetailAppBarState();
}

class _AnimeDetailAppBarState extends State<AnimeDetailAppBar> {
  late final GlobalKey _shareButtonKey = GlobalKey();
  late final GlobalKey _followButtonKey = GlobalKey();

  Color get theme => Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      title: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Text(widget.title),
      ),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,

      // 添加滚动时的不透明背景
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_rounded),
      ),
      actions: [
        if (widget.innerBoxIsScrolled)
          IconButton(
            key: _followButtonKey,
            onPressed: () {
              ShareMenu.showFollowMenu(
                context,
                _followButtonKey,
                theme,
                widget.id,
              );
            },
            icon: const Icon(Icons.favorite_border),
          ),
        IconButton(
          key: _shareButtonKey,
          onPressed: () {
            ShareMenu.showShareMenu(
              context,
              _shareButtonKey,
              theme,
              widget.images.bestUrl,
              widget.title,
              widget.id,
            );
          },
          icon: const Icon(Icons.share),
        ),
        const SizedBox(width: 8),
      ],
      stretch: true,
      centerTitle: false,
      // 高度设置
      expandedHeight: 300 + kTextTabBarHeight + kToolbarHeight,
      collapsedHeight:
          kTextTabBarHeight +
          kToolbarHeight +
          MediaQuery.paddingOf(context).top,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: widget.background,
      ),
      forceElevated: widget.innerBoxIsScrolled,
      bottom: AnimeDetailTabBar(
        tabController: widget.tabController,
        tabs: widget.tabs,
        innerBoxIsScrolled: widget.innerBoxIsScrolled,
      ),
    );
  }
}

/// 头部组件
class AnimeDetailHeader extends StatelessWidget {
  final BangumiDetailData bangumiItem;
  final bool isLoading;
  final double maxWidth;
  final VoidCallback? onPlayPressed;

  const AnimeDetailHeader({
    super.key,
    required this.bangumiItem,
    required this.isLoading,
    required this.maxWidth,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景模糊图片
        AnimeDetailBackground(
          imageUrl: bangumiItem.images.bestUrl,
          isLoading: isLoading,
        ),
        // 前景内容布局
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight, 16, 0),
              child: Column(
                children: [
                  BangumiInfoCard(
                    bangumiItem: bangumiItem,
                    isLoading: isLoading,
                    maxWidth: maxWidth,
                  ),
                  // 播放按钮区域
                  AnimePlayButton(
                    onPressed: onPlayPressed ?? () {},
                    animeId: bangumiItem.id,
                    animeName: bangumiItem.displayName,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 背景图片组件
class AnimeDetailBackground extends StatelessWidget {
  final String imageUrl;
  final bool isLoading;

  const AnimeDetailBackground({
    super.key,
    required this.imageUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AnimeBackgroundSkeleton(bottomPadding: kTextTabBarHeight + 60);
    }

    return Positioned.fill(
      bottom: kTextTabBarHeight + 60,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.8, 1],
                    ).createShader(bounds);
                  },
                  child: _buildNetworkImage(
                    imageUrl,
                    boxConstraints.maxWidth,
                    boxConstraints.maxHeight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 网络图片构建
  Widget _buildNetworkImage(String imageUrl, double width, double height) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

/// 标签栏组件
class AnimeDetailTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<String> tabs;
  final bool innerBoxIsScrolled;

  const AnimeDetailTabBar({
    super.key,
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
        isScrollable: false,
        tabAlignment: TabAlignment.center,
        dividerHeight: 0,
        tabs: tabs.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// 信息卡片组件
class BangumiInfoCard extends StatelessWidget {
  final BangumiDetailData bangumiItem;
  final bool isLoading;
  final double maxWidth;

  const BangumiInfoCard({
    super.key,
    required this.bangumiItem,
    required this.isLoading,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AnimeInfoSkeleton(maxWidth: maxWidth);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧封面图片
          _buildCoverImage(),
          const SizedBox(width: 12),
          // 右侧信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: _buildAnimeInfo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(53),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 140,
          height: 230,
          child: CachedNetworkImage(
            imageUrl: bangumiItem.images.bestUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          bangumiItem.displayName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // 放送日期和话数
        Text(
          '${bangumiItem.date} · 全 ${bangumiItem.totalEpisodes} 话',
          style: const TextStyle(fontSize: 14),
        ),

        // 评分区域
        if (bangumiItem.rating != null) ...[
          Row(
            children: [
              // 评分星星
              ...List.generate(5, (index) {
                final score = bangumiItem.rating!.score;
                final fullStars = (score / 2).floor();
                final hasHalfStar = (score / 2) - fullStars >= 0.5;

                if (index < fullStars) {
                  return const Icon(Icons.star, color: Colors.amber, size: 20);
                } else if (index == fullStars && hasHalfStar) {
                  return const Icon(
                    Icons.star_half,
                    color: Colors.amber,
                    size: 20,
                  );
                } else {
                  return const Icon(
                    Icons.star_border,
                    color: Colors.white54,
                    size: 16,
                  );
                }
              }),
              const SizedBox(width: 8),
              Text(
                bangumiItem.scoreText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            '${bangumiItem.totalRatingCount} 人评分 / #${bangumiItem.rating!.rank}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],

        const SizedBox(height: 12),

        // 收藏数据
        if (bangumiItem.collection != null) ...[
          Text(
            '${bangumiItem.totalCollectionCount} 收藏 / ${bangumiItem.collection!.doing} 在看 / ${bangumiItem.collection!.wish} 想看',
            style: const TextStyle(fontSize: 15),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

/// 按钮组件
/// 按钮组件
class AnimePlayButton extends StatefulWidget {
  final VoidCallback onPressed;
  final int? animeId;
  final String? animeName;
  final bool isLoading;

  const AnimePlayButton({
    super.key,
    required this.onPressed,
    this.animeId,
    this.animeName,
    this.isLoading = false,
  });

  @override
  State<AnimePlayButton> createState() => _AnimePlayButtonState();
}

class _AnimePlayButtonState extends State<AnimePlayButton> {
  late final GlobalKey _followButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // 如果正在加载，显示骨架屏
    if (widget.isLoading) {
      return const AnimePlayButtonSkeleton();
    }
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 追番按钮
          SizedBox(
            width: 120,
            child: ElevatedButton.icon(
              key: _followButtonKey,
              onPressed: () {
                ShareMenu.showFollowMenu(
                  context,
                  _followButtonKey,
                  primaryColor,
                  widget.animeId!,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.grey.withAlpha(53),
              ),
              icon: const Icon(Icons.add_chart_rounded, size: 20), // 左侧图标
              label: const Text(
                '追番',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(width: 10), // 按钮之间的间距
          // 开始观看按钮
          SizedBox(
            width: 220,
            child: ElevatedButton.icon(
              onPressed: () {
                // 跳转到播放信息页面
                context.pushNamed(
                  AppRouter.playInfo,
                  extra: {'animeName': widget.animeName, 'animeId': widget.animeId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text(
                '开始观看',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

