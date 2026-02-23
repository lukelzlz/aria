import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../i18n/strings.g.dart';

class WebViewRegisterPage extends HookConsumerWidget {
  const WebViewRegisterPage({super.key});

  static const String _serverUrl = 'https://misskey.liminalselves.top';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final webViewController = useState<InAppWebViewController?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.misskey.signup),
        actions: [
          IconButton(
            onPressed: () => context.push('/onboarding/login'),
            icon: const Icon(Icons.login),
            tooltip: t.misskey.login,
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('$_serverUrl/signup'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
            ),
            onWebViewCreated: (controller) {
              webViewController.value = controller;
            },
            onLoadStart: (controller, url) {
              isLoading.value = true;
            },
            onLoadStop: (controller, url) {
              isLoading.value = false;
            },
          ),
          if (isLoading.value)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
