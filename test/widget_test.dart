import 'package:bayle_ops/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows operations dashboard and navigates between workstreams', (
    tester,
  ) async {
    await tester.pumpWidget(const BayleOpsApp(screenshotMode: true));

    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Patrols today'), findsOneWidget);

    await tester.tap(find.text('Gear'));
    await tester.pumpAndSettle();

    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Radio kit B12 checkout'), findsOneWidget);
  });

  testWidgets('creates a local operations record', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BayleOpsApp(screenshotMode: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('floatingNewRecordButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('recordTitleField')),
      'Visitor badge restock',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveRecordButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patrol'));
    await tester.pumpAndSettle();

    expect(find.text('Visitor badge restock'), findsOneWidget);
  });
}
