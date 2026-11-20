import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api_ninjas_app/main.dart';
import 'package:api_ninjas_app/core/di/injection_container.dart';

void main() {
  testWidgets('App renders home screen smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    
    // Reset GetIt if previously initialized
    if (sl.isRegistered<SharedPreferences>()) {
      await sl.reset();
    }
    await initDependencies();

    await tester.pumpWidget(const ApiNinjasApp());
    await tester.pumpAndSettle();

    expect(find.text('Цитаты & Мудрость'), findsOneWidget);
    expect(find.text('Цитаты'), findsWidgets);
    expect(find.text('Загадки'), findsWidgets);
    expect(find.text('Факты'), findsWidgets);
    expect(find.text('Словарь'), findsWidgets);
    expect(find.text('История'), findsWidgets);
    expect(find.text('Настройки'), findsWidgets);
  });
}
