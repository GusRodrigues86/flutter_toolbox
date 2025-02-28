import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger.g.dart';

/// easy access to the logger
final appLogger = Provider((ref) => ref.read(appLoggerProvider.notifier));

@Riverpod(keepAlive: true)
class AppLogger extends _$AppLogger {
  late final Logger _logger;

  @override
  Future<void> build() async {
    final appPath = await getApplicationDocumentsDirectory();

    _logger = Logger(
      printer: PrefixPrinter(
        PrettyPrinter(
          methodCount: 10,
          errorMethodCount: 8,
          lineLength: 120,
          printEmojis: true,
          colors: false,
          dateTimeFormat: DateTimeFormat.dateAndTime,
        ),
      ),
      output: kReleaseMode
          ? AdvancedFileOutput(
              path: '${appPath.path}/logs',
              overrideExisting: true,
              fileNameFormatter: formatFileName,
            )
          : _InternalLogger(),
    );
  }

  void log(Level level, dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.log(level, message, error: error, stackTrace: stackTrace);

  // Convenience methods for different log levels
  void v(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.trace,
        message,
        error,
        stackTrace,
      );

  void t(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.trace,
        message,
        error,
        stackTrace,
      );
  void d(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.debug,
        message,
        error,
        stackTrace,
      );
  void i(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.info,
        message,
        error,
        stackTrace,
      );
  void w(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.warning,
        message,
        error,
        stackTrace,
      );
  void e(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.error,
        message,
        error,
        stackTrace,
      );
  void f(dynamic message, [Object? error, StackTrace? stackTrace]) => log(
        Level.fatal,
        message,
        error,
        stackTrace,
      );
}

class _InternalLogger extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(log);
  }
}

String formatFileName(DateTime d) {
  final now = d;
  String threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';

    return '00$n';
  }

  String twoDigits(int n) {
    if (n >= 10) return '$n';

    return '0$n';
  }

  String isoDate = now.toIso8601String();
  isoDate = isoDate.substring(0, isoDate.indexOf('T'));

  // ignore: prefer_adjacent_string_concatenation
  return '${isoDate}_${twoDigits(now.hour)}_${twoDigits(now.minute)}_' + //
      '${twoDigits(now.second)}_${threeDigits(now.millisecond)}';
}
