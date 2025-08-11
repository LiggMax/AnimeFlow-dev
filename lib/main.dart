import 'package:AnimeFlow/router/router_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './controllers/theme_controller.dart';

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

  @override
  void initState() {
    super.initState();
    themeController = ThemeController();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    await themeController.initTheme();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  // 路由
  final _router = AppRouter().routes;

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
              routerConfig: _router,
            ),
          );
        },
      ),
    );
  }
}
