import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:window_manager/window_manager.dart';

class FullscreenUtils {
  static int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 3;
    if (width < 800) return 4;
    if (width < 1000) return 5;
    return 7; // 超大屏幕显示7列
  }

  /// 判断是否为桌面设备
  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// 判断设备是否为平板
  static bool isTablet() {
    return false;
  }

  /// 判断设备是否需要紧凑布局
  static bool isCompact() {
    return !isDesktop();
  }

  /// 判断是否分屏模式 (android only)
  static Future<bool> isInMultiWindowMode() async {
    // 暂时返回false，避免调用不存在的原生方法
    // 如果需要检测分屏模式，需要实现对应的原生方法
    return false;
  }

  // 进入全屏显示
  static Future<void> enterFullScreen({bool lockOrientation = true}) async {
    print('进入全屏 - 平台: ${Platform.operatingSystem}');

    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      print('桌面端：设置窗口全屏');
      await windowManager.setFullScreen(true);
      return;
    }

    // 移动端：先设置UI模式，再锁定方向
    print('移动端：设置沉浸式UI模式');
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (lockOrientation) {
      if (Platform.isAndroid) {
        bool isInMultiWindowMode = await FullscreenUtils.isInMultiWindowMode();
        if (isInMultiWindowMode) {
          print('Android分屏模式，跳过方向锁定');
          return;
        }
      }
      // 锁定横屏
      print('锁定横屏方向');
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      print('横屏锁定完成');
    }
  }

  // 横屏
  static Future<void> landScape() async {
    dynamic document;
    try {
      if (kIsWeb) {
        await document.documentElement?.requestFullscreen();
      } else if (Platform.isAndroid || Platform.isIOS) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (exception, stacktrace) {
      print('Landscape error: $exception');
      print('Stack trace: $stacktrace');
    }
  }

  // 竖屏
  static Future<void> verticalScreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // 解除屏幕旋转限制
  static Future<void> unlockScreenRotation() async {
    await SystemChrome.setPreferredOrientations([]);
  }
}
