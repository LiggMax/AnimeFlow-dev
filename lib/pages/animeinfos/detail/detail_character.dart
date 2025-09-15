/*
  @Author Ligg
  @Time 2025/8/5
 */
import 'package:anime_flow/request/bangumi/bangumi.dart';
import 'package:anime_flow/modules/bangumi/character_data.dart';
import 'package:flutter/material.dart';
import 'detail_info.dart';

///条目角色
class AnimeCharacter extends StatefulWidget {
  final int animeId;

  const AnimeCharacter({super.key, required this.animeId});

  @override
  State<AnimeCharacter> createState() => _AnimeCharacterState();
}

class _AnimeCharacterState extends State<AnimeCharacter> {
  CharacterData? _characterData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacterData();
  }

  Future<void> _loadCharacterData() async {
    try {
      final data = await BangumiService.getCharacters(widget.animeId);
      if (mounted) {
        setState(() {
          _characterData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 获取主角列表，如果主角数量不足4个，则补充其他角色
  List<CharacterItem> get _mainCharacters {
    if (_characterData == null) return [];

    // 获取所有主角
    final mainCharacters = _characterData!.data
        .where((item) => item.type == 1) // 主角
        .toList();

    // 如果主角数量小于4个，需要补充其他角色
    if (mainCharacters.length < 4) {
      // 获取非主角角色，按类型和顺序排序
      final otherCharacters = _characterData!.data
          .where((item) => item.type != 1)
          .toList()
        ..sort((a, b) {
          // 首先按类型排序（配角优先于客串）
          if (a.type != b.type) {
            return a.type.compareTo(b.type);
          }
          // 然后按顺序排序
          return a.order.compareTo(b.order);
        });

      // 补充角色直到达到4个或没有更多角色
      final needed = 4 - mainCharacters.length;
      final additionalCharacters = otherCharacters.take(needed).toList();

      // 合并主角和补充的角色
      return [...mainCharacters, ...additionalCharacters];
    }

    return mainCharacters;
  }

  // 获取所有角色列表
  List<CharacterItem> get _allCharacters {
    if (_characterData == null) return [];
    return _characterData!.data;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_characterData == null || _characterData!.data.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : screenWidth > 600 ? 4 : 2;
    final childAspectRatio = screenWidth > 900 ? 2.0 : screenWidth > 600 ? 2.5 : 3.0;

    return AnimeInfoSection(
      title: '角色信息',
      children: [
        // 主角网格展示
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _mainCharacters.length,
          itemBuilder: (context, index) {
            final character = _mainCharacters[index];
            return _buildCharacterCard(character);
          },
        ),
        // 查看全部按钮
        if (_allCharacters.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showAllCharacters(context),
                child: const Text('查看全部'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCharacterCard(CharacterItem characterItem) {
    return Row(
      children: [
        // 角色头像
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(characterItem.character.images.medium),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 角色信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                characterItem.character.characterDisplayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${characterItem.roleName}·${characterItem.actors.isNotEmpty ? characterItem.actors.first.actorDisplayName : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAllCharacters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllCharactersSheet(),
    );
  }

  Widget _buildAllCharactersSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      '角色',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_allCharacters.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // 角色列表
              Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 900 ? 4 : width > 600 ? 3 : 2;
                      final childAspectRatio = width > 900 ? 2.0 : width > 600 ? 2.5 : 3.0;
                      return GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _allCharacters.length,
                        itemBuilder: (context, index) {
                          final character = _allCharacters[index];
                          return _buildCharacterListItem(character);
                        },
                      );
                    }
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCharacterListItem(CharacterItem characterItem) {
    return Row(
      children: [
        // 角色头像
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(characterItem.character.images.medium),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 角色信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                characterItem.character.characterDisplayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${characterItem.roleName}·${characterItem.actors.isNotEmpty ? characterItem.actors.first.actorDisplayName : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
