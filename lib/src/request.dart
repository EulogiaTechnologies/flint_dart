import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

/// Represents an HTTP request with convenient accessors for
/// method, headers, parameters, body, and other common features.
class Request {
  /// The original [HttpRequest] from Dart's `dart:io` server.
  final HttpRequest raw;

  /// Route parameters matched by the router (e.g. `/user/:id`).
  final Map<String, String> params;

  /// Constructs a [Request] with the raw [HttpRequest] and optional route [params].
  Request(this.raw, {Map<String, String>? params}) : params = params ?? {};

  /// The HTTP method (e.g. GET, POST, PUT).
  String get method => raw.method;

  /// The full request path (e.g. `/api/users/1`).
  String get path => raw.uri.path;

  /// All request headers as a [Map<String, String>].
  /// If a header has multiple values, they are joined with commas.
  Map<String, String> get headers {
    final Map<String, String> result = {};
    raw.headers.forEach((name, values) {
      result[name] = values.join(', ');
    });
    return result;
  }

  /// Query parameters from the URL as a [Map<String, String>].
  Map<String, String> get query => raw.uri.queryParameters;

  /// Reads and returns the raw request body as a [String].
  Future<String> body() => raw
      .transform(
        SystemEncoding().decoder as StreamTransformer<Uint8List, dynamic>,
      )
      .join();

  /// Returns the bearer token from the `Authorization` header if present.
  ///
  /// Example:
  /// ```
  /// Authorization: Bearer <token>
  /// ```
  String? get bearerToken {
    final auth = headers['authorization'];
    if (auth != null && auth.startsWith('Bearer ')) {
      return auth.substring(7);
    }
    return null;
  }

  /// Parses cookies from the `Cookie` header into a [Map<String, String>].
  Map<String, String> get cookies {
    final cookieHeader = raw.headers.value(HttpHeaders.cookieHeader);
    if (cookieHeader == null) return {};
    return Map.fromEntries(cookieHeader.split(';').map((cookie) {
      final parts = cookie.trim().split('=');
      return MapEntry(parts[0], parts[1]);
    }));
  }

  /// Parses the body as JSON and returns a [Map<String, dynamic>].
  ///
  /// Throws if the body is not valid JSON.
  Future<Map<String, dynamic>> json() async {
    final content = await body();
    return jsonDecode(content);
  }

  /// Parses the body as `application/x-www-form-urlencoded` data.
  ///
  /// Returns a [Map<String, String>] of form fields.
  Future<Map<String, String>> form() async {
    final content = await body();
    return Uri.splitQueryString(content);
  }
}
