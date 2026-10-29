import 'package:flutter_test/flutter_test.dart';
import 'package:toolbox_app/main.dart';

void main() {
  testWidgets('La pantalla de inicio muestra las herramientas',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ToolboxApp());
    expect(find.text('Caja de Herramientas'), findsOneWidget);
    expect(find.text('Acerca de'), findsOneWidget);
  });
}
