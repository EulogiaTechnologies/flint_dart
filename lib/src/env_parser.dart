// lib/src/env_parser.dart
import 'dart:io';

class FlintEnv {
  static final Map<String, String> _env = {};

  static String get(String key, [String defaultValue = '']) {
    return _env[key] ?? defaultValue;
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return int.tryParse(_env[key] ?? '') ?? defaultValue;
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    final val = _env[key]?.toLowerCase();
    return val == 'true' || val == '1'
        ? true
        : val == 'false' || val == '0'
            ? false
            : defaultValue;
  }

  static Future<void> load([String path = '.env']) async {
    final file = File(path);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    _env.addAll(_parseLines(lines));
  }

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

        // Handle quoted values
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
