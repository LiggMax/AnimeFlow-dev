///@Author Ligg
///@Time 2025/8/19
library;
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final int? animeId;
  const CommentsPage({super.key, required this.animeId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 示例评论数据
  final List<Map<String, dynamic>> comments = [
    {
      'username': '用户A',
      'avatar': Icons.person,
      'date': '2025-08-19',
      'rating': 5,
      'content': '这部动漫真的很棒！剧情紧凑，画面精美，强烈推荐！',
    },
    {
      'username': '用户B',
      'avatar': Icons.person,
      'date': '2025-08-18',
      'rating': 4,
      'content': '还不错，有些地方可以改进，但整体还是值得一看的。',
    },
    {
      'username': '用户C',
      'avatar': Icons.person,
      'date': '2025-08-17',
      'rating': 5,
      'content': '追了整个季度，每一集都很精彩，期待下一季！',
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以保持状态
    return ListView(
      children: [
        // 评论列表
        for (var comment in comments)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户信息行
                  Row(
                    children: [
                      CircleAvatar(
                        child: Icon(comment['avatar']),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            comment['date'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // 评分
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < comment['rating']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
