import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  // 添加轮播图控制器
  final List<String> _bannerImages = [
    // 这里添加轮播图图片URL或资源路径
    'https://picgg.cycimg.me/202507images/llbs.webp',
    'https://picgg.cycimg.me/banner/xrkd.webp',
    'https://picgg.cycimg.me/202507images/llbs.webp',
    'https://picgg.cycimg.me/202507images/qczt.webp',
    'https://picgg.cycimg.me/banner/xrkd.webp',
    'https://picgg.cycimg.me/202507images/qczt.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ImageCarousel(imageUrls: _bannerImages),
            SizedBox(height: 200, child: Row(children: [])),
          ],
        ),
      ),
    );
  }
}

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true, // 自动播放
        autoPlayInterval: const Duration(seconds: 8), // 自动播放间隔
        autoPlayCurve: Curves.fastEaseInToSlowEaseOut, // 动画曲线
        pauseAutoPlayOnTouch: true, // 触摸时暂停自动播放
        enlargeCenterPage: true, // 是否放大中间页
        onPageChanged: (index, reason) {
          // 页面改变回调
          print('当前页码: $index');
        },
      ),
      items: imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0), // 可选的圆角
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover, // 图片覆盖整个容器
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
