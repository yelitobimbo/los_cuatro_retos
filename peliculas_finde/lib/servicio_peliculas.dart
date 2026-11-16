import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'estado_animo.dart';
import 'pelicula.dart';

/// La clave se pasa al correr la app: flutter run --dart-define-from-file=secrets.json
const String claveTmdb = String.fromEnvironment('TMDB_KEY');

class ServicioPeliculas {
  final String apiKey;
  final http.Client cliente;

  ServicioPeliculas({this.apiKey = claveTmdb, http.Client? cliente})
      : cliente = cliente ?? http.Client();

  /// Sin clave la app funciona en "modo demo" con películas de ejemplo.
  bool get modoDemo => apiKey.isEmpty;

  Uri urlTendencias() => Uri.https('api.themoviedb.org', '/3/trending/movie/week', {
        'api_key': apiKey,
        'language': 'es-MX',
      });

  Uri urlPorAnimo(EstadoAnimo animo) => Uri.https('api.themoviedb.org', '/3/discover/movie', {
        'api_key': apiKey,
        'language': 'es-MX',
        'sort_by': 'popularity.desc',
        'with_genres': '${animo.generoId}',
      });

  Future<List<Pelicula>> tendencias() =>
      modoDemo ? Future.value(peliculasDemo) : _pedir(urlTendencias());

  Future<List<Pelicula>> porAnimo(EstadoAnimo animo) =>
      modoDemo ? Future.value(peliculasDemo) : _pedir(urlPorAnimo(animo));

  Future<List<Pelicula>> _pedir(Uri url) async {
    final respuesta = await cliente.get(url);
    if (respuesta.statusCode == 401) {
      throw Exception('La clave de TMDB no es válida.');
    }
    if (respuesta.statusCode != 200) {
      throw Exception('No se pudieron cargar las películas (${respuesta.statusCode}).');
    }
    return parsearLista(respuesta.body);
  }

  /// Convierte la respuesta de TMDB ({"results": [...]}) en una lista.
  static List<Pelicula> parsearLista(String body) {
    final datos = jsonDecode(body) as Map<String, dynamic>;
    final resultados = (datos['results'] ?? []) as List;
    return resultados
        .map((e) => Pelicula.desdeJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Escoge una película al azar. El Random se puede pasar para probarlo.
Pelicula? peliculaAlAzar(List<Pelicula> lista, [Random? random]) {
  if (lista.isEmpty) return null;
  return lista[(random ?? Random()).nextInt(lista.length)];
}

const peliculasDemo = [
  Pelicula(titulo: 'Coco', resumen: 'Miguel viaja a la Tierra de los Muertos para descubrir la historia de su familia.', calificacion: 8.2, fecha: '2017-10-27'),
  Pelicula(titulo: 'Intensamente', resumen: 'Las emociones de una niña intentan ayudarla a adaptarse a una nueva ciudad.', calificacion: 7.9, fecha: '2015-06-19'),
  Pelicula(titulo: 'Volver al futuro', resumen: 'Un joven viaja accidentalmente 30 años al pasado en un auto del tiempo.', calificacion: 8.3, fecha: '1985-07-03'),
];
