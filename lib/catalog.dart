import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.description,
    required this.image,
    required this.local,
    required this.year,
    required this.duration,
    required this.age,
  });
  final String id, title, genre, description, image, duration, age;
  final bool local;
  final int year;

  factory Movie.fromMap(Map<String, Object> map) => Movie(
    id: map['id'] as String,
    title: map['title'] as String,
    genre: map['genre'] as String,
    description: map['description'] as String,
    image: map['image'] as String,
    local: map['local'] as bool,
    year: map['year'] as int,
    duration: map['duration'] as String,
    age: map['age'] as String,
  );
}

// Listas y mapas: cada mapa se convierte en un objeto Movie tipado.
final List<Movie> catalog = <Map<String, Object>>[
  {
    'id': 'horizonte',
    'title': 'HORIZONTE',
    'genre': 'Aventura',
    'description':
        'Una fotógrafa regresa a las montañas de su infancia. Una señal inesperada la llevará a descubrir un camino que nunca apareció en los mapas.',
    'image': 'assets/images/mountains.jpg',
    'local': true,
    'year': 2026,
    'duration': '1 h 48 min',
    'age': '13+',
  },
  {
    'id': 'arena',
    'title': 'MAR DE ARENA',
    'genre': 'Aventura',
    'description':
        'Dos hermanos cruzan el desierto para cumplir una promesa. Entre dunas y tormentas, aprenderán que el verdadero destino es volver a encontrarse.',
    'image': 'assets/images/desert.jpg',
    'local': true,
    'year': 2025,
    'duration': '1 h 36 min',
    'age': '7+',
  },
  {
    'id': 'medianoche',
    'title': 'MEDIANOCHE',
    'genre': 'Suspenso',
    'description':
        'La ciudad nunca duerme. Cuando una periodista recibe una llamada anónima, tiene una sola noche para encontrar la verdad.',
    'image': 'assets/images/city.jpg',
    'local': true,
    'year': 2026,
    'duration': '1 h 52 min',
    'age': '16+',
  },
  {
    'id': 'bosque',
    'title': 'EL ÚLTIMO BOSQUE',
    'genre': 'Documental',
    'description':
        'Un viaje por los bosques del planeta y las historias de quienes dedican su vida a protegerlos. Cada árbol guarda una historia.',
    'image':
        'https://images.unsplash.com/photo-1448375240586-882707db888b?w=900&q=85&fit=crop',
    'local': false,
    'year': 2025,
    'duration': '58 min',
    'age': 'ATP',
  },
  {
    'id': 'oceano',
    'title': 'AZUL PROFUNDO',
    'genre': 'Documental',
    'description':
        'Bajo la superficie existe un universo por descubrir. Acompaña a un equipo de exploradores en una expedición por el océano.',
    'image':
        'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=900&q=85&fit=crop',
    'local': false,
    'year': 2024,
    'duration': '1 h 12 min',
    'age': 'ATP',
  },
  {
    'id': 'escape',
    'title': 'RUTA DE ESCAPE',
    'genre': 'Suspenso',
    'description':
        'Un viaje por carretera cambia de rumbo cuando una viajera encuentra una mochila abandonada. Alguien quiere recuperarla antes del amanecer.',
    'image':
        'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=900&q=85&fit=crop',
    'local': false,
    'year': 2026,
    'duration': '1 h 41 min',
    'age': '13+',
  },
].map(Movie.fromMap).toList(growable: false);

class MovieStore extends ChangeNotifier {
  MovieStore(this.preferences)
    : _saved = (preferences.getStringList('saved_movies') ?? []).toSet();
  final SharedPreferences preferences;
  final Set<String> _saved;
  bool contains(Movie movie) => _saved.contains(movie.id);
  List<Movie> get saved => catalog.where(contains).toList();
  Future<void> toggle(Movie movie) async {
    if (!_saved.add(movie.id)) _saved.remove(movie.id);
    notifyListeners();
    await preferences.setStringList('saved_movies', _saved.toList());
  }
}
