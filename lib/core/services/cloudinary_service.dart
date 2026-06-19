import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryConfig {
  final String cloudName;
  final String? apiKey;
  final String? signatureUrl; // Backend endpoint to sign parameters (to avoid exposing apiSecret)
  final String? uploadPreset;  // For unsigned uploads

  CloudinaryConfig({
    required this.cloudName,
    this.apiKey,
    this.signatureUrl,
    this.uploadPreset,
  });
}

class CloudinaryService {
  final CloudinaryConfig _config;
  final http.Client _client;

  CloudinaryService(this._config, {http.Client? client}) 
      : _client = client ?? http.Client();

  /// Uploads a file (photo, document attachment, or database backup) to Cloudinary
  /// using secure signed uploads or restricted unsigned presets.
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String publicId,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/${_config.cloudName}/auto/upload'),
      );

      if (_config.uploadPreset != null) {
        // Restricted Unsigned Upload
        request.fields['upload_preset'] = _config.uploadPreset!;
        request.fields['folder'] = folder;
        request.fields['public_id'] = publicId;
      } else if (_config.signatureUrl != null && _config.apiKey != null) {
        // Secure Signed Upload
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        
        // 1. Fetch signature from backend signature server to keep API Secret secure
        final signatureResponse = await _client.post(
          Uri.parse(_config.signatureUrl!),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'timestamp': timestamp,
            'folder': folder,
            'public_id': publicId,
          }),
        );

        if (signatureResponse.statusCode != 200) {
          throw Exception('Failed to generate Cloudinary signature: ${signatureResponse.body}');
        }

        final signatureData = jsonDecode(signatureResponse.body);
        final signature = signatureData['signature'] as String;

        request.fields['api_key'] = _config.apiKey!;
        request.fields['timestamp'] = timestamp.toString();
        request.fields['folder'] = folder;
        request.fields['public_id'] = publicId;
        request.fields['signature'] = signature;
      } else {
        throw Exception('Cloudinary configuration error: Provide either uploadPreset or signatureUrl & apiKey.');
      }
      
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final response = await _client.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Cloudinary upload failed: $responseBody');
      }

      final responseData = jsonDecode(responseBody);
      return responseData['secure_url'] as String;
    } catch (e) {
      throw Exception('Cloudinary Service Error: $e');
    }
  }

  /// Backup specific JSON String upload to Cloudinary
  Future<String> uploadBackupString({
    required String backupJson,
    required String userId,
  }) async {
    // Write string to a temp file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/backup_$userId.json');
    await tempFile.writeAsString(backupJson);

    try {
      final url = await uploadFile(
        file: tempFile,
        folder: 'users/$userId/backups',
        publicId: 'backup',
      );
      return url;
    } finally {
      // Clean up local temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
