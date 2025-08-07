import 'dart:io';

import 'base_http_error.dart';

class ValidationError extends BaseHttpResponseErorr {
  ValidationError({
    required super.message,
    super.code = HttpStatus.unprocessableEntity,
  });
}
