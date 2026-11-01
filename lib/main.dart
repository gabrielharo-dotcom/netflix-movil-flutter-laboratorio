import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(NetflixLab(store: MovieStore(preferences)));
}

const red = Color(0xFFE50914);
const muted = Color(0xFFAAAAAF);

class NetflixLab extends StatelessWidget {
  const NetflixLab({super.key, required this.store});
  final MovieStore store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Netflix · Laboratorio',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF101012),
      colorScheme: const ColorScheme.dark(
        primary: red,
        secondary: Colors.white,
        surface: Color(0xFF1C1C20),
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101012),
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    ),
    home: HomeScreen(store: store),
    // Rutas: portada, detalle y colección personal.
    onGenerateRoute: (settings) {
      if (settings.name == '/detail' && settings.arguments is Movie) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              DetailScreen(movie: settings.arguments! as Movie, store: store),
        );
      }
      if (settings.name == '/list') {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MyListScreen(store: store),
        );
      }
      return null;
    },
  );
}

void openDetail(BuildContext context, Movie movie) =>
    Navigator.pushNamed(context, '/detail', arguments: movie);

class MovieImage extends StatelessWidget {
  const MovieImage(this.movie, {super.key, this.fit = BoxFit.cover});
  final Movie movie;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext context, Object error, StackTrace? stack) =>
        Image.asset('assets/images/mountains.jpg', fit: fit);
    return movie.local
        ? Image.asset(
            movie.image,
            fit: fit,
            errorBuilder: (c, e, s) => const ColoredBox(
              color: Color(0xFF303038),
              child: Center(child: Icon(Icons.movie)),
            ),
          )
        : Image.network(
            movie.image,
            fit: fit,
            errorBuilder: fallback,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const ColoredBox(
                    color: Color(0xFF24242A),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final MovieStore store;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String genre = 'Todo';
  String query = '';
  bool searching = false;
  @override
  Widget build(BuildContext context) {
    final movies = catalog
        .where(
          (m) =>
              (genre == 'Todo' || m.genre == genre) &&
              m.title.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NETFLIX',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 36,
            color: red,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Buscar títulos',
            onPressed: () => setState(() {
              searching = !searching;
              query = '';
            }),
            icon: const Icon(Icons.search),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF256D74),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.person, size: 23),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar una película',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Todo', 'Aventura', 'Suspenso', 'Documental']
                    .map(
                      (g) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: genre == g,
                          showCheckmark: false,
                          selectedColor: red,
                          onSelected: (_) => setState(() => genre = g),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (query.isEmpty && genre == 'Todo') ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: HeroCard(movie: catalog.first, store: widget.store),
              ),
              MovieShelf(
                title: 'Tu próxima historia',
                movies: catalog,
                store: widget.store,
              ),
              MovieShelf(
                title: 'Adrenalina y aventura',
                movies: catalog.where((m) => m.genre != 'Documental').toList(),
                store: widget.store,
              ),
              MovieShelf(
                title: 'Un mundo por descubrir',
                movies: catalog.where((m) => m.genre == 'Documental').toList(),
                store: widget.store,
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${movies.length} títulos para ti',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (movies.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No encontramos ese título. Prueba otra búsqueda.',
                  ),
                ),
              ...movies.map((m) => MovieRow(movie: m, store: widget.store)),
            ],
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Text(
                'LABORATORIO FLUTTER  /  CATÁLOGO FICTICIO',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: const Color(0xFF17171B),
        indicatorColor: red.withValues(alpha: .2),
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushNamed(context, '/list');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            label: 'Mi lista',
          ),
        ],
      ),
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.movie, required this.store});
  final Movie movie;
  final MovieStore store;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Destacado: ${movie.title}',
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: .83,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MovieImage(movie),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black12,
                    Colors.transparent,
                    Color(0xF5101012),
                  ],
                  stops: [0, .3, 1],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: red,
                child: const Text(
                  'ESTRENO',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                children: [
                  const Text(
                    'UNA HISTORIA PARA IR MÁS ALLÁ',
                    style: TextStyle(fontSize: 9, letterSpacing: 2),
                  ),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 64,
                      height: 1.2,
                      letterSpacing: 3,
                    ),
                  ),
                  const Text(
                    'Aventura  •  Emotiva  •  Exploración',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => openDetail(context, movie),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Ver detalle'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SaveButton(movie: movie, store: store),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.movie, required this.store});
  final Movie movie;
  final MovieStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => OutlinedButton.icon(
      onPressed: () => store.toggle(movie),
      icon: Icon(store.contains(movie) ? Icons.check : Icons.add, size: 20),
      label: Text(store.contains(movie) ? 'Guardado' : 'Mi lista', maxLines: 1),
    ),
  );
}

