// File: lib/src/response.dart
import 'dart:convert';
import 'dart:io';

class Response {
  final HttpResponse raw;

  Response(this.raw);

  /// Sends a plain text or custom content response.
  ///
  /// - [body]: The response body string.
  /// - [status]: The HTTP status code (default: 200).
  /// - [contentType]: The content type (default: 'text/plain').
  void send(
    String body, {
    int status = 200,
    String contentType = 'text/plain',
  }) {
    try {
      raw.statusCode = status;
      raw.headers.contentType = ContentType.parse(contentType);
      raw.write(body);
    } catch (e) {
      // Fallback error response in case of encoding issues or bad string
      raw.statusCode = 500;
      raw.headers.contentType = ContentType.text;
      raw.write('❌ Failed to send response: Invalid content.');
    }
  }

  /// Sends a JSON response with a map.
  ///
  /// - [data]: A map of data to be converted to JSON.
  /// - [status]: The HTTP status code (default: 200).
  void json(dynamic data, {int status = 200}) {
    try {
      // Ensure only serializable types are encoded
      final encoded = jsonEncode(data);

      raw.statusCode = status;
      raw.headers.contentType = ContentType.json;
      raw.write(encoded);
    } catch (e) {
      // Fallback response for encoding errors
      raw.statusCode = 500;
      raw.headers.contentType = ContentType.text;
      raw.write('❌ Failed to encode JSON response: ${e.runtimeType}');
      print('[Flint] JSON Error: $e');
    }
  }

  /// Sets the status code of the response without sending data.
  /// Useful for middleware or header-only responses.
  Response status(int code) {
    raw.statusCode = code;
    return this;
  }

  /// Sends a predefined status message with a common HTTP status code.
  /// This also closes the response automatically.
  void sendStatus(int code) {
    final message = _statusMessages[code] ?? 'Status';
    send(message, status: code);
    raw.close();
  }
}

/// Common HTTP status codes and their default messages
const Map<int, String> _statusMessages = {
  200: 'OK',
  201: 'Created',
  202: 'Accepted',
  204: 'No Content',
  301: 'Moved Permanently',
  302: 'Found',
  304: 'Not Modified',
  400: 'Bad Request',
  401: 'Unauthorized',
  403: 'Forbidden',
  404: 'Not Found',
  405: 'Method Not Allowed',
  409: 'Conflict',
  422: 'Unprocessable Entity',
  500: 'Internal Server Error',
  502: 'Bad Gateway',
  503: 'Service Unavailable',
};
