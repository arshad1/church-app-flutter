import 'package:church_app/app/core/theme/app_theme.dart';
import 'package:church_app/app/core/widgets/bottom_nav_bar.dart';
import 'package:church_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

const _tabRoutes = [
  Routes.home,
  Routes.events,
  Routes.media,
  Routes.directory,
  Routes.profile,
];

/// Minimal app with one placeholder page per tab, each showing the nav bar,
/// set up the same way as main.dart (ScreenUtil + GetMaterialApp).
Widget _testApp({required String initialRoute}) {
  return ScreenUtilInit(
    designSize: const Size(360, 690),
    builder: (context, child) => GetMaterialApp(
      initialRoute: initialRoute,
      getPages: [
        for (final route in _tabRoutes)
          GetPage(
            name: route,
            page: () => Scaffold(
              body: Center(child: Text('page:$route')),
              bottomNavigationBar: AppBottomNavBar(currentRoute: route),
            ),
          ),
      ],
    ),
  );
}

/// The decoration of the animated pill wrapping a tab's label.
BoxDecoration _tabDecoration(WidgetTester tester, String label) {
  final container = tester.widget<AnimatedContainer>(
    find
        .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  setUpAll(() {
    AppTheme.useGoogleFonts = false; // tests have no network
    Get.testMode = true;
  });

  tearDown(() => Get.reset());

  testWidgets('shows all five tabs', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp(initialRoute: Routes.events));
    await tester.pumpAndSettle();

    for (final label in ['Home', 'Events', 'Media', 'Directory', 'Profile']) {
      expect(find.text(label), findsOneWidget, reason: '$label tab missing');
    }
  });

  testWidgets('highlights only the current tab with the gradient pill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp(initialRoute: Routes.events));
    await tester.pumpAndSettle();

    expect(_tabDecoration(tester, 'Events').gradient, isNotNull);
    for (final label in ['Home', 'Media', 'Directory', 'Profile']) {
      expect(
        _tabDecoration(tester, label).gradient,
        isNull,
        reason: '$label should not be highlighted',
      );
    }
  });

  testWidgets('tapping another tab navigates and moves the highlight', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp(initialRoute: Routes.events));
    await tester.pumpAndSettle();
    expect(find.text('page:${Routes.events}'), findsOneWidget);

    await tester.tap(find.text('Media'));
    await tester.pumpAndSettle();

    expect(find.text('page:${Routes.media}'), findsOneWidget);
    expect(find.text('page:${Routes.events}'), findsNothing);
    expect(_tabDecoration(tester, 'Media').gradient, isNotNull);
    expect(_tabDecoration(tester, 'Events').gradient, isNull);
  });

  testWidgets('tapping the current tab does nothing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp(initialRoute: Routes.home));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('page:${Routes.home}'), findsOneWidget);
    expect(Get.currentRoute, Routes.home);
  });
}
