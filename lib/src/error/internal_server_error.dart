import 'dart:io';
import 'base_http_error.dart';

class InternalServerError extends BaseHttpResponseErorr {
  InternalServerError({
    required super.message,
    super.code = HttpStatus.internalServerError,
  });
}
