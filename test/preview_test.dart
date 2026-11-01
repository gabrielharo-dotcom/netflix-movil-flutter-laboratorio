import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:netflix_movil/main.dart';
import 'package:netflix_movil/catalog.dart';

void main() {
  testWidgets('Exportar vista móvil de Inicio para revisión visual', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final entry in {
      'BebasNeue': 'BebasNeue-Regular.ttf',
      'Roboto': 'Roboto.ttf',
      'Montserrat': 'Montserrat.ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load('assets/fonts/${entry.value}'));
      await loader.load();
    }
    SharedPreferences.setMockInitialValues({});
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final store = MovieStore(await SharedPreferences.getInstance());
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: NetflixLab(store: store),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomeScreen));
      for (final movie in catalog.where((m) => m.local)) {
        await precacheImage(AssetImage(movie.image), context);
      }
    });
    await tester.pumpAndSettle();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('preview').create();
        await File(
          'preview/$name.png',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('inicio');
    await tester.tap(find.text('Ver detalle'));
    await tester.pumpAndSettle();
    await capture('detalle');
    await tester.tap(find.text('Mi lista'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mi lista').last);
    await tester.pumpAndSettle();
    await capture('mi_lista');
    expect(tester.takeException(), isNull);
  });
}
