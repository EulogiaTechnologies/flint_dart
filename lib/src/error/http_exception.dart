import 'dart:io';
import 'base_http_error.dart';

class HttpResponseErorr extends BaseHttpResponseErorr {
  HttpResponseErorr({
    super.message,
    super.code = HttpStatus.found,
  });
}
