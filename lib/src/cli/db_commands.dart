import 'dart:io';
import 'dart:isolate';
import 'package:flint_dart/src/cli/commands.dart';
import 'package:flint_dart/src/database/connection.dart';

List<String> _registeredSqlStrings = [];

class DBMigrateCommand extends FlintCommand {
  DBMigrateCommand() : super('migrate', 'Runs database migrations');

  @override
  Future<void> execute(List<String> args) async {
    print('🚀 Starting database migration...');

    try {
      await _runTableRegistry();
      await DB.autoConnect();

      if (_registeredSqlStrings.isEmpty) {
        print('❗️ No tables were registered. Please call registerTables().');
        return;
      }

      print('Found ${_registeredSqlStrings.length} tables. Migrating...');
      for (final sql in _registeredSqlStrings) {
        print('📄 Executing:\n$sql\n');
        await DB.execute(sql);
      }

      print('✅ Migration completed successfully.');
    } catch (e, st) {
      print('❌ Migration failed: $e');
      print(st);
    } finally {
      await DB.close();
    }
  }

  Future<void> _runTableRegistry() async {
    final appRoot = Directory.current.path;
    final registryPath = '$appRoot/lib/src/config/table_registry.dart';
    final registryFile = File(registryPath);

    if (!registryFile.existsSync()) {
      throw Exception('❌ Could not find table_registry.dart.');
    }

    final receivePort = ReceivePort();

    await Isolate.spawnUri(
      registryFile.uri,
      [],
      receivePort.sendPort,
      packageConfig: Uri.file('$appRoot/.dart_tool/package_config.json'),
    );

    final sqlList = await receivePort.first as List<String>;
    _registeredSqlStrings = sqlList;
  }
}
