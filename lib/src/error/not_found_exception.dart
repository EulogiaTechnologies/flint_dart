import 'dart:io';
import 'package:flint_dart/src/response.dart';
import 'base_http_error.dart';

class NotFoundException extends BaseHttpResponseErorr {
  NotFoundException({
    super.message = 'Not Fount 404',
    super.code = HttpStatus.notFound,
    super.responseType = RespondType.html,
  });
}
