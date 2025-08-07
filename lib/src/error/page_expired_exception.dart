import 'package:flint_dart/flint_dart.dart';

import 'base_http_error.dart';

class PageExpiredError extends BaseHttpResponseErorr {
  const PageExpiredError({
    super.message = '<center><h1>Page Expired (419)</h1></center>',
    super.code = 419,
    super.responseType = RespondType.html,
  });
}
