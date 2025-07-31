import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Jwt {
  static const String _secretKey = 'your-secret-key';

  static String generateToken(
    Map<String, dynamic> payload, {
    Duration expiry = const Duration(hours: 1),
  }) {
    final jwt = JWT(payload);
    return jwt.sign(SecretKey(_secretKey), expiresIn: expiry);
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }
}
