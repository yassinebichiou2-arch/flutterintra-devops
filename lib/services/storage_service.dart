import 'dart:io';
import 'dart:typed_data';
import 'cloudinary_service.dart';

class StorageService {
  final CloudinaryService _cloudinary = CloudinaryService();

  Future<String> uploadImage(File file, String folder) async {
    final url = await _cloudinary.uploadFile(file, folder: folder);
    return url ?? '';
  }

  Future<String> uploadImageBytes(
      Uint8List bytes, String filename, String folder) async {
    final url =
        await _cloudinary.uploadBytes(bytes, filename, folder: folder);
    return url ?? '';
  }

  Future<String> uploadFile(File file, String folder, String fileName) async {
    final url = await _cloudinary.uploadFile(file, folder: folder);
    return url ?? '';
  }

  Future<void> deleteFile(String url) async {
    // Cloudinary deletion requires API secret — skip for now
  }
}
