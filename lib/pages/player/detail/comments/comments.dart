///@Author Ligg
///@Time 2025/8/19
library;

import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/episodes_comments.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';

class CommentsPage extends StatefulWidget {
  final int? animeId;
  final int? episodeId;

  const CommentsPage({super.key, required this.animeId, this.episodeId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<EpisodesComments> _commentsList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEpisodeComments();
  }

  @override
  void didUpdateWidget(CommentsPage oldWidget){
    super.didUpdateWidget(oldWidget);
    //当episodeNumber发生变化时需要更新数据
    if (widget.episodeId != oldWidget.episodeId) {
      _fetchEpisodeComments();
    }
  }

  ///获取剧集评论
  Future<void> _fetchEpisodeComments() async {
    if (widget.episodeId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '剧集编号为空';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final commentsData = await BangumiService.getEpisodeComments(
        widget.episodeId!,
      );

      setState(() {
        if (commentsData != null) {
          _commentsList = commentsData;
        } else {
          _commentsList = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载评论失败：$e';
      });
    }
  }

  /// 格式化时间戳
  String _formatTime(num? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 构建评论项
  Widget _buildCommentItem(EpisodesComments comment, {bool isReply = false}) {
    return Card(
      margin: EdgeInsets.only(
        left: isReply ? 32 : 16,
        right: 16,
        top: 4,
        bottom: 4,
      ),
      elevation: isReply ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Row(
              children: [
                // 用户头像
                CircleAvatar(
                  radius: isReply ? 16 : 20,
                  backgroundImage: comment.user?.avatar?.small != null
                      ? NetworkImage(comment.user!.avatar!.small!)
                      : null,
                  child: comment.user?.avatar?.small == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                // 用户名和时间
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isReply)
                            Icon(
                              Icons.subdirectory_arrow_right,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          if (isReply) const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              comment.user?.nickname ??
                                  comment.user?.username ??
                                  '匿名用户',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isReply ? 14 : 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatTime(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: isReply ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 评论内容
            if (comment.content?.isNotEmpty == true)
              Text(
                comment.content!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isReply ? 13 : 14,
                ),
              ),
            const SizedBox(height: 8),
            // 反应/点赞信息
            if (comment.reactions?.isNotEmpty == true)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: comment.reactions!.map((reaction) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getReactionEmoji(reaction.value),
                          style: TextStyle(fontSize: isReply ? 12 : 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reaction.users?.length ?? 0}',
                          style: TextStyle(
                            fontSize: isReply ? 10 : 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            // 回复评论
            if (comment.replies?.isNotEmpty == true) ...<Widget>[
              const SizedBox(height: 12),
              ...comment.replies!.map((reply) => 
                _buildCommentItem(reply, isReply: true)
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据反应值获取对应的表情
  String _getReactionEmoji(num? value) {
    switch (value) {
      case 54: return '😄'; // 搞笑
      case 122: return '😭'; // 哭
      case 140: return '👍'; // 赞
      case 141: return '👎'; // 踩
      case 142: return '❤️'; // 爱心
      case 143: return '😂'; // 大笑
      case 144: return '😢'; // 难过
      case 145: return '😡'; // 愤怒
      default: return '👍';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以保持状态

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchEpisodeComments,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_commentsList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchEpisodeComments,
        child: ListView(
          children: const [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无评论', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    '下拉刷新试试',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEpisodeComments,
      child: ListView.builder(
        itemCount: _commentsList.length,
        itemBuilder: (context, index) {
          return _buildCommentItem(_commentsList[index]);
        },
      ),
    );
  }
}
