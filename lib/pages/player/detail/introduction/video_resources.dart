import 'package:flutter/material.dart';

class Resources extends StatefulWidget {
  final String? animeName;
  final int? episodeNumber;
  final VoidCallback? onTap;

  const Resources({super.key, this.onTap, this.animeName, this.episodeNumber});

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  bool _isAutoSelecting = true;

  //抽屉弹窗
  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '资源',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _isAutoSelecting
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(),
                          )
                        : Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 25,
                          ),
                    const SizedBox(width: 8),
                    Text(
                      _isAutoSelecting ? '正在自动选择' : '已选择数据源',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showDrawer(context);
                      },
                      icon: Icon(
                        Icons.repeat,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        '手动选择',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
