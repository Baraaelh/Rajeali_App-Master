import 'dart:convert';

import 'package:crypto/crypto.dart';

class CryptoService {
  CryptoService({required String secret}) : _secret = secret;

  final String _secret;

  String encrypt(String value) {
    final List<int> input = utf8.encode(value);
    final List<int> key = utf8.encode(_secret);
    final List<int> output = List<int>.generate(
      input.length,
      (int index) => input[index] ^ key[index % key.length],
    );
    return base64UrlEncode(output);
  }

  String decrypt(String value) {
    final List<int> input = base64Url.decode(value);
    final List<int> key = utf8.encode(_secret);
    final List<int> output = List<int>.generate(
      input.length,
      (int index) => input[index] ^ key[index % key.length],
    );
    return utf8.decode(output);
  }

  String hash(String value) {
    return sha256.convert(utf8.encode('$value::$_secret')).toString();
  }
}

