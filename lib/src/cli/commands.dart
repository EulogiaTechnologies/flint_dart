// lib/src/cli/commands.dart
abstract class FlintCommand {
  final String name;
  final String description;

  FlintCommand(this.name, this.description);

  Future<void> execute(List<String> args);
}

class RunServerCommand extends FlintCommand {
  RunServerCommand() : super('run', 'Runs the development server');

  @override
  Future<void> execute(List<String> args) async {
    // Implementation for running server...
  }
}

class DBMigrateCommand extends FlintCommand {
  DBMigrateCommand() : super('migrate', 'Runs database migrations');

  @override
  Future<void> execute(List<String> args) async {
    // Implementation for migrations...
  }
}
