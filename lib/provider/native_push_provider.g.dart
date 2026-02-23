// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_push_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NativePushService)
final nativePushServiceProvider = NativePushServiceProvider._();

final class NativePushServiceProvider
    extends $NotifierProvider<NativePushService, NativePushState> {
  NativePushServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativePushServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativePushServiceHash();

  @$internal
  @override
  NativePushService create() => NativePushService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NativePushState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NativePushState>(value),
    );
  }
}

String _$nativePushServiceHash() => r'native_push_service_hash_12345';

abstract class _$NativePushService extends $Notifier<NativePushState> {
  NativePushState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NativePushState, NativePushState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NativePushState, NativePushState>,
              NativePushState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
