// import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
// import 'package:flutter/material.dart';
// import 'tabs.dart';
// import 'search/search_page.dart';
// import 'animeinfos/anime_info.dart';
// import 'player/play_info.dart';
// import 'package:AnimeFlow/modules/bangumi/token.dart';
//
// /// 统一的路由系统
// class Routes {
//   // 路由路径定义
//   static const String tabs = '/tabs';
//   static const String home = '/home';
//   static const String time = '/time';
//   static const String profile = '/profile';
//   static const String search = '/search';
//   static const String animeData = '/anime_data';
//   static const String playInfo = '/play_info';
//
//   // 路由生成器
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     final name = settings.name;
//
//     // 处理授权回调
//     if (name != null && name.startsWith('/callback')) {
//       // 获取授权码
//       OAuthCallbackHandler.handleCallback(name).then((code) async {
//         if (code != null) {
//           BangumiToken? token = await OAuthCallbackHandler.getToken(code);
//           if (token != null) {
//             // 持久化Token
//             OAuthCallbackHandler.persistToken(token);
//           }
//         }
//       });
//       return MaterialPageRoute(
//         builder: (context) {
//           Future.microtask(() => Navigator.of(context).pop());
//           return const SizedBox.shrink();
//         },
//         settings: settings,
//       );
//     }
//
//     switch (name) {
//       case tabs:
//         return MaterialPageRoute(
//           builder: (_) => const Tabs(),
//           settings: settings,
//         );
//
//       case search:
//         return MaterialPageRoute(
//           builder: (_) => const SearchPage(),
//           settings: settings,
//         );
//
//       case animeData:
//         final args = settings.arguments;
//         if (args is Map<String, dynamic>) {
//           return MaterialPageRoute(
//             builder: (_) => AnimeDataPage(
//               animeId: args['animeId'] as int,
//               animeName: args['animeName'] as String?,
//             ),
//             settings: settings,
//           );
//         } else if (args is int) {
//           return MaterialPageRoute(
//             builder: (_) => AnimeDataPage(animeId: args),
//             settings: settings,
//           );
//         }
//         return _errorRoute(settings.name);
//
//       case playInfo:
//         final args = settings.arguments as Map<String, dynamic>?;
//         if (args != null) {
//           return MaterialPageRoute(
//             builder: (_) => PlayInfo(
//             ),
//             settings: settings,
//           );
//         }
//         return _errorRoute(settings.name);
//
//       default:
//         return _errorRoute(settings.name);
//     }
//   }
//
//   // 跳转方法
//   static Future<void> goToAnimeData(
//     BuildContext context, {
//     required int animeId,
//     String? animeName,
//     String? imageUrl,
//   }) {
//     return Navigator.pushNamed(
//       context,
//       animeData,
//       arguments: {
//         'animeId': animeId,
//         'animeName': animeName,
//         'imageUrl': imageUrl,
//       },
//     );
//   }
//
//   static Future<void> goToPlayInfo(
//     BuildContext context, {
//     String? title,
//     Map<String, dynamic>? videoInfo,
//   }) {
//     return Navigator.pushNamed(
//       context,
//       playInfo,
//       arguments: {'title': title, 'videoInfo': videoInfo},
//     );
//   }
//
//   static Future<void> goToTabs(BuildContext context) {
//     return Navigator.pushNamedAndRemoveUntil(context, tabs, (route) => false);
//   }
//
//   // 返回
//   static void goBack(BuildContext context, [dynamic result]) {
//     Navigator.pop(context, result);
//   }
//
//   // 跳转并替换当前页面
//   static Future<void> replaceTo(
//     BuildContext context,
//     String routeName, {
//     Object? arguments,
//   }) {
//     return Navigator.pushReplacementNamed(
//       context,
//       routeName,
//       arguments: arguments,
//     );
//   }
//
//   // 清空栈并跳转
//   static Future<void> clearAndGoTo(
//     BuildContext context,
//     String routeName, {
//     Object? arguments,
//   }) {
//     return Navigator.pushNamedAndRemoveUntil(
//       context,
//       routeName,
//       (route) => false,
//       arguments: arguments,
//     );
//   }
//
//   // 404 错误页面
//   static Route<dynamic> _errorRoute(String? routeName) {
//     return MaterialPageRoute(
//       builder: (context) => Scaffold(
//         appBar: AppBar(title: const Text('页面不存在')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 80, color: Colors.red),
//               const SizedBox(height: 20),
//               Text('找不到页面: $routeName', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('返回'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
