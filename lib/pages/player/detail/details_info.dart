///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';

import '../comments.dart';

class DetailPage extends StatefulWidget {
  final String? animeName;
  final int? animeId;

  const DetailPage({Key? key, this.animeName, this.animeId}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '简介'),
              Tab(text: '评论'),
            ],
            isScrollable: true,
            tabAlignment: TabAlignment.start, //左对齐
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 简介内容
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      widget.animeName ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                /// 评论内容
                CommentsPage(animeId: widget.animeId)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
