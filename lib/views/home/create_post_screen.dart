import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../services/cloudinary_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String? groupId;
  const CreatePostScreen({super.key, this.groupId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  final _cloudinary = CloudinaryService();

  final List<Uint8List> _imageBytes = [];
  final List<String> _imageNames = [];
  final List<Uint8List> _fileBytes = [];
  final List<String> _fileNames = [];
  bool _uploading = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    for (final img in picked) {
      final bytes = await img.readAsBytes();
      setState(() {
        _imageBytes.add(bytes);
        _imageNames.add(img.name);
      });
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      for (final f in result.files) {
        if (f.bytes != null) {
          setState(() {
            _fileBytes.add(f.bytes!);
            _fileNames.add(f.name);
          });
        }
      }
    }
  }

  Future<void> _submit() async {
    if (_contentCtrl.text.trim().isEmpty &&
        _imageBytes.isEmpty &&
        _fileBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post cannot be empty')));
      return;
    }

    setState(() => _uploading = true);

    try {
      final auth = context.read<AppAuthProvider>();
      final feed = context.read<FeedProvider>();

      // Upload images to Cloudinary
      final imageUrls = <String>[];
      for (int i = 0; i < _imageBytes.length; i++) {
        final url = await _cloudinary.uploadBytes(
          _imageBytes[i],
          _imageNames[i],
          folder: 'posts',
        );
        if (url != null) imageUrls.add(url);
      }

      // Upload files to Cloudinary
      final fileUrls = <String>[];
      final uploadedFileNames = <String>[];
      for (int i = 0; i < _fileBytes.length; i++) {
        final url = await _cloudinary.uploadBytes(
          _fileBytes[i],
          _fileNames[i],
          folder: 'post_files',
        );
        if (url != null) {
          fileUrls.add(url);
          uploadedFileNames.add(_fileNames[i]);
        }
      }

      final ok = await feed.createPost(
        authorId: auth.user!.id,
        authorName: auth.user!.name,
        authorPhotoUrl: auth.user!.photoUrl,
        content: _contentCtrl.text.trim(),
        imageUrls: imageUrls,
        fileUrls: fileUrls,
        fileNames: uploadedFileNames,
        groupId: widget.groupId,
      );

      if (mounted) {
        if (ok) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(feed.error ?? 'Failed to post')));
        }
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: _uploading ? null : _submit,
            child: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Post',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Image previews
            if (_imageBytes.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageBytes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_imageBytes[i],
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _imageBytes.removeAt(i);
                            _imageNames.removeAt(i);
                          }),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close,
                                size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // File chips
            ..._fileNames.asMap().entries.map((e) => Chip(
                  label: Text(e.value, overflow: TextOverflow.ellipsis),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() {
                    _fileBytes.removeAt(e.key);
                    _fileNames.removeAt(e.key);
                  }),
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Photos'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Files'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
