import 'dart:isolate';
import 'package:flint_dart/schema.dart';

/// Call this in your `table_registry.dart` to register tables via isolate.
void runTableRegistry(List<Table> tables, [_, SendPort? sendPort]) async {
  if (sendPort == null) {
    print(
        "❌ Error: runTableRegistry must be called via the Flint CLI isolate.");
    return;
  }

  final diffs = [];

  for (final table in tables) {
    final existingTable = await getTableSchema(table.name);
    // final updated = existingTable.compareWith(table);
    // diffs.add(updated);
    print(existingTable?.toSQL());
  }

  // print(diffs);
  // sendPort.send(diffs as List<String>);
}
