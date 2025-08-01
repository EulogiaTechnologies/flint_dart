import 'dart:io';
import 'middleware.dart';
import 'request.dart';
import 'response.dart';
import 'router.dart';

class App {
  String rootPath;
  App({this.rootPath = "bin"}) {
    // _initializeDatabase(); // Auto-init DB when app is created
  }

  final Router _router = Router();
  final List<Middleware> _middlewares = [];
  bool _dbInitialized = false;

  // await DB.connect();

  // Add a getter to check DB status
  bool get isDatabaseConnected => _dbInitialized;

  void get(String path, Handler handler) => _router.add('GET', path, handler);
  void post(String path, Handler handler) => _router.add('POST', path, handler);
  void put(String path, Handler handler) => _router.add('PUT', path, handler);
  void patch(String path, Handler handler) =>
      _router.add('PATCH', path, handler);
  void delete(String path, Handler handler) =>
      _router.add('DELETE', path, handler);

  void route(String method, String path, Handler handler) =>
      _router.add(method.toUpperCase(), path, handler);

  void use(Middleware middleware) => _middlewares.add(middleware);

  void mount(String prefix, void Function(App subApp) callback) {
    final subApp = App(rootPath: rootPath);
    callback(subApp);

    for (final route in subApp._router.routes) {
      _router.add(
        route.method,
        '$prefix${route.path == '/' ? '' : route.path}',
        route.handler,
      );
    }
  }

  Future<void> listen(int port) async {
    if (!_dbInitialized) {
      print('Warning: Database connection not established');
    }

    if (Platform.environment['FLINT_HOT'] != '1') {
      print('[FLINT] Starting with hot reload...');

      await Process.start(
        'dart',
        ['--enable-vm-service', 'run', 'flintdart:hot_reload', rootPath],
        environment: {'FLINT_HOT': '1'},
        mode: ProcessStartMode.inheritStdio,
      );

      exit(0);
    }

    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('Server running on http://localhost:$port');

    await for (var req in server) {
      final request = Request(req);
      final response = Response(req.response);
      final handler = _router.match(request.method, request.path);

      final pipeline = _middlewares.fold<Handler>(
        handler ?? ((req, res) async => res.send('404 Not Found', status: 404)),
        (prev, middleware) => middleware.handle(prev),
      );

      await pipeline(request, response);
      await req.response.close();
    }
  }
}
