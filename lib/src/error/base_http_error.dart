import 'package:flint_dart/src/response.dart';

class BaseHttpResponseErorr {
  final dynamic message;
  final RespondType responseType;
  final int code;

  const BaseHttpResponseErorr({
    required this.message,
    required this.code,
    this.responseType = RespondType.json,
  });
}
