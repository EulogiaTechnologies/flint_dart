import 'dart:io';

/// A lightweight environment variable parser for loading `.env` files
/// into memory for configuration purposes.
///
/// This class reads key-value pairs from a `.env` file and stores them
/// in a static in-memory map. Values can then be accessed using various
/// typed getters like [get], [getInt], and [getBool].
class FlintEnv {
  /// Internal in-memory store for loaded environment variables.
  static final Map<String, String> _env = {};

  /// Returns the value for the given [key] from the environment.
  ///
  /// If the key is not found, returns the [defaultValue] (defaults to `''`).
  ///
  /// Example:
  /// ```dart
  /// String dbHost = FlintEnv.get('DB_HOST', 'localhost');
  /// ```
  static String get(String key, [String defaultValue = '']) {
    return _env[key] ?? defaultValue;
  }

  /// Returns the integer value for the given [key] from the environment.
  ///
  /// If the key is not found or cannot be parsed as an integer,
  /// returns the [defaultValue] (defaults to `0`).
  ///
  /// Example:
  /// ```dart
  /// int port = FlintEnv.getInt('DB_PORT', 3306);
  /// ```
  static int getInt(String key, [int defaultValue = 0]) {
    return int.tryParse(_env[key] ?? '') ?? defaultValue;
  }

  /// Returns the boolean value for the given [key] from the environment.
  ///
  /// Accepts `'true'`, `'1'` as `true`, and `'false'`, `'0'` as `false`.
  /// If the key is not found or cannot be interpreted, returns [defaultValue] (defaults to `false`).
  ///
  /// Example:
  /// ```dart
  /// bool isProduction = FlintEnv.getBool('PRODUCTION', false);
  /// ```
  static bool getBool(String key, [bool defaultValue = false]) {
    final val = _env[key]?.toLowerCase();
    return val == 'true' || val == '1'
        ? true
        : val == 'false' || val == '0'
            ? false
            : defaultValue;
  }

  /// Loads environment variables from the given [path] (default is `.env`).
  ///
  /// Each line should follow the `KEY=VALUE` format. Lines beginning with
  /// `#` are ignored. Quoted values (single or double quotes) are handled.
  ///
  /// Example:
  /// ```env
  /// DB_HOST=localhost
  /// DB_PORT=3306
  /// ```
  ///
  /// Call this once before using [get], [getInt], or [getBool].
  ///
  /// ```dart
  /// await FlintEnv.load();
  /// ```
  static Future<void> load([String path = '.env']) async {
    final file = File(path);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    _env.addAll(_parseLines(lines));
  }

  /// Parses a list of lines into a map of environment variables.
  ///
  /// Expects lines in `KEY=VALUE` format, ignoring empty lines and comments.
  static Map<String, String> _parseLines(List<String> lines) {
    final result = <String, String>{};
    final regex = RegExp(r'^([A-Z_][A-Z0-9_]*)\s*=\s*(.*)$');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final match = regex.firstMatch(line);
      if (match != null) {
        final key = match.group(1)!;
        var value = match.group(2)!;

        // Remove surrounding quotes if present
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        } else if (value.startsWith("'") && value.endsWith("'")) {
          value = value.substring(1, value.length - 1);
        }

        result[key] = value;
      }
    }
    return result;
  }
}
