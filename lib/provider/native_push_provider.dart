import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../provider/api/notifications_notifier_provider.dart';
import '../provider/shared_preferences_provider.dart';

part 'native_push_provider.g.dart';

const _methodChannel = MethodChannel('com.poppingmoon.aria/push');
const _eventChannel = EventChannel('com.poppingmoon.aria/poll_event');

@Riverpod(keepAlive: true)
class NativePushService extends _$NativePushService {
  @override
  NativePushState build() {
    _listenToPollEvents();
    _loadState();
    return const NativePushState();
  }

  static const String _keyKeepAlive = 'native_push_keep_alive';
  static const String _keyPolling = 'native_push_polling';
  static const String _keyPollingInterval = 'native_push_polling_interval';

  Future<void> _loadState() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final keepAlive = prefs.getBool(_keyKeepAlive) ?? false;
    final polling = prefs.getBool(_keyPolling) ?? false;
    final interval = prefs.getInt(_keyPollingInterval) ?? 15;

    state = state.copyWith(
      keepAliveEnabled: keepAlive,
      pollingEnabled: polling,
      pollingIntervalMinutes: interval,
    );

    // Apply saved settings on Android
    if (Platform.isAndroid && !kDebugMode) {
      if (keepAlive) {
        await startKeepAlive();
      }
      if (polling) {
        await startPolling(intervalMinutes: interval);
      }
    }
  }

  void _listenToPollEvents() {
    if (!Platform.isAndroid) return;
    
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event == 'poll') {
        _checkNotifications();
      }
    });
  }

  Future<void> _checkNotifications() async {
    try {
      // This will trigger notification check via the existing provider
      await ref.read(notificationsNotifierProvider(null).notifier).refresh();
    } catch (e) {
      debugPrint('Error checking notifications: $e');
    }
  }

  Future<void> startKeepAlive() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('startKeepAlive');
      state = state.copyWith(keepAliveEnabled: true);
      await ref.read(sharedPreferencesProvider).setBool(_keyKeepAlive, true);
    } on PlatformException catch (e) {
      debugPrint('Failed to start keep alive: ${e.message}');
    }
  }

  Future<void> stopKeepAlive() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('stopKeepAlive');
      state = state.copyWith(keepAliveEnabled: false);
      await ref.read(sharedPreferencesProvider).setBool(_keyKeepAlive, false);
    } on PlatformException catch (e) {
      debugPrint('Failed to stop keep alive: ${e.message}');
    }
  }

  Future<void> toggleKeepAlive(bool enabled) async {
    if (enabled) {
      await startKeepAlive();
    } else {
      await stopKeepAlive();
    }
  }

  Future<void> startPolling({int intervalMinutes = 15}) async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('startPolling', {
        'intervalMinutes': intervalMinutes,
      });
      state = state.copyWith(
        pollingEnabled: true,
        pollingIntervalMinutes: intervalMinutes,
      );
      await ref.read(sharedPreferencesProvider).setBool(_keyPolling, true);
      await ref.read(sharedPreferencesProvider).setInt(_keyPollingInterval, intervalMinutes);
    } on PlatformException catch (e) {
      debugPrint('Failed to start polling: ${e.message}');
    }
  }

  Future<void> stopPolling() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('stopPolling');
      state = state.copyWith(pollingEnabled: false);
      await ref.read(sharedPreferencesProvider).setBool(_keyPolling, false);
    } on PlatformException catch (e) {
      debugPrint('Failed to stop polling: ${e.message}');
    }
  }

  Future<void> togglePolling(bool enabled, {int intervalMinutes = 15}) async {
    if (enabled) {
      await startPolling(intervalMinutes: intervalMinutes);
    } else {
      await stopPolling();
    }
  }

  Future<bool> isKeepAliveRunning() async {
    if (!Platform.isAndroid) return false;
    
    try {
      return await _methodChannel.invokeMethod('isKeepAliveRunning') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isPollingScheduled() async {
    if (!Platform.isAndroid) return false;
    
    try {
      return await _methodChannel.invokeMethod('isPollingScheduled') ?? false;
    } on PlatformException {
      return false;
    }
  }
}

class NativePushState {
  final bool keepAliveEnabled;
  final bool pollingEnabled;
  final int pollingIntervalMinutes;

  const NativePushState({
    this.keepAliveEnabled = false,
    this.pollingEnabled = false,
    this.pollingIntervalMinutes = 15,
  });

  NativePushState copyWith({
    bool? keepAliveEnabled,
    bool? pollingEnabled,
    int? pollingIntervalMinutes,
  }) {
    return NativePushState(
      keepAliveEnabled: keepAliveEnabled ?? this.keepAliveEnabled,
      pollingEnabled: pollingEnabled ?? this.pollingEnabled,
      pollingIntervalMinutes: pollingIntervalMinutes ?? this.pollingIntervalMinutes,
    );
  }
}
