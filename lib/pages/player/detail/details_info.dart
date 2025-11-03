///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';
import 'comments/comments.dart';
import 'introduction/Introduction_info.dart';

class DetailPage extends StatefulWidget {
  final String? animeName;
  final int? animeId;
  final Function(String)? onVideoUrlReceived; // URL回调
  final Function(int)? onEpisodeIdReceived; // 剧集id回调

  const DetailPage({
    super.key,
    this.animeName,
    this.animeId,
    this.onVideoUrlReceived,
    this.onEpisodeIdReceived,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedEpisodeId;

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

  // 处理剧集回调
  void _handleEpisodeIdReceived(int episodeId) {
    setState(() {
      _selectedEpisodeId = episodeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: '简介'),
              Tab(text: '评论'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                /// 简介内容
                Introduction(
                  animeName: widget.animeName,
                  animeId: widget.animeId,
                  onVideoUrlReceived: widget.onVideoUrlReceived,
                  onEpisodeIdReceived: _handleEpisodeIdReceived,
                ),

                /// 评论内容
                CommentsPage(
                  animeId: widget.animeId,
                  episodeId: _selectedEpisodeId,
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
