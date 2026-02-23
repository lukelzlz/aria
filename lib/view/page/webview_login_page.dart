import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../../provider/miauth_notifier_provider.dart';
import '../../util/future_with_dialog.dart';
import '../../util/show_toast.dart';

class WebViewLoginPage extends HookConsumerWidget {
  const WebViewLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miAuthState = ref.watch(miAuthNotifierProvider);
    final isLoading = useState(true);
    final canGoBack = useState(false);
    final webViewController = useState<InAppWebViewController?>(null);

    // Build MiAuth URL if not exists
    useEffect(() {
      if (miAuthState == null) {
        // Default server URL
        const serverUrl = 'https://misskey.liminalselves.top';
        ref.read(miAuthNotifierProvider.notifier).buildMiAuthUrl(
          Uri.parse(serverUrl),
        );
      }
      return null;
    }, []);

    if (miAuthState == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.misskey.login)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.misskey.login),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await futureWithDialog(
                context,
                ref.read(miAuthNotifierProvider.notifier).check(),
              );
              if (!context.mounted) return;
              if (result?.added case final added?) {
                showToast(
                  context: context,
                  message: added
                      ? t.aria.accountAdded
                      : t.aria.accessTokenUpdated,
                );
              }
              if (result?.success ?? false) {
                context.go('/timelines');
              } else {
                showToast(context: context, message: t.misskey.loginFailed);
              }
            },
            icon: const Icon(Icons.check),
            tooltip: t.aria.authenticated,
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri.uri(miAuthState.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {
              webViewController.value = controller;
            },
            onLoadStart: (controller, url) {
              isLoading.value = true;
            },
            onLoadStop: (controller, url) async {
              isLoading.value = false;
              canGoBack.value = await controller.canGoBack();
            },
            onReceivedError: (controller, request, error) {
              // Handle errors silently
            },
          ),
          if (isLoading.value)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: canGoBack.value
          ? BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => webViewController.value?.goBack(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: t.misskey.goBack,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => webViewController.value?.reload(),
                    icon: const Icon(Icons.refresh),
                    tooltip: t.misskey.reload,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
