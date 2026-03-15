import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../core/cloudinary_service.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? selectedDate;
  File? _selectedImage;
  String? _phone;
  String? _prefilledEmail;

  bool _isFormValid = false;
  bool _isSaving = false;
  bool _isPickingImage = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;
  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);
    _birthDateController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
  }

  bool _isPasswordValid(String password) {
    final String value = password.trim();
    final bool hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final bool hasNumber = RegExp(r'\d').hasMatch(value);
    final bool hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(value);
    return value.isNotEmpty &&
        value.length <= 8 &&
        hasLetter &&
        hasNumber &&
        hasSpecial;
  }

  Widget _buildPasswordRequirements() {
    final String pw = _passwordController.text.trim();
    final bool hasMaxLen = pw.isNotEmpty && pw.length <= 8;
    final bool hasLetter = RegExp(r'[A-Za-z]').hasMatch(pw);
    final bool hasNumber = RegExp(r'\d').hasMatch(pw);
    final bool hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(pw);

    Widget req(String label, bool met) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: met ? Colors.green : const Color(0xFFD1D5DB),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: met ? Colors.green : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        req("Maximum 8 characters", hasMaxLen),
        req("Include a letter", hasLetter),
        req("Include a number", hasNumber),
        req("Include a special character", hasSpecial),
      ],
    );
  }

  void _validateForm() {
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    bool isValid =
        _nameController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _emailController.text.contains("@") &&
        _isPasswordValid(password) &&
        confirmPassword == password &&
        _addressController.text.trim().isNotEmpty &&
        _selectedImage != null;

    setState(() {
      _isFormValid = isValid;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _phone = args['phone'] as String?;
      final email = args['email'] as String?;
      if (email != null && email.isNotEmpty && _emailController.text.isEmpty) {
        _prefilledEmail = email;
        _emailController.text = email;
      }
    }

    _argsLoaded = true;
  }

  // Date Picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Image Picker
  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _validateForm();
      }
    } on PlatformException catch (error) {
      debugPrint('[ImagePicker] pickImage skipped: ${error.message}');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      } else {
        _isPickingImage = false;
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_isFormValid || _isSaving) return;

    if (!_isPasswordValid(_passwordController.text)) {
      setState(() {
        _errorText =
            'Password must be max 8 characters and include letters, numbers, and special characters.';
      });
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _errorText = 'Password and confirm password do not match.';
      });
      return;
    }

    if ((_phone == null || _phone!.isEmpty) &&
        (_prefilledEmail == null || _prefilledEmail!.isEmpty)) {
      setState(() {
        _errorText = 'Phone number or email is missing. Please sign in again.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;
      User? authUser = FirebaseAuth.instance.currentUser;

      // If not signed in or signed in anonymously, create a new user with email/password
      if (authUser == null || (authUser.isAnonymous)) {
        try {
          final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          authUser = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // If email already in use, try to sign in
            final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            authUser = userCredential.user;
          } else if (e.code == 'weak-password') {
            if (!mounted) return;
            setState(() {
              _errorText = 'Please use a stronger password.';
            });
            return;
          } else if (e.code == 'invalid-email') {
            if (!mounted) return;
            setState(() {
              _errorText = 'Please enter a valid email address.';
            });
            return;
          } else if (e.code == 'operation-not-allowed') {
            if (!mounted) return;
            setState(() {
              _errorText = 'Email/password sign-in is disabled in Firebase Authentication.';
            });
            return;
          } else {
            rethrow;
          }
        }
      }

      if (authUser == null) {
        if (!mounted) return;
        setState(() {
          _errorText = 'Failed to initialize user identity.';
        });
        return;
      }

      if (_selectedImage == null) {
        if (!mounted) return;
        setState(() {
          _errorText = 'Please upload a profile image.';
        });
        return;
      }

      final uid = authUser.uid;
      final imageUrl = await CloudinaryService.uploadCustomerImage(
        _selectedImage!,
      );

      final profileData = <String, dynamic>{
        'ProfileImage': imageUrl,
        'address': _addressController.text.trim(),
        'birthDate': selectedDate != null
            ? '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
            : _birthDateController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'email': email,
        'emailLower': email.toLowerCase(),
        'fullName': _nameController.text.trim(),
        'isVerified': true,
        'latitude': 0.0,
        'longitude': 0.0,
        'password': _passwordController.text,
        'phone': (_phone != null && _phone!.isNotEmpty) ? _phone! : '',
        'role': 'customer',
        'uid': uid,
      };

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .set(profileData, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText =
            error.message ?? 'Failed to save profile. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to save profile. Please try again.';
      });
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
    _birthDateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "Create Your Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // 📸 Profile Image
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _isPickingImage ? null : _pickImage,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  image: _selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(_selectedImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _selectedImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: _isPickingImage ? null : _pickImage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF2563EB),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Center(
                        child: Text(
                          "Upload Profile Photo",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Full Name
                      const Text(
                        "Full Name",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: "Enter your full name",
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      // Birth Date
                      const Text(
                        "Birth Date",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _birthDateController,
                            hint: "Select your birth date",
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Email
                      const Text(
                        "Email Address",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: "Enter your email address",
                        icon: Icons.mail_outline,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "Enter your password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        inputFormatters: [LengthLimitingTextInputFormatter(8)],
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      _buildPasswordRequirements(),

                      const SizedBox(height: 20),

                      const Text(
                        "Confirm Password",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: "Re-enter your password",
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        inputFormatters: [LengthLimitingTextInputFormatter(8)],
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Location
                      const Text(
                        "Your Location",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2563EB),
                            width: 1.5,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF2563EB),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Use your current location",
                                  style: TextStyle(color: Color(0xFF2563EB)),
                                ),
                              ),
                              Icon(
                                Icons.arrow_circle_right,
                                color: Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildTextField(
                        controller: _addressController,
                        hint: "or Enter address manually",
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 Fixed Bottom Button
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 25,
                top: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  GestureDetector(
                    onTap: _isFormValid && !_isSaving ? _saveProfile : null,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: _isFormValid && !_isSaving
                            ? const Color(0xFF2563EB)
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _isSaving ? 'Saving...' : 'Save Profile',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
