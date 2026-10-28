import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/app.dart';
import 'package:pizarra/src/pages/inicio_page.dart';
import 'package:pizarra/src/widgets/app_pill_bar.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GameStorage.init();
  });

  testWidgets('la barra inferior está en todas las pantallas', (tester) async {
    await _pumpApp(tester);

    // Inicio: no hay a dónde volver, así que no muestra "Volver".
    expect(find.byType(AppPillBar), findsOneWidget);
    expect(find.text('Volver'), findsNothing);
    expect(find.text('Truco'), findsOneWidget);
    expect(find.text('Chinchón'), findsOneWidget);
    expect(find.text('Estilo'), findsOneWidget);

    // Configuración: volver + ayuda.
    await tester.tap(find.text('Truco'));
    await tester.pumpAndSettle();
    expect(find.byType(AppPillBar), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Ayuda'), findsOneWidget);

    await tester.tap(find.text('Ayuda'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo se anota?'), findsOneWidget);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();

    // Puntaje: volver + acciones del juego.
    await tester.ensureVisible(find.text('COMENZAR'));
    await tester.tap(find.text('COMENZAR'));
    await tester.pumpAndSettle();
    expect(find.byType(AppPillBar), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Reiniciar'), findsOneWidget);
    expect(find.text('Equipos'), findsOneWidget);
    expect(find.text('Estilo'), findsOneWidget);

    // Estilo: volver + listo.
    await tester.tap(find.text('Estilo'));
    await tester.pumpAndSettle();
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Equipos'), findsOneWidget);
  });

  testWidgets('Volver desde el puntaje regresa al inicio', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Truco'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('COMENZAR'));
    await tester.tap(find.text('COMENZAR'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('team-column-0')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.byType(InicioPage), findsOneWidget);
    expect(find.text('PIZARRA'), findsOneWidget);
    // La partida queda guardada y se puede continuar.
    expect(find.text('Continuar Truco'), findsOneWidget);
  });

  testWidgets('Volver desde la configuración regresa al inicio',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Chinchón'));
    await tester.pumpAndSettle();
    expect(find.text('Cantidad de jugadores'), findsOneWidget);

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.byType(InicioPage), findsOneWidget);
  });
}
