import 'package:encrypt/encrypt.dart';

class EncryptionUtils {
  static const String _keyString = "z7m2pE8vLx3qT9vK8WjH5rYpQbNcDxRfGhIjKlMnOpQ=";

  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty || encryptedText == "None" || encryptedText == "N/A") {
      return encryptedText;
    }

    try {
      final key = Key.fromBase64(_keyString);
      final fernet = Fernet(key);
      final encrypter = Encrypter(fernet);
      
      final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedText));
      return decrypted;
    } catch (e) {
      print("Decryption error: $e");
      return encryptedText;
    }
  }

  static String encrypt(String plainText) {
    if (plainText.isEmpty) return plainText;

    try {
      final key = Key.fromBase64(_keyString);
      final fernet = Fernet(key);
      final encrypter = Encrypter(fernet);
      
      final encrypted = encrypter.encrypt(plainText);
      return encrypted.base64;
    } catch (e) {
      print("Encryption error: $e");
      return plainText;
    }
  }
}
