import 'dart:io';

import 'base_http_error.dart';

class Unauthenticated extends BaseHttpResponseErorr {
  Unauthenticated(
      {required super.message,
      super.code = HttpStatus.unauthorized,
      super.responseType});
}
