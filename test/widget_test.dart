import 'package:flutter_test/flutter_test.dart';
import 'package:personal_assistant/main.dart';

void main() {
  testWidgets('PersonalAssistantApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalAssistantApp());
    expect(find.byType(PersonalAssistantApp), findsOneWidget);
  });
}
