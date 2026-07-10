import 'package:flutter_test/flutter_test.dart';

import 'package:manari_app/main.dart';

void main() {
  testWidgets('App renders the Studio style guide', (WidgetTester tester) async {
    await tester.pumpWidget(const ManariApp());
    await tester.pumpAndSettle();

    expect(find.text('Colour'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);
    expect(find.text('Components'), findsOneWidget);
  });
}
