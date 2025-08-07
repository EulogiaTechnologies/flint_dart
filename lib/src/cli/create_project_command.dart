// Expanded CreateProjectCommand
import 'dart:io';

import 'package:flint_dart/src/cli/commands.dart';

class CreateProjectCommand extends FlintCommand {
  CreateProjectCommand() : super('create', 'Creates a new FlintDart project');

  @override
  Future<void> execute(List<String> args) async {
    final projectName = args.isNotEmpty ? args[0] : 'my_flint_app';
    final dir = Directory(projectName);

    if (await dir.exists()) {
      print('Error: Directory "$projectName" already exists');
      return;
    }

    await dir.create();
    print('Creating FlintDart project in ${dir.path}...');

    // Create basic project structure
    await _createFile('${dir.path}/pubspec.yaml', _pubspecContent(projectName));
    await _createFile('${dir.path}/lib/main.dart', _mainDartContent());
    await _createFile('${dir.path}/.gitignore', _gitignoreContent());
    await _createProjectStructure(dir.path); // ✅ Pass the path here

    print('Project created successfully!');
    print('To get started:\n'
        '  cd $projectName\n'
        '  dart pub get\n'
        '  flint run');
  }

  Future<void> _createFile(String path, String content) async {
    await File(path).writeAsString(content);
  }

  String _pubspecContent(String name) => '''
name: $name
description: A FlintDart application
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  flint_dart: ^1.0.0

''';

  String _mainDartContent() => '''
import 'package:flint_dart/flint_dart.dart';

void main() {
  final app = App();

  app.get('/', (req, res) async {
    res.send('Hello from FlintDart!');
  });

  app.listen(3000);
}

''';

  String _gitignoreContent() => '''
# Dart
.dart_tool/
.packages
.pub/
build/

# Environment files
.env
''';
}

Future<void> _createProjectStructure(String basePath) async {
  final folders = [
    'lib/src/controllers',
    'lib/src/models',
    'lib/src/routes',
    'lib/src/middleware',
    'lib/src/config',
    'lib/src/utils',
    'lib/src/services',
  ];

  for (final path in folders) {
    await Directory('$basePath/$path').create(recursive: true);
  }
}
