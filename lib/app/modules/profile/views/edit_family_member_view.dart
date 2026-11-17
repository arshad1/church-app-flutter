import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/member_model.dart';
import '../../../core/utils/image_helper.dart';
import '../controllers/profile_controller.dart';

class EditFamilyMemberView extends StatefulWidget {
  final MemberModel member;
  const EditFamilyMemberView({super.key, required this.member});

  @override
  State<EditFamilyMemberView> createState() => _EditFamilyMemberViewState();
}

class _EditFamilyMemberViewState extends State<EditFamilyMemberView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final ProfileController _controller = Get.find<ProfileController>();
  File? _selectedImage;
  int? _selectedSpouseId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name ?? '');
    _phoneController = TextEditingController(text: widget.member.phone ?? '');
    _selectedSpouseId = widget.member.spouseId;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final processedImage = await ImageHelper.processImage(File(image.path));
      if (processedImage != null) {
        setState(() {
          _selectedImage = processedImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: glassAppBar(
        'Edit Family Member',
        onBack: () => Get.back(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassIconButton(
              icon: Icons.delete_outline_rounded,
              size: 40,
              iconColor: AppTheme.live,
              onTap: () {
              Get.defaultDialog(
                title: 'Delete Member',
                middleText:
                    'Are you sure you want to remove this family member?',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: AppTheme.live,
                onConfirm: () {
                  Get.back(); // Close dialog
                  _controller.deleteFamilyMember(widget.member.id!);
                  Get.back(); // Close edit screen (managed by controller but safe here)
                },
              );
            },
            ),
          ),
        ],
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
                            : (widget.member.profileImage != null
                                      ? NetworkImage(
                                          widget.member.profileImage!,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child:
                            _selectedImage == null &&
                                widget.member.profileImage == null
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
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              if (_controller.user.value?.member?.family?.members != null &&
                  _controller
                      .user
                      .value!
                      .member!
                      .family!
                      .members!
                      .isNotEmpty) ...[
                _buildDropdownField<int>(
                  label: 'Spouse (Optional)',
                  icon: Icons.favorite,
                  value: _selectedSpouseId,
                  items: _controller.user.value!.member!.family!.members!
                      .where((m) => m.id != widget.member.id) // Exclude self
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name ?? 'Member ${m.id}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSpouseId = v),
                ),
                const SizedBox(height: 32),
              ],
              Obx(
                () => GradientButton(
                  label: 'Save Changes',
                  isLoading: _controller.isLoading.value,
                  onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Controller needs a method to update family member similar to updateProfile
                              // For now I'll need to add updateFamilyMember method to controller that accepts ID
                              _controller.updateFamilyMemberProfile(
                                memberId: widget.member.id!,
                                name: _nameController.text,
                                phone: _phoneController.text,
                                spouseId: _selectedSpouseId,
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTheme.body(fontSize: 15),
      keyboardType: keyboardType,
      validator: validator,
      decoration: AppTheme.inputDecoration(label: label, icon: icon),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      // ignore: deprecated_member_use
      value: value,
      dropdownColor: AppTheme.surface,
      style: AppTheme.body(fontSize: 15),
      decoration: AppTheme.inputDecoration(label: label, icon: icon),
      items: items,
      onChanged: onChanged,
    );
  }
}