class MovieShelf extends StatelessWidget {
  const MovieShelf({
    super.key,
    required this.title,
    required this.movies,
    required this.store,
  });
  final String title;
  final List<Movie> movies;
  final MovieStore store;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      SizedBox(
        height: 218,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: movies.length,
          separatorBuilder: (_, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) => SizedBox(
            width: 132,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => openDetail(context, movies[index]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MovieImage(movies[index]),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 7,
                            left: 8,
                            child: Text(
                              'N',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                color: red,
                                fontSize: 25,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 10,
                            child: Text(
                              movies[index].title,
                              maxLines: 2,
                              style: const TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 22,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: Text(
                        movies[index].genre,
                        style: const TextStyle(fontSize: 11, color: muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.movie, required this.store});
  final Movie movie;
  final MovieStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Explorar título')),
    body: SafeArea(
      top: false,
      child: ListView(
        children: [
          SizedBox(height: 270, child: MovieImage(movie)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'N  PELÍCULA',
                  style: TextStyle(
                    color: red,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 44,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${movie.year}', style: const TextStyle(color: muted)),
                    Text(movie.age, style: const TextStyle(color: muted)),
                    Text(movie.duration, style: const TextStyle(color: muted)),
                    const Text(
                      'HD',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Vista de demostración'),
                        content: Text(
                          'Has seleccionado ${movie.title}. Este laboratorio presenta la interfaz y la navegación; no incluye videos.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Reproducir demo'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SaveButton(movie: movie, store: store),
                ),
                const SizedBox(height: 22),
                Text(
                  movie.description,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Género: ${movie.genre}',
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 8),
                Text(
                  movie.local
                      ? 'Imagen incluida en la aplicación'
                      : 'Imagen cargada desde internet',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ),
          MovieShelf(
            title: 'También te puede gustar',
            movies: catalog.where((m) => m.id != movie.id).toList(),
            store: store,
          ),
        ],
      ),
    ),
  );
}

class MovieRow extends StatelessWidget {
  const MovieRow({super.key, required this.movie, required this.store});
  final Movie movie;
  final MovieStore store;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        leading: SizedBox(
          width: 62,
          height: 64,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: MovieImage(movie),
          ),
        ),
        title: Text(
          movie.title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${movie.genre} · ${movie.year}',
          style: const TextStyle(color: muted, fontSize: 12),
        ),
        onTap: () => openDetail(context, movie),
        trailing: ListenableBuilder(
          listenable: store,
          builder: (context, _) => IconButton(
            tooltip: store.contains(movie)
                ? 'Quitar de Mi lista'
                : 'Agregar a Mi lista',
            icon: Icon(
              store.contains(movie)
                  ? Icons.bookmark_remove_outlined
                  : Icons.bookmark_add_outlined,
            ),
            onPressed: () => store.toggle(movie),
          ),
        ),
      ),
    ),
  );
}

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key, required this.store});
  final MovieStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Mi lista',
        style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final movies = store.saved;
          if (movies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmarks_outlined,
                      size: 64,
                      color: muted,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tu próxima historia te espera',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Guarda películas con el botón «Mi lista» y encuéntralas aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Explorar catálogo'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  movies.length == 1
                      ? '1 título guardado'
                      : '${movies.length} títulos guardados',
                  style: const TextStyle(color: muted),
                ),
              ),
              ...movies.map((m) => MovieRow(movie: m, store: store)),
            ],
          );
        },
      ),
    ),
  );
}
