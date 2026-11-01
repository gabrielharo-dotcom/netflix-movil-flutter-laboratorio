# Netflix móvil · Laboratorio Flutter

Aplicación móvil académica inspirada en Netflix. Catálogo ficticio en español, diseño oscuro, portada destacada, carruseles, búsqueda, filtros, detalle y favoritos persistentes. No requiere cuenta ni claves de API. El botón de reproducción abre una demostración informativa; no transmite películas.

## Ejecutar en Android

Requisitos: Flutter estable (Dart 3.10 o superior), Android Studio y un emulador o teléfono Android con depuración USB.

Desde la carpeta del proyecto:

```powershell
flutter doctor
flutter pub get
flutter devices
flutter run
```

Para generar un instalador:

```powershell
flutter build apk --debug
```

El resultado estará en `build/app/outputs/flutter-apk/app-debug.apk`. Para una distribución de producción se debe configurar la firma propia. La carpeta iOS también está incluida; compilar para iPhone requiere macOS, Xcode y la configuración de firma correspondiente.

## Cómo presentar el laboratorio

1. Abrir Inicio y mostrar la portada, los carruseles y el desplazamiento vertical.
2. Deslizar un carrusel horizontal para mostrar las tarjetas del catálogo.
3. Elegir «Suspenso» y luego buscar «Medianoche». Mostrar también una búsqueda sin resultados.
4. Abrir una película y explicar el paso de argumentos a la ruta de detalle.
5. Agregarla con «Mi lista», volver y abrir la colección desde la barra inferior.
6. Cerrar y abrir la aplicación: la selección se conserva. Quitarla de la lista para mostrar el estado vacío.
7. Abrir «El último bosque» o «Azul profundo» para mostrar una imagen remota; «Horizonte», «Mar de arena» y «Medianoche» usan imágenes locales.

## Relación con los requisitos

| Requisito | Implementación |
| --- | --- |
| ListView | Inicio vertical, carruseles horizontales con `ListView.separated`, detalle y favoritos |
| ListTile | `MovieRow`: miniatura, título, género, año y acción de favoritos |
| Listas y mapas | `catalog.dart`: `List<Map<String, Object>>` convertida a `List<Movie>` |
| Rutas | `MaterialApp`, `/detail` con argumentos y `/list`; regreso con `Navigator.pop` |
| Tema global | `ThemeData` en `NetflixLab`: colores, fuentes, botones y barras |
| Cards | `MovieShelf` y `MovieRow` |
| Row y Column | Botones en la portada, contenido de tarjetas y ficha de detalle |
| Tres tipos de letra | Bebas Neue: marca y títulos; Roboto: contenido; Montserrat: botones y favoritos |
| Imágenes locales | `Image.asset`, archivos JPG en `assets/images` |
| Imágenes en la nube | `Image.network` por HTTPS, indicador de carga y respaldo local |
| Estado | `ChangeNotifier` y `ListenableBuilder` actualizan favoritos |
| Persistencia | `shared_preferences` guarda identificadores en el dispositivo |

## Archivos principales

- `lib/main.dart`: tema, rutas, pantallas y widgets reutilizables.
- `lib/catalog.dart`: modelo, catálogo de mapas y estado persistente de favoritos.
- `pubspec.yaml`: dependencias, imágenes y las tres familias de fuentes locales.
- `test/app_test.dart`: persistencia, navegación, búsqueda, filtros y ancho móvil de 320 px.

Validación:

```powershell
flutter analyze
flutter test
```

## Recursos y referencias

Los títulos y sinopsis son ficticios, creados para este ejercicio. Netflix es una marca de su titular; este proyecto es una práctica académica independiente.

- Referencia visual: https://www.netflix.com/pe/
- Fotografías: Unsplash, servidas desde `images.unsplash.com`. Los identificadores exactos de las imágenes locales y remotas están en `FUENTES.md` y `lib/catalog.dart`.
- Fuentes: Google Fonts (Bebas Neue, Roboto y Montserrat), con licencias OFL incluidas junto a los archivos TTF.
- Navegación Flutter: https://docs.flutter.dev/ui/navigation
- Internet en Android: https://docs.flutter.dev/data-and-backend/networking

Las fotos remotas requieren internet. Si el servicio no responde, la aplicación muestra una fotografía local de respaldo.
