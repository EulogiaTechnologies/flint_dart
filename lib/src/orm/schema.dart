// lib/src/orm/schema.dart
class Table {
  final String name;
  final List<Column> columns;
  final List<Index> indexes;
  final List<ForeignKey> foreignKeys;

  Table({
    required this.name,
    required this.columns,
    this.indexes = const [],
    this.foreignKeys = const [],
  });
}

class Column {
  final String name;
  final ColumnType type;
  final bool isPrimaryKey;
  final bool isAutoIncrement;
  final bool isNullable;
  final dynamic defaultValue;

  Column({
    required this.name,
    required this.type,
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
    this.isNullable = false,
    this.defaultValue,
  });
}

enum ColumnType {
  integer,
  string,
  text,
  boolean,
  double,
  datetime,
  timestamp,
}

class Index {
  final String name;
  final List<String> columns;
  final bool isUnique;

  Index({required this.name, required this.columns, this.isUnique = false});
}

class ForeignKey {
  final String column;
  final String referenceTable;
  final String referenceColumn;
  final String onDelete;
  final String onUpdate;

  ForeignKey({
    required this.column,
    required this.referenceTable,
    required this.referenceColumn,
    this.onDelete = 'RESTRICT',
    this.onUpdate = 'RESTRICT',
  });
}
