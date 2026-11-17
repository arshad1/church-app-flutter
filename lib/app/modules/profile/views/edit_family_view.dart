import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../controllers/profile_controller.dart';

class EditFamilyView extends StatefulWidget {
  const EditFamilyView({super.key});

  @override
  State<EditFamilyView> createState() => _EditFamilyViewState();
}

class _EditFamilyViewState extends State<EditFamilyView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _houseNameController;
  final ProfileController _controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    final family = _controller.user.value?.member?.family;
    _nameController = TextEditingController(text: family?.name ?? '');
    _addressController = TextEditingController(text: family?.address ?? '');
    _phoneController = TextEditingController(text: family?.phone ?? '');
    _houseNameController = TextEditingController(text: family?.houseName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _houseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: glassAppBar(
        'Edit Family Details',
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
              _buildTextField(
                controller: _nameController,
                label: 'Family Name',
                icon: Icons.family_restroom,
                validator: (v) => v == null || v.isEmpty
                    ? 'Family Name cannot be empty'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _houseNameController,
                label: 'House Name',
                icon: Icons.home_filled,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Primary Phone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Obx(
                () => GradientButton(
                  label: 'Save Changes',
                  isLoading: _controller.isLoading.value,
                  onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _controller.updateFamilyDetails(
                                name: _nameController.text,
                                houseName: _houseNameController.text,
                                phone: _phoneController.text,
                                address: _addressController.text,
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
