import 'package:mysql1/mysql1.dart';

class DB {
  static MySqlConnection? _connection;

  static Future<MySqlConnection> connect({
    required String host,
    required int port,
    required String user,
    required String password,
    required String db,
  }) async {
    if (_connection == null) {
      final settings = ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: db,
      );
      _connection = await MySqlConnection.connect(settings);
    }
    return _connection!;
  }

  static MySqlConnection get instance {
    if (_connection == null) {
      throw Exception(
          "Database connection not initialized. Call DB.connect first.");
    }
    return _connection!;
  }
}
