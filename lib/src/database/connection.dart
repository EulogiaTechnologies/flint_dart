import 'package:flint_dart/src/env_parser.dart';
import 'package:mysql1/mysql1.dart';

class DB {
  static MySqlConnection? _connection;
  static bool _isInitialized = false;

  // Option 1: Manual configuration
  static Future<MySqlConnection> connect({
    required String host,
    required int port,
    required String user,
    required String password,
    required String db,
  }) async {
    _connection = await _createConnection(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );
    _isInitialized = true;
    return _connection!;
  }

  // Option 2: Auto-configure from .env
  static Future<MySqlConnection> autoConnect() async {
    await FlintEnv.load(); // Load .env file

    _connection = await _createConnection(
      host: FlintEnv.get('DB_HOST', 'localhost'),
      port: FlintEnv.getInt('DB_PORT', 3306),
      user: FlintEnv.get('DB_USER', 'root'),
      password: FlintEnv.get('DB_PASSWORD', ''),
      db: FlintEnv.get('DB_NAME', 'flint_db'),
    );
    _isInitialized = true;
    return _connection!;
  }

  static Future<MySqlConnection> _createConnection({
    required String host,
    required int port,
    required String user,
    required String password,
    required String db,
  }) async {
    return await MySqlConnection.connect(
      ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: db,
      ),
    );
  }

  static MySqlConnection get instance {
    if (!_isInitialized) {
      throw Exception(
          "Database not initialized. Call DB.connect() or DB.autoConnect() first.");
    }
    if (_connection == null) {
      throw Exception(
          "Database connection failed. Check your connection parameters.");
    }
    return _connection!;
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
    _isInitialized = false;
  }
}
