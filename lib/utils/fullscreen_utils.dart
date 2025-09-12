import 'dart:io';
import 'package:flutter/cupertino.dart';

class FullscreenUtils {
  static int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 3;
    if (width < 800) return 4;
    if (width < 1000) return 5;
    if (width < 1300) return 6;
    return 7; // 超大屏幕
  }

  /// 判断是否为桌面设备
  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
}
