/*
  @Author Ligg
  @Time 2025/7/31
 */
import 'package:flutter/material.dart';

/// 骨架屏加载组件
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({super.key, this.width, this.height, this.borderRadius});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0.0),
              end: Alignment(1.0 + _animation.value, 0.0),
              colors: const [
                Color(0x73E0E0E0),
                Color(0xA4E0E0E0),
                Color(0xCEE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// 动画信息骨架屏
class AnimeInfoSkeleton extends StatelessWidget {
  final double maxWidth;

  const AnimeInfoSkeleton({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width > maxWidth
          ? maxWidth
          : MediaQuery.sizeOf(context).width - 32,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧封面骨架
          Container(
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
            child: SkeletonLoader(
              width: 140,
              height: 230,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          // 右侧信息骨架
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题骨架
                  const SkeletonLoader(
                    width: double.infinity,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoader(
                    width: 180,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),

                  // 日期和话数骨架
                  const SkeletonLoader(
                    width: 150,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),

                  // 评分骨架
                  Row(
                    children: [
                      // 星星骨架
                      ...List.generate(
                        5,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 2),
                          child: const SkeletonLoader(
                            width: 20,
                            height: 20,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SkeletonLoader(
                        width: 40,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 评分详情骨架
                  const SkeletonLoader(
                    width: 120,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),

                  // 收藏数据骨架
                  const SkeletonLoader(
                    width: 200,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 动画详情页背景骨架屏
class AnimeBackgroundSkeleton extends StatelessWidget {
  final double bottomPadding;

  const AnimeBackgroundSkeleton({super.key, this.bottomPadding = 60});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      bottom: bottomPadding,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 1.0],
              colors: [
                Colors.black.withAlpha(55),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 播放按钮骨架屏
class AnimePlayButtonSkeleton extends StatelessWidget {
  const AnimePlayButtonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 追番按钮骨架
          SizedBox(
            width: 120,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const SkeletonLoader(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),

          const SizedBox(width: 10),
          // 开始观看按钮骨架
          SizedBox(
            width: 230,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const SkeletonLoader(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 完整的动画详情头部骨架屏
class AnimeDetailHeaderSkeleton extends StatelessWidget {
  final double maxWidth;

  const AnimeDetailHeaderSkeleton({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景骨架
        AnimeBackgroundSkeleton(bottomPadding: kTextTabBarHeight + 60),
        // 前景内容骨架
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight, 16, 0),
              child: Column(
                children: [
                  // 动画信息骨架
                  AnimeInfoSkeleton(maxWidth: maxWidth),
                  const SizedBox(height: 16),
                  // 播放按钮骨架
                  const AnimePlayButtonSkeleton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
