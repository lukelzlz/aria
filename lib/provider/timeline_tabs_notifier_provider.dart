import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../model/tab_icon.dart';
import '../model/tab_settings.dart';
import '../model/tab_type.dart';
import 'accounts_notifier_provider.dart';
import 'shared_preferences_provider.dart';

part 'timeline_tabs_notifier_provider.g.dart';

@Riverpod(keepAlive: true)
class TimelineTabsNotifier extends _$TimelineTabsNotifier {
  @override
  List<TabSettings> build() {
    final value = ref.watch(sharedPreferencesProvider).getStringList(_key);
    if (value != null) {
      final tabs = <TabSettings>[];
      for (final e in value) {
        try {
          final json = jsonDecode(e) as Map<String, dynamic>;
          json.putIfAbsent('id', () => const Uuid().v4());
          tabs.add(TabSettings.fromJson(json));
        } catch (_) {}
      }
      // Auto-create chat tab for first account if no tabs exist but account exists
      if (tabs.isEmpty) {
        final accounts = ref.watch(accountsNotifierProvider);
        if (accounts.isNotEmpty) {
          final chatTab = TabSettings.chat(accounts.first).copyWith(
            id: const Uuid().v4(),
            icon: const MaterialIcon(codePoint: 0xe0b7), // Icons.chat
          );
          Future.microtask(() => state = [chatTab]);
          return [chatTab];
        }
      }
      return tabs;
    } else {
      // Auto-create chat tab for first account if no tabs exist but account exists
      final accounts = ref.watch(accountsNotifierProvider);
      if (accounts.isNotEmpty) {
        final chatTab = TabSettings.chat(accounts.first).copyWith(
          id: const Uuid().v4(),
          icon: const MaterialIcon(codePoint: 0xe0b7), // Icons.chat
        );
        Future.microtask(() => _save());
        return [chatTab];
      }
      return [];
    }
  }

  static const _key = 'timelineTabs';

  Future<void> _save() async {
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_key, state.map((e) => jsonEncode(e.toJson())).toList());
  }

  TabSettings _removeUnusedValues(TabSettings tabSettings) {
    return tabSettings.copyWith(
      roleId: tabSettings.tabType == TabType.roleTimeline
          ? tabSettings.roleId
          : null,
      channelId: tabSettings.tabType == TabType.channel
          ? tabSettings.channelId
          : null,
      listId: tabSettings.tabType == TabType.userList
          ? tabSettings.listId
          : null,
      antennaId: tabSettings.tabType == TabType.antenna
          ? tabSettings.antennaId
          : null,
      userId: tabSettings.tabType == TabType.user ? tabSettings.userId : null,
      endpoint: tabSettings.tabType == TabType.custom
          ? tabSettings.endpoint
          : null,
      streamingChannel: tabSettings.tabType == TabType.custom
          ? tabSettings.streamingChannel
          : null,
      parameters: tabSettings.tabType == TabType.custom
          ? tabSettings.parameters
          : null,
    );
  }

  Future<void> add(TabSettings tabSettings) async {
    state = [
      ...state,
      _removeUnusedValues(tabSettings).copyWith(id: const Uuid().v4()),
    ];
    await _save();
  }

  Future<void> replace(String tabId, TabSettings tabSettings) async {
    state = state
        .map((tab) => tab.id == tabId ? _removeUnusedValues(tabSettings) : tab)
        .toList();
    await _save();
  }

  Future<void> delete(String tabId) async {
    state = state.where((tab) => tab.id != tabId).toList();
    await _save();
  }

  Future<void> deleteAll(Iterable<String> tabIds) async {
    state = state.where((tab) => !tabIds.contains(tab.id)).toList();
    await _save();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final items = state.toList();
    final item = items.removeAt(oldIndex);
    items.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
    state = items;
    await _save();
  }

  Future<void> import(List<TabSettings> tabs) async {
    state = tabs;
    await _save();
  }
}
