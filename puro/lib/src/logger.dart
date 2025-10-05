import 'dart:async';

import 'package:clock/clock.dart';
import 'package:neoansi/neoansi.dart';

import 'extensions.dart';
import 'provider.dart';
import 'terminal.dart';

enum LogLevel {
  wtf,
  error,
  warning,
  verbose,
  debug;

  bool operator >(LogLevel other) {
    return index > other.index;
  }

  bool operator <(LogLevel other) {
    return index < other.index;
  }

  bool operator >=(LogLevel other) {
    return index >= other.index;
  }

  bool operator <=(LogLevel other) {
    return index <= other.index;
  }
}

class LogEntry {
  LogEntry(this.timestamp, this.level, this.message);

  final DateTime timestamp;
  final LogLevel level;
  final String message;
}

class PuroLogger {
  PuroLogger({this.level, this.terminal, this.onAdd, this.profile = false});

  LogLevel? level;
  Terminal? terminal;
  void Function(LogEntry event)? onAdd;
  bool profile;

  late final stopwatch = Stopwatch();

  OutputFormatter get format => terminal?.format ?? plainFormatter;

  bool shouldLog(LogLevel level) {
    return this.level != null && level <= this.level!;
  }

  void add(LogEntry event) {
    if (level == null || level! < event.level) return;
    _add(event);
  }

  void _add(LogEntry event) {
    if (onAdd != null) {
      onAdd!(event);
    }
    if (terminal != null) {
      final buf = StringBuffer();

      if (profile) {
        final elapsed = stopwatch.elapsedMilliseconds;
        buf.write(
          format.color(
            '${elapsed.pretty().padLeft(4)} ',
            foregroundColor: elapsed > 1000
                ? Ansi8BitColor.red
                : elapsed > 100
                ? Ansi8BitColor.orange1
                : Ansi8BitColor.green,
            bold: true,
          ),
        );
        if (!stopwatch.isRunning) {
          stopwatch.start();
        } else {
          stopwatch.reset();
        }
      }

      buf.write(
        format.color(
          levelPrefixes[event.level]!,
          foregroundColor: levelColors[event.level]!,
          bold: true,
        ),
      );

      terminal!.writeln(format.prefix('$buf ', event.message));
    }
  }

  String _interpolate(Object? message) {
    if (message is Function) {
      return '${message()}';
    } else {
      return '$message';
    }
  }

  void d(Object? message) {
    if (level == null || level! < LogLevel.debug) return;
    _add(LogEntry(DateTime.now(), LogLevel.debug, _interpolate(message)));
  }

  void v(Object? message) {
    if (level == null || level! < LogLevel.verbose) return;
    _add(LogEntry(DateTime.now(), LogLevel.verbose, _interpolate(message)));
  }

  void w(Object? message) {
    if (level == null || level! < LogLevel.warning) return;
    _add(LogEntry(DateTime.now(), LogLevel.warning, _interpolate(message)));
  }

  void e(Object? message) {
    if (level == null || level! < LogLevel.error) return;
    _add(LogEntry(DateTime.now(), LogLevel.error, _interpolate(message)));
  }

  void wtf(Object? message) {
    if (level == null || level! < LogLevel.wtf) return;
    _add(LogEntry(DateTime.now(), LogLevel.wtf, _interpolate(message)));
  }

  static const levelPrefixes = {
    LogLevel.wtf: '[WTF]',
    LogLevel.error: '[E]',
    LogLevel.warning: '[W]',
    LogLevel.verbose: '[V]',
    LogLevel.debug: '[D]',
  };

  static const levelColors = {
    LogLevel.wtf: Ansi8BitColor.pink1,
    LogLevel.error: Ansi8BitColor.red,
    LogLevel.warning: Ansi8BitColor.orange1,
    LogLevel.verbose: Ansi8BitColor.grey62,
    LogLevel.debug: Ansi8BitColor.grey,
  };

  static final provider = Provider<PuroLogger>.late();
  static PuroLogger of(Scope scope) => scope.read(provider);
}

FutureOr<T?> runOptional<T>(
  Scope scope,
  String action,
  Future<T> fn(), {
  LogLevel level = LogLevel.error,
  LogLevel? exceptionLevel,
  bool skip = false,
}) async {
  final log = PuroLogger.of(scope);
  if (skip) {
    log.v('Skipped $action');
    return null;
  }
  final uppercaseAction =
      action.substring(0, 1).toUpperCase() + action.substring(1);
  log.v('$uppercaseAction...');
  try {
    return await fn();
  } catch (exception, stackTrace) {
    final time = clock.now();
    log.add(LogEntry(time, level, 'Exception while $action'));
    log.add(LogEntry(time, exceptionLevel ?? level, '$exception\n$stackTrace'));
    return null;
  }
}
