// lib/src/cli/make_model_command.dart
import 'dart:io';

import 'package:flint_dart/src/cli/commands.dart';

class MakeModelCommand extends FlintCommand {
  MakeModelCommand() : super('make:model', 'Creates a new model class');

  @override
  Future<void> execute(List<String> args) async {
    if (args.isEmpty) {
      print('❌ Please provide a model name.');
      return;
    }

    final name = args[0];
    final className = _capitalize(name);
    final fileName = _toSnakeCase(name);

    final content = _generateModelTemplate(className, fileName);

    final dir = Directory('lib/app/models');
    if (!await dir.exists()) await dir.create(recursive: true);

    final file = File('${dir.path}/$fileName.dart');
    if (await file.exists()) {
      print('⚠️ Model $fileName.dart already exists.');
      return;
    }

    await file.writeAsString(content);
    print('✅ Model created: lib/app/models/$fileName.dart');
  }

  String _capitalize(String str) =>
      str.isEmpty ? str : '${str[0].toUpperCase()}${str.substring(1)}';

  String _toSnakeCase(String input) =>
      input.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
        return '${match.group(1)}_${match.group(2)}';
      }).toLowerCase();

  String _generateModelTemplate(String className, String fileName) {
    return '''
import 'package:flint_dart/src/orm/model.dart';
import 'package:flint_dart/src/orm/schema.dart';

class $className extends Model<$className> {
  int? id;

  // Define your fields here
  String? name;

  @override
  Table get table => Table(
    name: '${fileName.split('.').first}s',
    columns: [
      Column(name: 'id', type: ColumnType.integer, isPrimaryKey: true, isAutoIncrement: true),
      Column(name: 'name', type: ColumnType.string),
    ],
  );

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  @override
  $className fromMap(Map<String, dynamic> map) {
    return $className()
      ..id = map['id']
      ..name = map['name'];
  }
}
''';
  }
}
