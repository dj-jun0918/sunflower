import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_eye_frontend/presentation/widgets/common/shimmer_card.dart';

void main() {
  testWidgets('ShimmerCard renders with correct dimensions',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShimmerCard(width: 100, height: 50),
        ),
      ),
    );

    // Verify that the ShimmerCard is present.
    final containerFinder = find.byType(Container);
    expect(containerFinder, findsOneWidget);

    // Verify dimensions
    final Container container = tester.widget(containerFinder);
    expect(container.constraints?.minWidth, 100);
    expect(container.constraints?.minHeight, 50);
  });

  testWidgets('ShimmerCard animation cycles', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShimmerCard(width: 100, height: 50),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Advance time
    await tester.pump(const Duration(milliseconds: 500));

    // Check if it repaints (implicitly via pump)
    expect(tester.hasRunningAnimations, isTrue);
  });
}
