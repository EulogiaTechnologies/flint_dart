// File: lib/src/middleware.dart
import 'router.dart';

abstract class Middleware {
  Handler handle(Handler next);
}
