// File: lib/src/orm/query_builder.dart
import 'package:mysql1/mysql1.dart';

class QueryBuilder {
  final String table;
  final MySqlConnection connection;
  final List<String> _whereClauses = [];
  final List<Object?> _whereValues = [];
  int? _limit;
  int? _offset;
  String? _orderBy;

  QueryBuilder(this.table, this.connection);

  QueryBuilder where(String column, dynamic value, {String operator = '='}) {
    _whereClauses.add('`$column` $operator ?');
    _whereValues.add(value);
    return this;
  }

  QueryBuilder limit(int value) {
    _limit = value;
    return this;
  }

  QueryBuilder offset(int value) {
    _offset = value;
    return this;
  }

  QueryBuilder orderBy(String column, {bool descending = false}) {
    _orderBy = '`$column` ${descending ? 'DESC' : 'ASC'}';
    return this;
  }

  Future<Results> get() async {
    final query = StringBuffer('SELECT * FROM `$table`');

    if (_whereClauses.isNotEmpty) {
      query.write(' WHERE ${_whereClauses.join(' AND ')}');
    }

    if (_orderBy != null) {
      query.write(' ORDER BY $_orderBy');
    }

    if (_limit != null) {
      query.write(' LIMIT $_limit');
    }

    if (_offset != null) {
      query.write(' OFFSET $_offset');
    }

    return await connection.query(query.toString(), _whereValues);
  }
}
