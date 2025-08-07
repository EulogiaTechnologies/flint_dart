import 'dart:io';

import 'package:flint_dart/flint_dart.dart';
import 'package:flint_dart/src/error/base_http_error.dart';

class ForbiddenErorr extends BaseHttpResponseErorr {
  ForbiddenErorr({
    super.message = 'Forbidden',
    super.code = HttpStatus.forbidden,
    super.responseType = RespondType.json,
  });
}
