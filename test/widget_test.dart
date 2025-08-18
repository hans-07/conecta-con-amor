// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:conecta_con_amor/main.dart';

void main() {
  testWidgets('Conecta con Amor app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ConectaConAmorApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app title is displayed.
    expect(find.text('Conecta con Amor'), findsOneWidget);

    // Verify that main buttons are present.
    expect(find.text('Llamar'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Contactos'), findsOneWidget);
    expect(find.text('Fotos'), findsOneWidget);
    expect(find.text('Emergencia'), findsOneWidget);
    expect(find.text('Ayuda'), findsOneWidget);
  });
}
