// File: lib/src/orm/model.dart
import 'package:mysql1/mysql1.dart';
import 'query_builder.dart';
import '../validation/validator.dart';

abstract class Model {
  static MySqlConnection? _connection;

  // Override if you want custom table name
  String get table => _inferTableName();
  String? get primaryKey => 'id';

  Map<String, dynamic> toMap();
  Map<String, String> rules() => {};

  static void setConnection(MySqlConnection connection) {
    _connection = connection;
  }

  static MySqlConnection get connection {
    if (_connection == null) {
      throw Exception('Database connection not initialized.');
    }
    return _connection!;
  }

  static QueryBuilder query(String table) => QueryBuilder(table, connection);

  Future<void> save() async {
    final map = toMap();
    await Validator.validate(map, rules());

    if (primaryKey != null && map.containsKey(primaryKey)) {
      await connection.query(
        'UPDATE `$table` SET ${map.keys.where((k) => k != primaryKey).map((k) => '`$k` = ?').join(', ')} WHERE `$primaryKey` = ?',
        [
          ...map.entries.where((e) => e.key != primaryKey).map((e) => e.value),
          map[primaryKey]
        ],
      );
    } else {
      await connection.query(
        'INSERT INTO `$table` (${map.keys.map((k) => '`$k`').join(', ')}) VALUES (${List.filled(map.length, '?').join(', ')})',
        map.values.toList(),
      );
    }
  }

  static Future<Results> rawQuery(String sql, [List<Object?>? values]) async {
    return await connection.query(sql, values);
  }

  static Future<Model?> find(
    Model model,
    dynamic id,
    Model Function(Map<String, dynamic>) fromMap,
  ) async {
    final table = model.table;
    final result = await connection.query(
      'SELECT * FROM `$table` WHERE `id` = ? LIMIT 1',
      [id],
    );
    if (result.isNotEmpty) {
      return fromMap(result.first.fields);
    }
    return null;
  }

  static Future<List<Model>> findAll(
    String table,
    Model Function(Map<String, dynamic>) fromMap,
  ) async {
    final results = await connection.query('SELECT * FROM `$table`');
    return results.map((row) => fromMap(row.fields)).toList();
  }

  static Future<void> delete(String table, dynamic id) async {
    await connection.query('DELETE FROM `$table` WHERE `id` = ?', [id]);
  }

  String _inferTableName() {
    final className = runtimeType.toString();
    return _toSnakeCase(_pluralize(className));
  }

  String _toSnakeCase(String input) {
    return input.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return "_" + match.group(0)!.toLowerCase();
    }).replaceFirst('_', '');
  }

  String _pluralize(String word) {
    if (word.endsWith('y')) {
      return word.substring(0, word.length - 1) + 'ies';
    }
    return word + 's';
  }
}
