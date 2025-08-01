// File: lib/src/orm/model.dart
import 'package:flint_dart/src/database/connection.dart';
import 'package:flint_dart/src/orm/schema.dart';
import 'package:mysql1/mysql1.dart';
import 'query_builder.dart';
import '../validation/validator.dart';

abstract class Model<T extends Model<T>> {
  // Model state tracking
  bool _existsInDb = false;
  bool get existsInDatabase => _existsInDb;

  // Model configuration
  Table get table;

  String get primaryKey => 'id';
  bool get timestamps => true;

  // Timestamps
  DateTime? _createdAt;
  DateTime? _updatedAt;
  DateTime? get createdAt => _existsInDb ? _createdAt : null;
  DateTime? get updatedAt => _existsInDb ? _updatedAt : null;

  // CRUD operations
  Map<String, dynamic> toMap();
  T fromMap(Map<String, dynamic> map);

  // Validation rules
  Map<String, String> rules() => {};

  // Connection management uses your existing DB class
  static MySqlConnection get connection => DB.instance;

  static QueryBuilder query<T extends Model<T>>(T model) {
    return QueryBuilder(
      model.table.name,
      connection,
    );
  }

  // Full CRUD Operations
  Future<void> save() async {
    final map = toMap();
    await Validator.validate(map, rules());

    if (_existsInDb) {
      await update(map);
    } else {
      await insert(map);
    }
  }

  Future<void> insert(Map<String, dynamic> map) async {
    if (timestamps) {
      final now = DateTime.now();
      map['created_at'] = now;
      map['updated_at'] = now;
    }

    final result = await connection.query(
      'INSERT INTO `${table.name}` (${map.keys.map((k) => '`$k`').join(', ')}) '
      'VALUES (${List.filled(map.length, '?').join(', ')})',
      map.values.toList(),
    );

    if (primaryKey == 'id' && result.insertId != null) {
      (this as dynamic).id = result.insertId;
    }

    _existsInDb = true;
    if (timestamps) {
      _createdAt = map['created_at'];
      _updatedAt = map['updated_at'];
    }
  }

  Future<void> update(Map<String, dynamic> map) async {
    if (!_existsInDb) {
      throw StateError('Cannot update a model that doesn\'t exist in database');
    }

    if (timestamps) {
      map['updated_at'] = DateTime.now();
    }

    await connection.query(
      'UPDATE `${table.name}` SET '
      '${map.keys.where((k) => k != primaryKey).map((k) => '`$k` = ?').join(', ')} '
      'WHERE `$primaryKey` = ?',
      [
        ...map.entries.where((e) => e.key != primaryKey).map((e) => e.value),
        map[primaryKey]
      ],
    );

    if (timestamps) {
      _updatedAt = map['updated_at'];
    }
  }

  Future<void> delete() async {
    if (!_existsInDb) {
      throw StateError('Cannot delete a model that doesn\'t exist in database');
    }

    final map = toMap();
    await connection.query(
      'DELETE FROM `${table.name}` WHERE `$primaryKey` = ?',
      [map[primaryKey]],
    );

    _existsInDb = false;
  }

  Future<void> refresh() async {
    if (!_existsInDb) {
      throw StateError(
          'Cannot refresh a model that doesn\'t exist in database');
    }

    final map = toMap();
    final result = await connection.query(
      'SELECT * FROM `${table.name}` WHERE `$primaryKey` = ? LIMIT 1',
      [map[primaryKey]],
    );

    if (result.isEmpty) {
      throw StateError('Record no longer exists in database');
    }

    final refreshed = fromMap(result.first.fields);
    copyValues(refreshed as T);
  }

  // Query Operations
  static Future<T?> find<T extends Model<T>>(dynamic id, T model) async {
    final result = await connection.query(
      'SELECT * FROM `${model.table.name}` WHERE `${model.primaryKey}` = ? LIMIT 1',
      [id],
    );

    if (result.isEmpty) return null;

    final instance = model.fromMap(result.first.fields);
    (instance as dynamic)._existsInDb = true;

    if (model.timestamps) {
      (instance as dynamic)._createdAt = result.first['created_at'];
      (instance as dynamic)._updatedAt = result.first['updated_at'];
    }

    return instance as T;
  }

  static Future<List<T>> all<T extends Model<T>>(T model) async {
    final results = await connection.query(
      'SELECT * FROM `${model.table.name}`',
    );

    return results.map((r) {
      final instance = model.fromMap(r.fields);
      (instance as dynamic)._existsInDb = true;

      if (model.timestamps) {
        (instance as dynamic)._createdAt = r['created_at'];
        (instance as dynamic)._updatedAt = r['updated_at'];
      }

      return instance as T;
    }).toList();
  }

  static Future<List<T>> where<T extends Model<T>>({
    required T model,
    required String column,
    required dynamic value,
    String? operator,
    int? limit,
    int? offset,
    String? orderBy,
    bool orderDesc = false,
  }) async {
    final op = operator ?? '=';
    var query = 'SELECT * FROM `${model.table.name}` WHERE `$column` $op ?';

    if (orderBy != null) {
      query += ' ORDER BY `$orderBy` ${orderDesc ? 'DESC' : 'ASC'}';
    }

    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final results = await connection.query(query, [value]);

    return results.map((r) {
      final instance = model.fromMap(r.fields);
      (instance as dynamic)._existsInDb = true;

      if (model.timestamps) {
        (instance as dynamic)._createdAt = r['created_at'];
        (instance as dynamic)._updatedAt = r['updated_at'];
      }

      return instance as T;
    }).toList();
  }

  // Utility Methods
  void copyValues(T other) {
    final otherMap = other.toMap();
    for (final key in toMap().keys) {
      if (otherMap.containsKey(key)) {
        (this as dynamic).key = otherMap[key];
      }
    }
    _existsInDb = other._existsInDb;
    _createdAt = other._createdAt;
    _updatedAt = other._updatedAt;
  }
}
