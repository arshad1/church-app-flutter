import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import '../../../routes/app_pages.dart'; // Import Routes
import '../controllers/profile_controller.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Ensure no back button appears unless we want it (but for bottom nav item usually false)
        // However, if we want to support Pushing from Profile, we might want 'true'.
        // But if 'true', and we are on Bottom Nav (offNamed), we get NO back button (correct).
        // If we force 'false', we get NO back button ever.
        // If we have manual leading, we get back button always.
        // CURRENT ISSUE: Manual leading was there.
        // DECISION: Remove manual leading. Let Flutter default (automaticallyImplyLeading: true).
        // This handles both cases: Pushed (Back works), Replaced/Root (No Back).
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final settings = controller.churchSettings.value;
                if (settings == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Default location (e.g., generic or previous placeholder) if not set
                final LatLng location = LatLng(
                  settings.latitude ??
                      9.9312, // Default fallback (e.g., Cochin)
                  settings.longitude ?? 76.2673,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Address'),
                      const SizedBox(height: 12),
                      Text(
                        settings.churchName ?? 'Church Name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (settings.address != null)
                        Text(
                          settings.address!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (settings.description != null) ...[
                        Text(
                          settings.description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildInfoRow('Vicar', settings.vicar),
                      _buildInfoRow('Trustee', settings.trustee),
                      _buildInfoRow('Secretary', settings.secretary),

                      const SizedBox(height: 24),
                      if (settings.latitude != null &&
                          settings.longitude != null) ...[
                        _buildSectionHeader('Location Map'),
                        const SizedBox(height: 12),
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.surface,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: location,
                                initialZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.churchapp.church_app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: location,
                                      width: 80,
                                      height: 80,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Fallback if no coords match
                        _buildSectionHeader('Location Map'),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.surface,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Center(
                            child: Text(
                              "Map coordinates not available",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
            const AppBottomNavBar(currentRoute: Routes.aboutUs),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label - ',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.wavy,
                decorationColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
