import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _posCtrl;
  late final TextEditingController _bioCtrl;
  Uint8List? _photoBytes;
  String? _photoName;
  bool _uploading = false;
  final _cloudinary = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _posCtrl = TextEditingController(text: widget.user.position ?? '');
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _posCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoName = img.name;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _uploading = true);
    final auth = context.read<AppAuthProvider>();
    try {
      String? photoUrl = widget.user.photoUrl;
      if (_photoBytes != null && _photoName != null) {
        photoUrl = await _cloudinary.uploadBytes(
          _photoBytes!,
          _photoName!,
          folder: 'avatars',
        );
      }
      final ok = await auth.updateProfile(
        name: _nameCtrl.text.trim(),
        position: _posCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        photoUrl: photoUrl,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(auth.error ?? 'Update failed')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _uploading ? null : _save,
            child: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  _photoBytes != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: MemoryImage(_photoBytes!),
                        )
                      : UserAvatar(
                          photoUrl: widget.user.photoUrl,
                          name: widget.user.name,
                          radius: 50,
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _posCtrl,
              decoration: const InputDecoration(
                  labelText: 'Position',
                  prefixIcon: Icon(Icons.work_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 3,
              maxLength: 160,
              decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info_outlined),
                  hintText: 'Tell your team about yourself...'),
            ),
          ],
        ),
      ),
    );
  }
}
