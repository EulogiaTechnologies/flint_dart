import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Request {
  final HttpRequest raw;

  Request(this.raw);

  String get method => raw.method;
  String get path => raw.uri.path;

  Future<String> body() => raw
      .transform(
        SystemEncoding().decoder as StreamTransformer<Uint8List, dynamic>,
      )
      .join();
}
