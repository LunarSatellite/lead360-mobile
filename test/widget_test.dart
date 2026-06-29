import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lead360_mobile/core/theme/app_theme.dart';

void main() {
  testWidgets('app theme + login title render', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: Center(child: Text('Lead360'))),
        ),
      ),
    );
    expect(find.text('Lead360'), findsOneWidget);
  });
}
