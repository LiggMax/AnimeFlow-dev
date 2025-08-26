import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:AnimeFlow/pages/tabs/user/header.dart';
import 'package:AnimeFlow/pages/tabs/user/no_login.dart';
import 'package:AnimeFlow/modules/bangumi/user_collection.dart';

import 'collection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  BangumiToken? _persistedToken;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadPersistedToken();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 加载持久化的Token
  Future<void> _loadPersistedToken() async {
    final token = await OAuthCallbackHandler.getPersistedToken();
    if (mounted) {
      setState(() {
        _persistedToken = token;
      });
      print('持久化Token已加载: $_persistedToken');
      // 如果有Token，获取用户信息
      if (_persistedToken != null) {
        await _loadUserInfo();
      }
    }
  }

  /// 获取用户信息
  Future<void> _loadUserInfo() async {
    if (_persistedToken == null) return;

    try {
      // 使用Token中的userId获取用户信息
      final userInfo = await BangumiUser.getUserinfo(
        _persistedToken!.userId.toString(),
        token: _persistedToken!.accessToken,
      );

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取用户信息失败: $e')));
      }
    }
  }

  /// 获取用户收藏（想看1、在看2、看过3、搁置4、抛弃5）
  // Future<void> _loadUserCollections() async {
  //       final col = await BangumiUser.getUserCollection(_persistedToken!);
  // }

  /// 接收子组件授权完成后的 Token
  Future<void> _onAuthorized(BangumiToken token) async {
    if (!mounted) return;
    setState(() {
      _persistedToken = token;
    });
    await _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _userInfo != null
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _userInfo!.avatar.large,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    _userInfo!.nickname,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : null,
        actions: [
          if (_persistedToken != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('退出登录'),
                      content: Text('确定要退出登录吗？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            OAuthCallbackHandler.clearPersistedToken();
                            Navigator.of(context).pop();
                            _loadPersistedToken();
                          },
                          child: Text('确定'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
        backgroundColor: Colors.transparent,
      ),

      body: _persistedToken == null
          ? NoLogin(onAuthorized: _onAuthorized)
          : DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  // 头部组件
                  if (_userInfo != null) ...[
                    UserHeader(userInfo: _userInfo!, height: 260),
                  ] else ...[
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  ],
                  // 添加 tabs
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: '想看'),
                      Tab(text: '在看'),
                      Tab(text: '看过'),
                      Tab(text: '搁置'),
                      Tab(text: '抛弃'),
                    ],
                  ),
                  // 对应内容
                  Expanded(
                    child: TabBarView(
                      children: const [
                        Center(child: Text('想看的内容')),
                        Center(child: Text('在看的内容')),
                        Center(child: Text('看过的内容')),
                        Center(child: Text('搁置的内容')),
                        Center(child: Text('抛弃的内容')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
