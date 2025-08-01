// bin/flint_cli.dart
import 'dart:io';

import 'package:flint_dart/src/cli/commands.dart';
import 'package:flint_dart/src/cli/create_project_command.dart';

final commands = {
  'create': CreateProjectCommand(),
  'run': RunServerCommand(),
  'migrate': DBMigrateCommand(),
  // Add more commands...
};

void main(List<String> args) async {
  if (args.isEmpty || !commands.containsKey(args[0])) {
    print('''
FlintDart CLI

Usage: flint <command> [options]

Available commands:
${commands.entries.map((e) => '  ${e.key.padRight(10)}${e.value.description}').join('\n')}
''');
    return;
  }

  try {
    await commands[args[0]]!.execute(args.sublist(1));
  } catch (e) {
    print('Error: $e');
    exitCode = 1;
  }
}
