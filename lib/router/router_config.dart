/*
  @Author Ligg
  @Time 2025/8/11
 */

import 'package:AnimeFlow/pages/player/play_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/animeinfos/anime_info.dart';
import '../pages/tabs.dart';

class AppRouter {

  static const String home = '/';
  static const String animeData = '/anime_data';
  static const String playInfo = '/play_info';

  final GoRouter routes = GoRouter(
    routes: [
      //主页
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const Tabs(),
      ),
      //详情页
      GoRoute(
        path: '$animeData/:animeId',
        name: 'anime_data',
        builder: (context, state) {
          final animeId = int.parse(state.pathParameters['animeId']!);
          return AnimeDataPage(animeId: animeId);
        },
      ),
      //播放页
      GoRoute(
        path: playInfo,
        name: 'play_info',
        builder: (context, state) {
          final extra = state.extra as Map<String,dynamic>;
          final animeName = extra['animeName'];
          final animeId = extra['animeId'];
          return PlayInfo(animeName: animeName, animeId: animeId);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('页面不存在：${state.uri.path}'))),
  );
}
