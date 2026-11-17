import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/ui_kit.dart';

/// What the user chose in the photo sheet.
enum PhotoAction { camera, gallery }

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Shows "Take a photo / Choose from gallery", then picks, crops (circle)
  /// and compresses the image. Returns null if the user cancelled.
  static Future<File?> pickProfilePhoto() async {
    final action = await _showSourceSheet();
    if (action == null) return null;
    return pickAndProcess(
      action == PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
    );
  }

  /// Picks from [source], crops to a square and compresses. Shows a message
  /// and returns null if anything goes wrong.
  static Future<File?> pickAndProcess(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 95,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image == null) return null; // user cancelled
      return await processImage(File(image.path));
    } catch (e) {
      _error(
        source == ImageSource.camera
            ? 'Could not open the camera. Please allow camera access in '
                  'your phone settings and try again.'
            : 'Could not open your photos. Please allow photo access in '
                  'your phone settings and try again.',
      );
      return null;
    }
  }

  static Future<File?> cropImage(File imageFile) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: AppTheme.background,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          backgroundColor: AppTheme.background,
          activeControlsWidgetColor: AppTheme.primary,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          cropStyle: CropStyle.circle,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  /// Compresses to a ~500px JPEG. Works for any input name/format; if
  /// compression fails the original file is returned instead of failing.
  static Future<File?> compressImage(File imageFile) async {
    try {
      final dir = imageFile.parent.path;
      final outPath =
          '$dir/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        outPath,
        quality: 75,
        minWidth: 600,
        minHeight: 600,
        format: CompressFormat.jpeg,
      );

      if (result != null) return File(result.path);
    } catch (_) {
      // fall through to the uncompressed file
    }
    return imageFile;
  }

  static Future<File?> processImage(File imageFile) async {
    // 1. Crop
    File? cropped;
    try {
      cropped = await cropImage(imageFile);
    } catch (_) {
      // If the cropper can't open, still let the user use the photo.
      cropped = imageFile;
    }
    if (cropped == null) return null; // user cancelled cropping

    // 2. Compress
    return compressImage(cropped);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  static Future<PhotoAction?> _showSourceSheet() {
    Widget option(PhotoAction action, IconData icon, String label,
        {bool danger = false}) {
      // Navigator.pop (not Get.back) so an open snackbar can't swallow the tap.
      return Builder(
        builder: (context) => GlassCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: () => Navigator.of(context).pop(action),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: danger ? null : AppTheme.primaryGradient,
                color: danger ? AppTheme.live.withValues(alpha: 0.15) : null,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: danger ? AppTheme.live : Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppTheme.body(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: danger ? AppTheme.live : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        ),
      );
    }

    return Get.bottomSheet<PhotoAction>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppTheme.glassBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Text('Profile Photo', style: AppTheme.heading(fontSize: 21)),
              const SizedBox(height: 16),
              option(
                PhotoAction.camera,
                Icons.photo_camera_rounded,
                'Take a photo',
              ),
              option(
                PhotoAction.gallery,
                Icons.photo_library_rounded,
                'Choose from gallery',
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static void _error(String message) {
    Get.snackbar(
      'Photo',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.live,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }
}
