import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (canPop)
                      GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 40,
                        onTap: () => Get.back(),
                      )
                    else
                      const SizedBox(width: 40),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Contact Us',
                          style: AppTheme.heading(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final settings = controller.churchSettings.value;
                  if (settings == null) {
                    return const AppLoader();
                  }

                  final hasCoords =
                      settings.latitude != null && settings.longitude != null;
                  final LatLng location = LatLng(
                    settings.latitude ?? 9.9312, // Default fallback (Cochin)
                    settings.longitude ?? 76.2673,
                  );

                  final leaders = <(String, String?, IconData)>[
                    ('Vicar', settings.vicar, Icons.person_rounded),
                    ('Trustee', settings.trustee, Icons.account_balance_rounded),
                    ('Secretary', settings.secretary, Icons.edit_note_rounded),
                  ].where((l) => l.$2 != null && l.$2!.isNotEmpty).toList();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Church card
                        FadeSlideIn(
                          child: GlassCard(
                            padding: const EdgeInsets.all(18),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.secondary.withValues(alpha: 0.18),
                                AppTheme.accent.withValues(alpha: 0.08),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: AppTheme.glow(),
                                      ),
                                      child: const Icon(
                                        Icons.church_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        settings.churchName ?? 'Church Name',
                                        style: AppTheme.heading(fontSize: 22),
                                      ),
                                    ),
                                  ],
                                ),
                                if (settings.address != null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.place_rounded,
                                        color: AppTheme.accent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          settings.address!,
                                          style: AppTheme.body(
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (settings.description != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    settings.description!,
                                    style: AppTheme.body(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (leaders.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const FadeSlideIn(
                            index: 1,
                            child: SectionHeader(title: 'Parish Leadership'),
                          ),
                          const SizedBox(height: 12),
                          for (var i = 0; i < leaders.length; i++)
                            FadeSlideIn(
                              index: i + 2,
                              child: _buildLeaderCard(
                                leaders[i].$1,
                                leaders[i].$2!,
                                leaders[i].$3,
                              ),
                            ),
                        ],
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          index: 5,
                          child: SectionHeader(
                            title: 'Find Us',
                            actionLabel: 'Directions',
                            onSeeAll: hasCoords
                                ? () => _openDirections(location)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeSlideIn(
                          index: 6,
                          child: Container(
                            height: hasCoords ? 280 : 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: AppTheme.surface,
                              border: Border.all(color: AppTheme.glassBorder),
                              boxShadow: AppTheme.glow(
                                AppTheme.secondary,
                                0.15,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: hasCoords
                                  ? FlutterMap(
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
                                              child: const _MapPin(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const EmptyState(
                                      icon: Icons.map_outlined,
                                      message: 'Map coordinates not available',
                                    ),
                            ),
                          ),
                        ),
                        if (hasCoords) ...[
                          const SizedBox(height: 16),
                          FadeSlideIn(
                            index: 7,
                            child: GradientButton(
                              label: 'Get Directions',
                              icon: Icons.directions_rounded,
                              onPressed: () => _openDirections(location),
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
      ),
    );
  }

  Future<void> _openDirections(LatLng location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${location.latitude},${location.longitude}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar('Error', 'Could not open maps');
    }
  }

  Widget _buildLeaderCard(String label, String value, IconData icon) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accent.withValues(alpha: 0.25),
                  AppTheme.secondary.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTheme.body(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppTheme.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient map pin with a pulsing halo.
class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const PulsingDot(size: 22, color: AppTheme.secondary),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: AppTheme.glow(),
          ),
          child: const Icon(
            Icons.church_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}
