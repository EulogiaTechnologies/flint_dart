import 'dart:io';
import 'package:flint_dart/flint_dart.dart';

import 'base_http_error.dart';

class RedirectError extends BaseHttpResponseErorr {
  RedirectError({
    super.message,
    super.code = HttpStatus.found,
    super.responseType = RespondType.html,
  });
}
