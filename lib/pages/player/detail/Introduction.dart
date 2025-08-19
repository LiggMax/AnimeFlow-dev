///@Author Ligg
///@Time 2025/8/19
///简介页面
library;

import 'package:flutter/material.dart';

class Introduction extends StatelessWidget {
  final String? animeName;

  const Introduction({super.key, this.animeName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              animeName ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ],
    );
  }
}
