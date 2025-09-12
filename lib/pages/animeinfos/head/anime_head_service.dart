///@Author Ligg
///@Time 2025/9/8
library;
import 'package:AnimeFlow/request/api/common_api.dart';
import 'package:AnimeFlow/utils/common_util.dart';
import 'package:flutter/material.dart';

class AnimeHeadService {

  static void handleShareOption(BuildContext context,String option,String imageUrl,String title,int id) {
    switch (option) {
      case 'saveImage':
         CommonUtil.saveImage(imageUrl, title);
         ScaffoldMessenger.of(
           context,
         ).showSnackBar(const SnackBar(content: Text('成功保持封面')));
        break;
      case 'copyLink':
        CommonUtil.copyLink('${CommonApi.bgmTv}/subject/$id');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text('已复制:'),
                Text(
                  '${CommonApi.bgmTv}/subject/$id',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        );
        break;
      case 'goToWebsite':
        CommonUtil.toLaunchUrl('${CommonApi.bgmTv}/subject/$id');
        break;
    }
  }
}
