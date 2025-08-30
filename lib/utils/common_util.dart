import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtil {

  static Future<void> toLaunchUrl(String url, {BuildContext? context}) async {
    final Uri uri = Uri.parse(url);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    } else {
      // 如果无法打开URL，显示错误提示
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法打开网页')),
        );
      }
    }
  }
}
