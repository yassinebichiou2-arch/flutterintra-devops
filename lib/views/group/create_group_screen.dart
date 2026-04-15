import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isPrivate = false;
  File? _cover;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _cover = File(img.path));
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AppAuthProvider>();
    final groupProv = context.read<GroupProvider>();
    final group = await groupProv.createGroup(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      adminId: auth.user!.id,
      isPrivate: _isPrivate,
      coverImage: _cover,
    );
    if (mounted) {
      if (group != null) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(groupProv.error ?? 'Failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProv = context.watch<GroupProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickCover,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    image: _cover != null
                        ? DecorationImage(
                            image: FileImage(_cover!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _cover == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 40, color: Colors.grey),
                            Text('Add Cover Image',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 14),
              SwitchListTile(
                title: const Text('Private Group'),
                subtitle: const Text('Only members can see posts'),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: groupProv.loading ? null : _create,
                child: groupProv.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




