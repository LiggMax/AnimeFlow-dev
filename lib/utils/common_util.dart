import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../request/request.dart';
import 'fullscreen_utils.dart';

class CommonUtil {
  //打开浏览器
  static Future<void> toLaunchUrl(String url, {BuildContext? context}) async {
    final Uri uri = Uri.parse(url);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    } else {
      // 如果无法打开URL，显示错误提示
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('无法打开网页')));
      }
    }
  }

  //复制链接
  static void copyLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
  }

  ///下载保持图片
  static Future<void> saveImage(String url, String name) async {
    try {
      final String time = DateTime.now().millisecondsSinceEpoch.toString();
      if (!FullscreenUtils.isDesktop()) {
        /*
          移动端(保持到相册)
          检查并申请存储权限
        */
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          bool granted = await Gal.requestAccess();
          if (!granted) {
            throw Exception('存储权限被拒绝，无法保存图片');
          }
        }
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$time.jpg';
        await httpRequest.download(url, filePath);
        final bytes = await File(filePath).readAsBytes();
        await Gal.putImageBytes(bytes, name: '${name}_$time');
        await File(filePath).delete();
      } else {
        //桌面端(保持到下载目录)
        final dir = await getDownloadsDirectory();
        final filePath = '${dir?.path}/${name}_$time.jpg';
        await httpRequest.download(url, filePath);
        debugPrint('图片已保存到:$filePath');
      }
    } catch (e) {
      debugPrint('保存图片失败:$e');
    }
  }
}
