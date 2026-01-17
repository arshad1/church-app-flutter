import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class AddFamilyMemberView extends StatefulWidget {
  const AddFamilyMemberView({super.key});

  @override
  State<AddFamilyMemberView> createState() => _AddFamilyMemberViewState();
}

class _AddFamilyMemberViewState extends State<AddFamilyMemberView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRole;

  DateTime? _selectedDate;
  String? _selectedGender;
  int? _selectedHouseId;
  int? _selectedSpouseId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Family Member',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Member Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Relationship',
                icon: Icons.people,
                value: _selectedRole,
                items:
                    [
                          'HEAD',
                          'SPOUSE',
                          'FATHER',
                          'MOTHER',
                          'SON',
                          'DAUGHTER',
                          'GRANDFATHER',
                          'GRANDMOTHER',
                          'MEMBER',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Gender',
                icon: Icons.wc,
                value: _selectedGender,
                items: ['MALE', 'FEMALE', 'OTHER']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 16),
              _buildDateField(
                label: 'Date of Birth',
                value: _selectedDate,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.primary,
                            onPrimary: Colors.white,
                            surface: AppTheme.surface,
                            onSurface: Colors.white,
                          ),
                          dialogTheme: const DialogThemeData(
                            backgroundColor: AppTheme.surface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number (Optional)',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => null, // Optional
              ),
              const SizedBox(height: 16),
              // House Selection (only if multiple houses exist)
              if (controller.user.value?.member?.family?.houses != null &&
                  controller.user.value!.member!.family!.houses!.length >
                      1) ...[
                _buildDropdownField<int>(
                  label: 'Select House',
                  icon: Icons.home,
                  value: _selectedHouseId,
                  items: controller.user.value!.member!.family!.houses!
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.id,
                          child: Text(h.name ?? 'House ${h.id}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedHouseId = v),
                ),
                const SizedBox(height: 16),
              ],
              // Spouse Selection
              if (controller.user.value?.member?.family?.members != null &&
                  controller
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
                  items: controller.user.value!.member!.family!.members!
                      .where((m) => m.id != null) // Filter valid members
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name ?? 'Member ${m.id}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSpouseId = v),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedRole == null) {
                                Get.snackbar(
                                  'Error',
                                  'Please select relationship',
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              if (_selectedGender == null) {
                                Get.snackbar(
                                  'Error',
                                  'Please select gender',
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              final data = {
                                'name': _nameController.text,
                                'familyRole': _selectedRole,
                                'gender': _selectedGender,
                                'phone': _phoneController.text.isNotEmpty
                                    ? _phoneController.text
                                    : null,
                                'dob': _selectedDate?.toIso8601String(),
                                if (_selectedHouseId != null)
                                  'houseId': _selectedHouseId,
                                if (_selectedSpouseId != null)
                                  'spouseId': _selectedSpouseId,
                              };
                              controller.addFamilyMember(data);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Add Member',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
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
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator:
          validator ??
          (v) => v == null || v.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value == null
                      ? 'Select Date'
                      : value.toString().split(' ')[0],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
