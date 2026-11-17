import 'package:church_app/app/core/theme/app_theme.dart';
import 'package:church_app/app/core/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hosts a widget inside the minimum app shell it needs (theme, directionality,
/// Material ancestor).
Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  // google_fonts downloads fonts at runtime; tests have no network.
  setUpAll(() => AppTheme.useGoogleFonts = false);

  group('GradientButton', () {
    testWidgets('shows its label and calls onPressed when tapped', (
      WidgetTester tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(GradientButton(label: 'Sign In', onPressed: () => taps++)),
      );

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('shows a spinner and ignores taps while loading', (
      WidgetTester tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          GradientButton(
            label: 'Sign In',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);

      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      expect(taps, 0);
    });

    testWidgets('is dimmed when onPressed is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const GradientButton(label: 'Save', onPressed: null)),
      );

      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(GradientButton),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });
  });

  group('PressableScale', () {
    testWidgets('shrinks while pressed, restores and fires onTap on release', (
      WidgetTester tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          PressableScale(
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      double currentScale() => tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(PressableScale),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;

      expect(currentScale(), 1.0);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PressableScale)),
      );
      // Longer than kPressTimeout so the tap-down is always delivered.
      await tester.pump(const Duration(milliseconds: 150));
      expect(currentScale(), 0.96);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(currentScale(), 1.0);
      expect(taps, 1);
    });
  });

  group('FadeSlideIn', () {
    Opacity opacityOf(WidgetTester tester, String text) {
      return tester.widget<Opacity>(
        find
            .ancestor(of: find.text(text), matching: find.byType(Opacity))
            .first,
      );
    }

    testWidgets('starts hidden and fades in fully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const FadeSlideIn(child: Text('Hello'))),
      );

      expect(opacityOf(tester, 'Hello').opacity, 0.0);

      // Fire the (zero) start delay, then let the animation finish.
      await tester.pump(Duration.zero);
      await tester.pumpAndSettle();

      expect(opacityOf(tester, 'Hello').opacity, 1.0);
    });

    testWidgets('waits index × staggerMs before starting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const FadeSlideIn(index: 3, staggerMs: 70, child: Text('Later')),
        ),
      );

      // 3 × 70 ms = 210 ms delay: still hidden at 150 ms.
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacityOf(tester, 'Later').opacity, 0.0);

      // Past the delay, the animation runs to completion.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(opacityOf(tester, 'Later').opacity, 1.0);
    });
  });

  group('SectionHeader', () {
    testWidgets('shows the title and a working "See all" link', (
      WidgetTester tester,
    ) async {
      var seeAllTaps = 0;
      await tester.pumpWidget(
        _host(
          SectionHeader(
            title: 'Upcoming Events',
            onSeeAll: () => seeAllTaps++,
          ),
        ),
      );

      expect(find.text('Upcoming Events'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);

      await tester.tap(find.text('See all'));
      await tester.pump();

      expect(seeAllTaps, 1);
    });

    testWidgets('hides the link when onSeeAll is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const SectionHeader(title: 'Gallery')));

      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('See all'), findsNothing);
    });
  });

  group('GlassCard', () {
    testWidgets('is tappable only when onTap is given', (
      WidgetTester tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassCard(onTap: () => taps++, child: const Text('Tap me')),
              const GlassCard(child: Text('Static')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(taps, 1);

      expect(
        find.ancestor(
          of: find.text('Static'),
          matching: find.byType(PressableScale),
        ),
        findsNothing,
      );
    });
  });

  group('Status widgets', () {
    testWidgets('EmptyState shows its icon and message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const EmptyState(
            icon: Icons.event_busy_rounded,
            message: 'No upcoming events',
          ),
        ),
      );

      expect(find.text('No upcoming events'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy_rounded), findsOneWidget);
    });

    testWidgets('LiveBadge shows its text with a pulsing dot', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LiveBadge()));
      // The dot animates forever, so pump a few frames instead of settling.
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('LIVE NOW'), findsOneWidget);
      expect(find.byType(PulsingDot), findsOneWidget);
    });

    testWidgets('PillLabel shows its text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const PillLabel(text: 'FEATURED', icon: Icons.star_rounded)),
      );

      expect(find.text('FEATURED'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });
  });
}
