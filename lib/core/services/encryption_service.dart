import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // Encrypts text using a derived key from passphrase
  String encrypt(String plaintext, String passphrase) {
    final keyBytes = sha256.convert(utf8.encode(passphrase)).bytes;
    final key = Key(Uint8List.fromList(keyBytes));
    
    // Generate a secure random Initialization Vector (IV)
    final iv = IV.fromSecureRandom(16);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    // Return combined IV and ciphertext, separated by a colon
    return '${iv.base64}:${encrypted.base64}';
  }

  // Decrypts ciphertext using a derived key from passphrase
  String decrypt(String combinedCiphertext, String passphrase) {
    final parts = combinedCiphertext.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid encrypted backup payload structure.');
    }

    final iv = IV.fromBase64(parts[0]);
    final ciphertextBase64 = parts[1];

    final keyBytes = sha256.convert(utf8.encode(passphrase)).bytes;
    final key = Key(Uint8List.fromList(keyBytes));

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(ciphertextBase64), iv: iv);

    return decrypted;
  }
}
