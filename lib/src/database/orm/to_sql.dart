import 'dart:async';
import 'package:flint_dart/schema.dart';
import 'package:flint_dart/src/database/connection.dart';
import 'package:mysql_dart/exception.dart';
import 'package:mysql_dart/mysql_dart.dart';

extension TableSQL on Table {
  String toSQL() {
    final buffer = StringBuffer();
    buffer.write('CREATE TABLE `$name` (\n');

    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      buffer.write('  `${col.name}` ${col.sqlType()}');

      if (!col.isNullable) buffer.write(' NOT NULL');
      if (col.isAutoIncrement) buffer.write(' AUTO_INCREMENT');
      if (col.defaultValue != null) {
        buffer.write(' DEFAULT ${_formatDefaultValue(col.defaultValue)}');
      }
      if (col.isPrimaryKey) buffer.write(' PRIMARY KEY');

      if (i < columns.length - 1 || foreignKeys.isNotEmpty) buffer.write(',');
      buffer.write('\n');
    }

    for (int i = 0; i < foreignKeys.length; i++) {
      final fk = foreignKeys[i];
      buffer.write(
          '  FOREIGN KEY (`${fk.column}`) REFERENCES `${fk.referenceTable}`(`${fk.referenceColumn}`)');
      buffer.write(' ON DELETE ${fk.onDelete}');
      buffer.write(' ON UPDATE ${fk.onUpdate}');

      if (i < foreignKeys.length - 1) buffer.write(',');
      buffer.write('\n');
    }

    buffer.write(');');
    return buffer.toString();
  }

  String _formatDefaultValue(dynamic value) {
    if (value is String) return "'$value'";
    if (value is bool) return value ? 'TRUE' : 'FALSE';
    return value.toString();
  }
}

extension TableMigration on Table {
  List<String> compareWith(Table updated) {
    final oldCols = {for (var c in columns) c.name: c};
    final newCols = {for (var c in updated.columns) c.name: c};
    final changes = <String>[];

    for (var name in newCols.keys) {
      if (!oldCols.containsKey(name)) {
        final c = newCols[name]!;
        changes.add(
            'ADD COLUMN `${c.name}` ${c.sqlType()} ${c.isNullable ? "" : "NOT NULL"}');
      } else if (oldCols[name] != newCols[name]) {
        final c = newCols[name]!;
        changes.add(
            'MODIFY COLUMN `${c.name}` ${c.sqlType()} ${c.isNullable ? "" : "NOT NULL"}');
      }
    }

    for (var name in oldCols.keys) {
      if (!newCols.containsKey(name)) {
        changes.add('DROP COLUMN `$name`');
      }
    }

    return changes;
  }

  Future<List<Column>> getMySQLColumns() async {
    final MySQLConnection conn = DB.instance;
    final resultSet = await conn.execute("SHOW COLUMNS FROM `$name`");
    final rows = resultSet.rows;

    return rows.map((row) {
      final data = row.assoc();
      return Column(
        name: data['Field'] as String,
        type: TableMySQL._inferColumnType(data['Type'] as String),
        length: TableMySQL._extractLength(data['Type'] as String),
        isPrimaryKey: data['Key'] == 'PRI',
        isAutoIncrement:
            (data['Extra'] as String?)?.contains('auto_increment') ?? false,
        isNullable: (data['Null'] as String).toUpperCase() == 'YES',
        defaultValue: data['Default'],
      );
    }).toList();
  }
}

extension ColumnSQL on Column {
  String sqlType() {
    switch (type) {
      case ColumnType.string:
        return 'VARCHAR($length)';
      case ColumnType.text:
        return 'TEXT';
      case ColumnType.integer:
        return 'INT';
      case ColumnType.double:
        return 'DOUBLE';
      case ColumnType.boolean:
        return 'BOOLEAN';
      case ColumnType.datetime:
        return 'DATETIME';
      case ColumnType.timestamp:
        return 'TIMESTAMP';
    }
  }
}

extension TableMySQL on Table {
  static Table fromMySQL(String tableName, List<ResultSetRow> rows) {
    final columns = rows.map((row) {
      final data = row.assoc();
      return Column(
        name: data['Field'] as String,
        type: _inferColumnType(data['Type'] as String),
        length: _extractLength(data['Type'] as String),
        isPrimaryKey: data['Key'] == 'PRI',
        isAutoIncrement:
            (data['Extra'] as String?)?.contains('auto_increment') ?? false,
        isNullable: (data['Null'] as String).toUpperCase() == 'YES',
        defaultValue: data['Default'],
      );
    }).toList();

    return Table(name: tableName, columns: columns);
  }

  static ColumnType _inferColumnType(String typeStr) {
    final lower = typeStr.toLowerCase();
    if (lower.startsWith('int')) return ColumnType.integer;
    if (lower.startsWith('varchar') || lower.startsWith('char'))
      return ColumnType.string;
    if (lower.startsWith('text')) return ColumnType.text;
    if (lower.startsWith('bool')) return ColumnType.boolean;
    if (lower.startsWith('double') || lower.startsWith('float'))
      return ColumnType.double;
    if (lower.contains('datetime')) return ColumnType.datetime;
    if (lower.contains('timestamp')) return ColumnType.timestamp;
    return ColumnType.string;
  }

  static int _extractLength(String typeStr) {
    final regExp = RegExp(r'\((\d+)\)');
    final match = regExp.firstMatch(typeStr);
    return match != null ? int.parse(match.group(1)!) : 255;
  }
}

Future<Table?> getTableSchema(String tableName) async {
  MySQLConnection? conn;

  try {
    conn = await DB.autoConnect();

    // await conn.execute('DROP TABLE IF EXISTS `$tableName`');
    // await conn.execute('''
    //   CREATE TABLE `$tableName` (
    //     id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    //     name VARCHAR(255),
    //     email VARCHAR(255),
    //     age INT
    //   )
    // ''');

    final resultSet = await conn.execute("SHOW COLUMNS FROM `$tableName`");
    return TableMySQL.fromMySQL(tableName, resultSet.rows.toList());
  } on MySQLClientException catch (e) {
    throw Exception("❌ MySQL Error (${e.message}): ${e.message}");
  } finally {
    await conn?.close();
  }
}
