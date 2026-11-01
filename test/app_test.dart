import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netflix_movil/catalog.dart';
import 'package:netflix_movil/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MovieStore> makeStore() async {
    SharedPreferences.setMockInitialValues({});
    return MovieStore(await SharedPreferences.getInstance());
  }

  test('Favoritos se agregan, persisten y se eliminan', () async {
    final store = await makeStore();
    expect(store.saved, isEmpty);
    await store.toggle(catalog.first);
    expect(store.contains(catalog.first), isTrue);
    final reloaded = MovieStore(await SharedPreferences.getInstance());
    expect(reloaded.saved.single.id, catalog.first.id);
    await reloaded.toggle(catalog.first);
    expect(reloaded.saved, isEmpty);
  });

  testWidgets('Inicio abre detalle y guarda una película en Mi lista', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = await makeStore();
    await tester.pumpWidget(NetflixLab(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver detalle'));
    await tester.pumpAndSettle();
    expect(find.text('Explorar título'), findsOneWidget);
    await tester.tap(find.text('Mi lista'));
    await tester.pumpAndSettle();
    expect(store.saved.single.id, 'horizonte');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi lista').last);
    await tester.pumpAndSettle();
    expect(find.text('1 título guardado'), findsOneWidget);
    await tester.tap(find.byTooltip('Quitar de Mi lista'));
    await tester.pumpAndSettle();
    expect(find.text('Tu próxima historia te espera'), findsOneWidget);
  });

  testWidgets('Filtro y búsqueda muestran resultados y estado vacío', (
    tester,
  ) async {
    final store = await makeStore();
    await tester.pumpWidget(NetflixLab(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suspenso').first);
    await tester.pumpAndSettle();
    expect(find.text('2 títulos para ti'), findsOneWidget);
    await tester.tap(find.byTooltip('Buscar títulos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'no existe');
    await tester.pumpAndSettle();
    expect(
      find.text('No encontramos ese título. Prueba otra búsqueda.'),
      findsOneWidget,
    );
  });

  testWidgets('Pantalla móvil angosta no desborda', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(NetflixLab(store: await makeStore()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
