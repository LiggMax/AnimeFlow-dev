///@Author Ligg
///@Time 2025/8/23
library;

import 'package:AnimeFlow/request/api/bangumi/bgm_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///bgm图标解析工具

class BgmIconParser {

  //解析图标
  static Object parseIcon(int number) {
    if (number >= 1 && number <= 23) {
      return 'https://bgm.tv/img/smiles/bgm/$number.png';
    } else if (number >= 24 && number <= 125) {
      return 'https://bgm.tv/img/smiles/tv_vs/bgm_$number.png';
    } else if (number >= 200 && number <= 238) {
      return 'https://bgm.tv/img/smiles/tv_vs/bgm_$number.png';
    } else if (number >= 500 && number <= 529) {
      return 'https://bgm.tv/img/smiles/tv_500/bgm_$number.gif';
    } else {
      return Icon(Icons.running_with_errors_sharp);
    }
  }
}
