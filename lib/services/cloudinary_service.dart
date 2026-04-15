import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String _cloudName = 'dk8cuvafx';
  static const String _uploadPreset = 'yassin';
  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload from File (mobile)
  Future<String?> uploadFile(File file, {String folder = 'flutterintra'}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  /// Upload from bytes (web)
  Future<String?> uploadBytes(
      Uint8List bytes, String filename, {String folder = 'flutterintra'}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String?;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
