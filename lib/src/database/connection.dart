import 'package:flint_dart/src/env_parser.dart';
import 'package:mysql_dart/mysql_dart.dart';

/// Provides static methods for managing a MySQL database connection.
class DB {
  /// Internal singleton MySQL connection instance.
  static MySQLConnection? _connection;

  /// Tracks whether the connection has been initialized.
  static bool _isInitialized = false;


  

  /// Manually establish connection using config values.
  static Future<MySQLConnection> connect({
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

  /// Automatically connect using environment variables.
  static Future<MySQLConnection> autoConnect() async {
    await FlintEnv.load();

    final host = FlintEnv.get('DB_HOST', 'localhost');
    final port = FlintEnv.getInt('DB_PORT', 3306);
    final user = FlintEnv.get('DB_USER', 'flint_sample');
    final password = FlintEnv.get('DB_PASSWORD', 'flint_sample');
    final db = FlintEnv.get('DB_NAME', 'flint_sample');

    print("🔍 ENV VALUES LOADED:");
    print(" - DB_HOST: $host");
    print(" - DB_PORT: $port");
    print(" - DB_USER: $user");
    print(" - DB_PASSWORD: $password");
    print(" - DB_NAME: $db");

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

  /// Internal helper to create a new MySQL connection.
  static Future<MySQLConnection> _createConnection({
    required String host,
    required int port,
    required String user,
    required String password,
    required String db,
  }) async {
    try {
      print("🔌 Connecting to MySQL at $host:$port as $user to DB $db...");
      final conn = await MySQLConnection.createConnection(
        host: host,
        port: port,
        userName: user,
        password: password,
        databaseName: db,
      );
      await conn.connect();
      print("✅ Connection successful.");
      return conn;
    } catch (e, st) {
      print("❌ Failed to connect to MySQL:");
      print("   Error: $e");
      print("   Stacktrace: $st");
      rethrow;
    }
  }

  /// Execute a raw SQL query (non-select).
  static Future<void> execute(String sql) async {
    final conn = instance;
    try {
      await conn.execute(sql);
    } catch (e, st) {
      print("❌ SQL execution failed: $e");
      print("📄 SQL: $sql");
      print("📍 Stacktrace: $st");
      rethrow;
    }
  }

  /// Return the active connection instance.
  static MySQLConnection get instance {
    if (!_isInitialized || _connection == null) {
      throw Exception(
        "Database not initialized. Call DB.connect() or DB.autoConnect() first.",
      );
    }
    return _connection!;
  }

  /// Closes and resets the database connection.
  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
    _isInitialized = false;
  }
}
