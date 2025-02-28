import 'dart:developer';

import 'package:riverpod/riverpod.dart';

/// RiverpodLogger allows a direct logging (dart developer log) to riverpod providers
/// Since they're most likely to show some sort of PII, it is restricted to the debug mode
/// It alsos uses a non
class RiverpodLogger implements ProviderObserver {
  @override
  void didAddProvider(ProviderBase<Object?> provider, Object? value, ProviderContainer container) {
    final name = provider.name!;
    final val = value.hashCode.toString().padRight(10).substring(0, 7);
    final ident = provider.runtimeType;
    log(
      '|+ Added: [$name] #$val as...\t<$ident>',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    log(
      '|x Disposed: ${provider.runtimeType}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final name = provider.name!;
    final prev = previousValue.hashCode.toString().padRight(10).substring(0, 7);
    final val = newValue.hashCode.toString().padRight(10).substring(0, 7);
    final ident = previousValue.runtimeType;

    log(
      '|^ Updated $ident: [$name] #$prev to: #$val',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    final name = provider.name!;
    final ident = provider.runtimeType;
    final err = error.runtimeType;
    log(
      '|* Fail: [$name] | <$ident>,\tErrorType: $err,',
    );
    log(
      '!! | Error Details --> $error\n!! | Stacktrace: \n$stackTrace',
    );
  }
}
