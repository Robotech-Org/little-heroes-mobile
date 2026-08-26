import 'dart:developer' as developer;

class LoggerUtils {
  LoggerUtils._();

  static void debug(String message) {
    developer.log(
      message,
      name: 'DEBUG',
    );
  }

  static void info(String message) {
    developer.log(
      message,
      name: 'INFO',
    );
  }

  static void warning(String message) {
    developer.log(
      message,
      name: 'WARNING',
    );
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      message,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}