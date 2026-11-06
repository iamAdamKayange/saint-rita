import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saint_rita/widgets/animated_nun_3d.dart';

void main() {
  testWidgets('nun animates and responds to drag', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: AnimatedNun3D(height: 240))),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.drag(find.byType(AnimatedNun3D), const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AnimatedNun3D)), const Size(160, 240));
  });

  testWidgets('nun stays still when reduced motion is on', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: Center(child: AnimatedNun3D())),
      ),
    );
    // No ticking animation: pumpAndSettle would time out otherwise.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
