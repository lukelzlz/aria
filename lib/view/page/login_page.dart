import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' hide launchUrl;

import '../../constant/max_content_width.dart';
import '../../i18n/strings.g.dart';
import '../../provider/api/meta_notifier_provider.dart';
import '../../provider/dio_provider.dart';
import '../../provider/miauth_notifier_provider.dart';
import '../../provider/misskey_servers_provider.dart';
import '../../provider/server_url_notifier_provider.dart';
import '../../util/future_with_dialog.dart';
import '../../util/launch_url.dart';
import '../../util/punycode.dart';
import '../widget/image_widget.dart';
import '../widget/misskey_server_background.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key, this.query});

  final String? query;

  // Customization: Force server domain
  static const String _forcedServerDomain = 'misskey.liminalselves.top';

  Future<void> _launchMiAuth(
    WidgetRef ref,
    String query, {
    bool skipValidation = false,
  }) async {
    final trimmed = query.trim();
    final match = RegExp(
      '^(https?://)?([^/]*)',
      caseSensitive: false,
    ).firstMatch(trimmed);
    final scheme = match?[1]?.toLowerCase() ?? 'https://';
    final host = toAscii(match?[2] ?? trimmed).toLowerCase();
    final serverUrl = Uri.parse('$scheme$host');

    bool miauth = skipValidation;
    if (!skipValidation) {
      final server = ref
          .read(misskeyServersProvider)
          .value
          ?.firstWhereOrNull((server) => server.url == host);
      if (server?.meta case final meta?) {
        if (meta['features'] case {'miauth': true}) {
          miauth = true;
        }
        if (meta['uri'] case final String uri) {
          final url = Uri.tryParse(uri);
          if (url?.authority case final authority?) {
            await ref
                .read(serverUrlNotifierProvider(authority).notifier)
                .updateUrl(serverUrl);
          }
        }
      } else {
        try {
          if (await ref
                  .read(serverUrlNotifierProvider(host).notifier)
                  .getSavedUrl() ==
              serverUrl) {
            final meta = await ref.read(metaNotifierProvider(trimmed).future);
            miauth = meta.features?.miauth ?? false;
          } else {
            final meta = await ref
                .read(dioProvider)
                .postUri<Map<String, dynamic>>(
                  serverUrl.replace(pathSegments: ['api', 'meta']),
                  data: {},
                );
            if (meta.data?['features'] case {'miauth': true}) {
              miauth = true;
            }
            if (meta.data?['uri'] case final String uri) {
              final url = Uri.tryParse(uri);
              if (url?.authority case final authority?) {
                await ref
                    .read(serverUrlNotifierProvider(authority).notifier)
                    .updateUrl(serverUrl);
              }
            }
          }
        } catch (_) {}
      }
    }

    if (!ref.context.mounted) return;
    if (miauth) {
      final url = ref
          .read(miAuthNotifierProvider.notifier)
          .buildMiAuthUrl(serverUrl);
      unawaited(
        launchUrl(
          ref,
          url,
          mode: switch (defaultTargetPlatform) {
            TargetPlatform.iOS => LaunchMode.inAppWebView,
            _ => null,
          },
        ),
      );
      unawaited(ref.context.push('/login/authenticate'));
    } else {
      unawaited(ref.context.push('/login/token?query=$trimmed'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Customization: Force server domain, ignore query parameter
    final servers = ref.watch(misskeyServersProvider).value ?? [];
    final controller = useTextEditingController(text: _forcedServerDomain);
    final focusNode = useFocusNode();
    final query = useState(_forcedServerDomain);
    final host = _forcedServerDomain;
    final server = servers.firstWhereOrNull((server) => server.url == host);
    final iconUrl =
        server?.meta?['iconUrl'] as String? ??
        (server != null && server.icon
            ? 'https://instanceapp.misskey.page/instance-icons/${server.url}.webp'
            : null);
    useEffect(() {
      controller.addListener(
        () =>
            query.value = controller.text.replaceFirst(RegExp('^https://'), ''),
      );
      return;
    }, []);

    return Scaffold(
      body: MisskeyServerBackground(
        controller: controller,
        child: Column(
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                child: AppBar(
                  title: Text(t.misskey.login),
                  actions: [
                    PopupMenuButton<void>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () =>
                              context.push('/login/token?query=${query.value}'),
                          child: Text(t.aria.loginWithAccessToken),
                        ),
                      ],
                    ),
                  ],
                  backgroundColor: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: maxContentWidth,
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Color(0xffdddddd),
                              shape: BoxShape.circle,
                            ),
                            child: iconUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: ImageWidget(
                                      url: iconUrl,
                                      width: 50.0,
                                      height: 50.0,
                                    ),
                                  )
                                : const SizedBox.square(dimension: 50.0),
                          ),
                          const SizedBox(height: 16.0),
                          // Customization: Server input is read-only with forced domain
                          TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: t.misskey.instance,
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            ),
                            readOnly: true,
                          ),
                          // Customization: Removed "Find Server" button
                          const SizedBox(height: 16.0),
                          ElevatedButton.icon(
                            onPressed: query.value.isNotEmpty
                                ? () => futureWithDialog(
                                    context,
                                    _launchMiAuth(ref, query.value),
                                  )
                                : null,
                            onLongPress: query.value.isNotEmpty
                                ? () => futureWithDialog(
                                    context,
                                    _launchMiAuth(
                                      ref,
                                      query.value,
                                      skipValidation: true,
                                    ),
                                  )
                                : null,
                            icon: const Icon(Icons.open_in_browser),
                            label: Text(t.aria.authenticate),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
