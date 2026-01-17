import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/content_service.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Firebase
  // Note: Make sure to add google-services.json (Android) and GoogleService-Info.plist (iOS)
  // or use flutterfire configure to generate firebase_options.dart
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint("Firebase initialization failed: \$e");
  // }

  // Initialize Global Services
  Get.put(AuthService(), permanent: true);
  // Get.put(NotificationService(), permanent: true);
  Get.put(ContentService(), permanent: true);

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "Church App",
          // Navigation logic is handled in SplashController
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  );
}
