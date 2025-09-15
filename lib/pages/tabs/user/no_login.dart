/*
  @Author Ligg
  @Time 2025/8/9
 */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anime_flow/request/api/bangumi/oauth.dart';
import 'package:anime_flow/request/bangumi/bangumi_oauth.dart';
import 'package:anime_flow/modules/bangumi/token.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NoLogin extends StatefulWidget {
  final ValueChanged<BangumiToken> onAuthorized;

  const NoLogin({super.key, required this.onAuthorized});

  @override
  State<NoLogin> createState() => _NoLoginState();
}

class _NoLoginState extends State<NoLogin> {
  late final String _authUrl = BangumiOAuthApi.oauthUrl;
  StreamSubscription<BangumiToken>? _tokenSubscription;
  bool _isAuthorizing = false;

  Future<void> _launchAuthUrl() async {
    _tokenSubscription?.cancel();
    _tokenSubscription = OAuthCallbackHandler.tokenStream.listen((token) async {
      if (!mounted) return;
      setState(() {
        _isAuthorizing = false;
      });
      await _tokenSubscription?.cancel();
      _tokenSubscription = null;
      widget.onAuthorized(token);
    });

    setState(() {
      _isAuthorizing = true;
    });

    final Uri url = Uri.parse(_authUrl);
    if (!await launchUrl(url)) {
      if (!mounted) return;
      setState(() {
        _isAuthorizing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('无法打开授权页面')));
    }
  }

  void _cancelAuthorization() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
    if (!mounted) return;
    setState(() {
      _isAuthorizing = false;
    });
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: 40),
        CachedNetworkImage(
          imageUrl: 'https://bangumi.tv/img/ukagaka/shell_1.gif',
          width: 200,
          height: 200,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        const Text(
          'Bangumi 授权登录',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          '点击下方按钮进行 Bangumi 账号授权登录',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        if (_isAuthorizing)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 左侧
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: null, // 等待中禁用
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('正在等待登录结果'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // 右侧
              SizedBox(
                width: 76,
                child: OutlinedButton(
                  onPressed: () {
                    _cancelAuthorization();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    foregroundColor: colorScheme.primary,
                    side: const BorderSide(color: Colors.transparent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          )
        else
          ElevatedButton(
            onPressed: _launchAuthUrl,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('授权登录'),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}
