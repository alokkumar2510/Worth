import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worth/core/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard tight constraints build test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 200,
              child: GlassCard(
                borderColor: Colors.green,
                child: const Text('Tight Constraints Content'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tight Constraints Content'), findsOneWidget);
    final RenderBox cardBox = tester.renderObject(find.byType(GlassCard).first);
    expect(cardBox.size, const Size(320, 200));
  });

  testWidgets('GlassCard loose constraints build test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassCard(
              borderColor: Colors.green,
              child: const SizedBox(
                width: 150,
                height: 80,
                child: Center(child: Text('Loose Content')),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Loose Content'), findsOneWidget);
  });
}





