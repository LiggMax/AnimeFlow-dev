import 'dart:async';

import 'package:AnimeFlow/router/router_config.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './controllers/theme_controller.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive
  await Hive.initFlutter();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeController themeController;
  bool _isInitialized = false;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _sub;

  @override
  void initState() {
    super.initState();
    themeController = ThemeController();
    _initializeTheme();
    _initDeepLinkListener();
  }

  Future<void> _initializeTheme() async {
    await themeController.initTheme();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _initDeepLinkListener() async {
    // 处理 app 启动时的回调 URI
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    } catch (e) {
      debugPrint('获取初始 URI 失败：$e');
    }

    // 监听 app 运行中收到的 URI（热启动或后台唤起）
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingUri(uri);
      },
      onError: (err) {
        debugPrint('URI 监听错误：$err');
      },
    );
  }

  void _handleIncomingUri(Uri uri) {
    debugPrint('收到回调 URI：$uri');
    if (uri.scheme == 'animeflow' &&
        uri.host == 'auth' &&
        uri.path == '/callback') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        debugPrint('授权成功，Code = $code');
        _handleTokenExchange(code);
        context.pushNamed(AppRouter.home);
      }
    }
  }

  Future<void> _handleTokenExchange(String code) async {
    try {
      final token = await OAuthCallbackHandler.getToken(code);
      if (token != null) {
        await OAuthCallbackHandler.persistToken(token);
      }
    } catch (e) {
      debugPrint('Token 获取或持久化失败: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ChangeNotifierProvider.value(
      value: themeController,
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 300),
            data: themeController.currentTheme,
            child: MaterialApp.router(
              theme: ThemeController.lightTheme,
              darkTheme: ThemeController.darkTheme,
              themeMode: themeController.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              routerConfig: AppRouter().routes,
            ),
          );
        },
      ),
    );
  }
}
