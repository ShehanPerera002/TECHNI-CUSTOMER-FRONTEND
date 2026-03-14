import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_customer_profile_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  void _reloadProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  ImageProvider? _profileImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }

    final value = imagePath.trim();

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }

    final file = File(value);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }

  Widget _infoTile({required String label, required String value}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditScreen(Map<String, dynamic> data) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditCustomerProfileScreen(initialData: data),
      ),
    );

    if (result == true) {
      _reloadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load profile'),
            );
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text('Profile not found'),
            );
          }

          final image = _profileImageProvider(data['ProfileImage'] as String?);
          final name = (data['fullName'] as String?)?.trim();
          final email = (data['email'] as String?)?.trim();
          final birthDate = (data['birthDate'] as String?)?.trim();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.white,
                  backgroundImage: image,
                  child: image == null
                      ? const Icon(Icons.person, size: 58, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 28),
                _infoTile(label: 'Name', value: name?.isNotEmpty == true ? name! : '-'),
                _infoTile(label: 'Email', value: email?.isNotEmpty == true ? email! : '-'),
                _infoTile(
                  label: 'Birthday',
                  value: birthDate?.isNotEmpty == true ? birthDate! : '-',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _openEditScreen(data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Edit Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      foregroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
