import 'package:flint_dart/flint_dart.dart';

typedef Handler = Future<void> Function(Request req, Response res);

class Route {
  final String method;
  final String path;
  final Handler handler;

  Route(this.method, this.path, this.handler);
}

class Router {
  final List<Route> _routes = [];
  List<Route> get routes => _routes;

  void add(String method, String path, Handler handler) {
    _routes.add(Route(method.toUpperCase(), path, handler));
  }

  Handler? match(String method, String path) {
    return _routes
        .firstWhere(
          (r) => r.method == method && r.path == path,
          orElse: () =>
              Route('', '', (req, res) async => res.send('404 Not Found')),
        )
        .handler;
  }
}
