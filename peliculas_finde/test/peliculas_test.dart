import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:peliculas_finde/estado_animo.dart';
import 'package:peliculas_finde/pelicula.dart';
import 'package:peliculas_finde/servicio_peliculas.dart';

const jsonEjemplo = '''
{"results": [
  {"title": "Coco", "overview": "Música y familia", "poster_path": "/coco.jpg", "vote_average": 8.2, "release_date": "2017-10-27"},
  {"title": "Sin póster", "overview": "", "poster_path": null, "vote_average": 6}
]}
''';

void main() {
  group('Pelicula', () {
    test('se crea desde el JSON de TMDB', () {
      final lista = ServicioPeliculas.parsearLista(jsonEjemplo);
      expect(lista.length, 2);
      expect(lista.first.titulo, 'Coco');
      expect(lista.first.calificacion, 8.2);
      expect(lista.first.anio, '2017');
    });

    test('arma la dirección completa del póster', () {
      final p = ServicioPeliculas.parsearLista(jsonEjemplo).first;
      expect(p.posterUrl, 'https://image.tmdb.org/t/p/w500/coco.jpg');
    });

    test('sin póster regresa null y sin fecha el año queda vacío', () {
      final p = ServicioPeliculas.parsearLista(jsonEjemplo).last;
      expect(p.posterUrl, isNull);
      expect(p.anio, '');
      expect(p.calificacion, 6.0); // un int también funciona
    });
  });

  group('URLs', () {
    final s = ServicioPeliculas(apiKey: 'abc');

    test('el estado de ánimo "feliz" pide comedias (género 35)', () {
      final url = s.urlPorAnimo(EstadoAnimo.feliz);
      expect(url.path, '/3/discover/movie');
      expect(url.queryParameters['with_genres'], '35');
      expect(url.queryParameters['api_key'], 'abc');
      expect(url.queryParameters['language'], 'es-MX');
    });

    test('tendencias usa trending de la semana', () {
      expect(s.urlTendencias().path, '/3/trending/movie/week');
    });
  });

  group('servicio (con un cliente falso, sin internet)', () {
    test('regresa la lista cuando la API responde 200', () async {
      final falso = MockClient((_) async => http.Response(jsonEjemplo, 200,
          headers: {'content-type': 'application/json; charset=utf-8'}));
      final s = ServicioPeliculas(apiKey: 'abc', cliente: falso);
      final lista = await s.porAnimo(EstadoAnimo.miedo);
      expect(lista.length, 2);
    });

    test('clave inválida (401) lanza un error claro', () async {
      final falso = MockClient((_) async => http.Response('{}', 401));
      final s = ServicioPeliculas(apiKey: 'mala', cliente: falso);
      await expectLater(s.tendencias(), throwsA(isA<Exception>()));
    });

    test('sin clave usa el modo demo', () async {
      final s = ServicioPeliculas(apiKey: '');
      expect(s.modoDemo, isTrue);
      expect(await s.tendencias(), peliculasDemo);
    });
  });

  group('al azar', () {
    test('siempre escoge una película de la lista', () {
      final r = Random(7);
      for (var i = 0; i < 20; i++) {
        expect(peliculasDemo, contains(peliculaAlAzar(peliculasDemo, r)));
      }
    });

    test('con la lista vacía regresa null', () {
      expect(peliculaAlAzar(const <Pelicula>[]), isNull);
    });
  });
}
