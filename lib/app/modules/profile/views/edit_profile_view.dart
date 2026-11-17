import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import 'dart:io';
import '../../../core/utils/image_helper.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  final ProfileController _controller = Get.find<ProfileController>();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final member = _controller.user.value?.member;
    _nameController = TextEditingController(text: member?.name ?? '');
    _phoneController = TextEditingController(text: member?.phone ?? '');
    _emailController = TextEditingController(
      text: _controller.user.value?.email ?? '',
    );
    _addressController = TextEditingController(
      text: member?.family?.address ?? '',
    );
  }

  /// Camera or gallery → crop → compress (with error messages).
  Future<void> _pickImage() async {
    final file = await ImageHelper.pickProfilePhoto();
    if (file != null && mounted) {
      setState(() => _selectedImage = file);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: glassAppBar(
        'Edit Profile',
        onBack: () => Get.back(),
      ),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: AppTheme.glow(AppTheme.secondary, 0.35),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.surface,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (_controller.user.value?.member?.profileImage !=
                                          null
                                      ? NetworkImage(
                                          _controller
                                              .user
                                              .value!
                                              .member!
                                              .profileImage!,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child:
                            _selectedImage == null &&
                                _controller.user.value?.member?.profileImage ==
                                    null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.background, width: 3),
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                // Optional: members who log in with a username may have none.
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty || GetUtils.isEmail(value)) return null;
                  return 'Please enter a valid email';
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Home Address',
                icon: Icons.home,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Obx(
                () => GradientButton(
                  label: 'Save Changes',
                  isLoading: _controller.isLoading.value,
                  onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _controller.updateProfile(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                email: _emailController.text,
                                address: _addressController.text,
                                imageFile: _selectedImage,
                              );
                            }
                          },
                ),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTheme.body(fontSize: 15),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: AppTheme.inputDecoration(label: label, icon: icon),
    );
  }
}
