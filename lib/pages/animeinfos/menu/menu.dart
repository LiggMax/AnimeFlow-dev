///@Author Ligg
///@Time 2025/9/8
library;

import 'package:animeFlow/pages/animeinfos/head/anime_head_service.dart';
import 'package:flutter/material.dart';
import 'drop_down_menu.dart';

class ShareMenu {
  static void showShareMenu(
    BuildContext context,
    GlobalKey buttonKey,
    Color theme,
    String imageUrl,
    String title,
    int id,
  ) async {
    final result = await ReusableDropdownMenu.show<String>(
      context: context,
      buttonKey: buttonKey,
      items: [
        ReusableDropdownMenu.createIconItem(
          value: 'goToWebsite',
          icon: Icons.open_in_browser_rounded,
          text: '浏览器查看',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'saveImage',
          icon: Icons.file_download_outlined,
          text: '下载封面',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'copyLink',
          icon: Icons.copy_all,
          text: '复制网址',
          iconColor: theme,
        ),
      ],
    );

    //选项处理
    if (result != null && context.mounted) {
      AnimeHeadService.handleShareOption(context, result, imageUrl, title, id);
    }
  }

  ///追番菜单
  static void showFollowMenu(
    BuildContext context,
    GlobalKey buttonKey,
    Color theme,
    int id,
  ) async {
    final result = await ReusableDropdownMenu.show<String>(
      context: context,
      buttonKey: buttonKey,
      items: [
        ReusableDropdownMenu.createIconItem(
          value: 'wish',
          icon: Icons.add_chart_outlined,
          text: '想看',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'watching',
          icon: Icons.play_circle_outline_outlined,
          text: '再看',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'watched',
          icon: Icons.check_circle_outline_outlined,
          text: '看过',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'on_hold',
          icon: Icons.access_alarm_rounded,
          text: '搁置',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'dropped',
          icon: Icons.dangerous_outlined,
          text: '抛弃',
          iconColor: theme,
        ),
        ReusableDropdownMenu.createIconItem(
          value: 'cancel',
          icon: Icons.delete_sweep_outlined,
          text: '取消追番',
          iconColor: theme,
        )
      ],
    );
    if(result != null && context.mounted) {
      print('追番菜单选择: $result');
    }
  }
}
