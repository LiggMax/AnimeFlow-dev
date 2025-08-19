///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';

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
                  children: const [
                    Text('这里是简介内容'),
                    Text(
                      '动漫简介',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '这是动漫的详细描述内容。在这里可以介绍动漫的背景故事、主要情节等信息。',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '角色介绍',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '主要角色信息介绍，包括主角、配角等角色的详细描述。',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '制作信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '导演：XXX\n编剧：XXX\n制作公司：XXX导演：XXX\n编剧：XXX\n制作公司：XXX导演：XXX\n编剧：XXX\n制作公司：XXX导演：XXX\n编剧：XXX\n制作公司：XXX导演：XXX\n编剧：XXX\n制作公司：XXX导演：XXX\n编剧：XXX\n制作公司：XXX',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                // 评论内容
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text('这里是评论内容'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
