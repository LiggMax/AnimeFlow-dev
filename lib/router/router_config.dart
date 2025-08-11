/*
  @Author Ligg
  @Time 2025/8/11
 */

import 'package:AnimeFlow/pages/player/play_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/animeinfos/anime_info.dart';
import '../pages/tabs.dart';

class AppRouter {
  final GoRouter routes = GoRouter(
    routes: [
      //主页
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const Tabs(),
      ),
      //详情页
      GoRoute(
        path: '/anime_data/:animeId',
        name: 'anime_data',
        builder: (context, state) {
          final animeId = int.parse(state.pathParameters['animeId']!);
          final animeName = state.pathParameters['animeName']!;
          final imageUrl = state.pathParameters['imageUrl']!;
          return AnimeDataPage(
            animeId: animeId,
            animeName: animeName,
            imageUrl: imageUrl,
          );
        },
      ),
      //播放页
      GoRoute(
        path: '/play_info',
        name: 'play_info',
        builder: (context, state) {
          final title = state.pathParameters['title']!;
          final videoInfo = state.extra as Map<String, dynamic>?;
          return PlayInfo(title: title, videoInfo: videoInfo);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('页面不存在：${state.uri.path}'))),
  );
}
