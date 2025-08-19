import 'package:flutter/material.dart';
import 'package:AnimeFlow/request/bangumi/bangumi.dart';
import 'package:AnimeFlow/modules/bangumi/comments.dart';

/// 评论内容组件
class AnimeCommentsContent extends StatefulWidget {
  final int animeId;
  final VoidCallback? onLoadMoreTriggered;
  final Function(bool)? onLoadingStateChanged;

  const AnimeCommentsContent({
    super.key,
    required this.animeId,
    this.onLoadMoreTriggered,
    this.onLoadingStateChanged,
  });

  @override
  State<AnimeCommentsContent> createState() => AnimeCommentsContentState();
}

class AnimeCommentsContentState extends State<AnimeCommentsContent> {
  CommentsData? _commentsData;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentOffset = 0;
  bool _hasMore = true;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentOffset = 0;
        _hasMore = true;
      });

      _fetchComments(0);
    }
  }

  Future<void> _fetchComments(int offset) async {
    try {
      final data = await BangumiService.getComments(
        widget.animeId,
        limit: _pageSize,
        offset: offset,
      );

      if (mounted) {
        setState(() {
          if (offset == 0) {
            // 首次加载或刷新
            _commentsData = data;
            _isLoading = false;
            _currentOffset = _pageSize;
          } else {
            // 加载更多
            _isLoadingMore = false;
            if (data != null && data.data.isNotEmpty) {
              // 合并评论数据
              _commentsData = CommentsData(
                total: data.total,
                data: [..._commentsData!.data, ...data.data],
              );
              _currentOffset += _pageSize;
            } else {
              _hasMore = false;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  /// 公共方法：加载更多评论
  Future<void> loadMoreComments() async {
    await _loadMoreComments();
  }

  Future<void> _loadMoreComments() async {
    // 如果正在加载或没有更多数据，则不执行
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      // 通知父组件加载状态改变
      widget.onLoadingStateChanged?.call(true);

      await _fetchComments(_currentOffset);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _error = e.toString();
        });
      }
    } finally {
      // 通知父组件加载状态改变
      widget.onLoadingStateChanged?.call(false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 确保在依赖项改变时重新加载
    if (_commentsData == null && mounted) {
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 5),
            Text('正在加载评论...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              '加载评论失败',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            ElevatedButton(
              onPressed: _loadComments,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (_commentsData == null || _commentsData!.data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('暂无评论数据'),
        ),
      );
    }

    // 成功获取数据，显示评论列表
    return AnimeCommentsList(
      animeId: widget.animeId,
      commentsData: _commentsData!,
      hasMore: _hasMore,
      isLoadingMore: _isLoadingMore,
      onLoadMore: _loadMoreComments,
    );
  }
}

/// 评论列表组件
class AnimeCommentsList extends StatelessWidget {
  final int animeId;
  final CommentsData commentsData;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const AnimeCommentsList({
    super.key,
    required this.animeId,
    required this.commentsData,
    required this.hasMore,
    required this.isLoadingMore,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '评论 (${commentsData.total})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 评论列表 - 使用Column，让父级CustomScrollView处理滚动
        ...commentsData.data.map((comment) => _buildCommentItem(comment)),
        // 加载更多指示器
        if (hasMore && isLoadingMore) _buildLoadingMoreIndicator(),
        // 没有更多数据的提示
        if (!hasMore && commentsData.data.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '已加载全部评论',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // 加载更多指示器
  Widget _buildLoadingMoreIndicator() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// 构建单个评论项
  Widget _buildCommentItem(BangumiComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15, left: 16, right: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Row(
              children: [
                // 用户头像
                CircleAvatar(
                  radius: 20,
                  backgroundImage: comment.user.avatar.defaultAvatar.isNotEmpty
                      ? NetworkImage(comment.user.avatar.defaultAvatar)
                      : null,
                  onBackgroundImageError: (exception, stackTrace) {
                    // 处理图片加载错误
                  },
                  child: comment.user.avatar.defaultAvatar.isEmpty
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                const SizedBox(width: 10),
                // 用户名称和信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${comment.user.groupText} | ${comment.updateTimeText}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // 评分信息使用星星图标展示
                if (comment.rate > 0) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (index) {
                            final starValue = comment.rate / 2;
                            final isFilled = index < starValue;
                            final isHalf =
                                (starValue - index) > 0 &&
                                (starValue - index) < 1;

                            return Padding(
                              padding: const EdgeInsets.only(right: 1),
                              child: Icon(
                                isHalf ? Icons.star_half : Icons.star,
                                size: 14,
                                color: isFilled || isHalf
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            comment.rateText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 评论类型标签
                      Text(
                        comment.typeText,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),
            // 评论内容
            if (comment.comment.isNotEmpty) ...[
              Text(comment.comment, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// 评论输入框组件 (预留)
class AnimeCommentsInput extends StatefulWidget {
  final int animeId;
  final VoidCallback? onSubmit;

  const AnimeCommentsInput({super.key, required this.animeId, this.onSubmit});

  @override
  State<AnimeCommentsInput> createState() => _AnimeCommentsInputState();
}

class _AnimeCommentsInputState extends State<AnimeCommentsInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  TODO: 实现评论输入框
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '输入你的评论...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现提交评论功能
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}
