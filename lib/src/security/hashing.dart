// File: lib/src/security/hashing.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Hashing {
  static String password(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static bool verify(String password, String hash) {
    return Hashing.password(password) == hash;
  }
}
