import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _addressController = TextEditingController();

  DateTime? selectedDate;
  File? _selectedImage;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validateForm);
    _birthDateController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
  }

  void _validateForm() {
    bool isValid =
        _nameController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _emailController.text.contains("@") &&
        _addressController.text.trim().isNotEmpty &&
        _selectedImage != null;

    setState(() {
      _isFormValid = isValid;
    });
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
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      _validateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
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
                              onTap: _pickImage,
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
                                onTap: _pickImage,
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
              child: GestureDetector(
                onTap: _isFormValid
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile Saved")),
                        );
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: _isFormValid
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Save Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
