import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/cloudinary_service.dart';

class EditCustomerProfileScreen extends StatefulWidget {
  const EditCustomerProfileScreen({
    super.key,
    required this.initialData,
  });

  final Map<String, dynamic> initialData;

  @override
  State<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  DateTime? _selectedDate;
  File? _selectedImage;
  String? _existingImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text =
        (widget.initialData['fullName'] as String?)?.trim() ?? '';
    _emailController.text = (widget.initialData['email'] as String?)?.trim() ?? '';

    final rawBirthDate = (widget.initialData['birthDate'] as String?)?.trim() ?? '';
    _birthDateController.text = rawBirthDate;
    _selectedDate = _tryParseBirthDate(rawBirthDate);

    _existingImagePath =
        (widget.initialData['ProfileImage'] as String?)?.trim().isNotEmpty == true
        ? (widget.initialData['ProfileImage'] as String).trim()
        : null;
  }

  DateTime? _tryParseBirthDate(String value) {
    if (value.isEmpty) return null;

    final parsedIso = DateTime.tryParse(value);
    if (parsedIso != null) return parsedIso;

    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDate() async {
    final initial = _selectedDate ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _birthDateController.text = _formatDate(picked);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  ImageProvider? _previewImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    if (_existingImagePath == null || _existingImagePath!.isEmpty) {
      return null;
    }

    if (_existingImagePath!.startsWith('http://') ||
        _existingImagePath!.startsWith('https://')) {
      return NetworkImage(_existingImagePath!);
    }

    final file = File(_existingImagePath!);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final birthDate = _birthDateController.text.trim();

    if (name.isEmpty || email.isEmpty || birthDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please sign in again.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = <String, dynamic>{
        'fullName': name,
        'email': email,
        'birthDate': birthDate,
      };

      if (_selectedImage != null) {
        final imageUrl = await CloudinaryService.uploadCustomerImage(
          _selectedImage!,
        );
        updated['ProfileImage'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .set(updated, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Failed to update profile'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _previewImage();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  backgroundImage: image,
                  child: image == null
                      ? const Icon(Icons.person, size: 54, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap image to change photo',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _textField(controller: _nameController, label: 'Name'),
              _textField(controller: _emailController, label: 'Email'),
              _textField(
                controller: _birthDateController,
                label: 'Birthday',
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
