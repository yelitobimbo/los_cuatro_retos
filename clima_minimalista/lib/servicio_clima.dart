import 'dart:convert';

import 'package:http/http.dart' as http;

import 'clima.dart';

/// La clave se pasa al correr la app: flutter run --dart-define-from-file=secrets.json
const String claveOwm = String.fromEnvironment('OWM_KEY');

/// Error con un mensaje que sí se le puede mostrar al usuario.
class ClimaException implements Exception {
  final String mensaje;
  const ClimaException(this.mensaje);
  @override
  String toString() => mensaje;
}

class ServicioClima {
  final String apiKey;
  final http.Client cliente;

  ServicioClima({this.apiKey = claveOwm, http.Client? cliente})
      : cliente = cliente ?? http.Client();

  Map<String, String> get _comunes => {'appid': apiKey, 'units': 'metric', 'lang': 'es'};

  Uri urlPorCiudad(String ciudad) => Uri.https(
      'api.openweathermap.org', '/data/2.5/weather', {'q': ciudad.trim(), ..._comunes});

  Uri urlPorCoordenadas(double lat, double lon) => Uri.https(
      'api.openweathermap.org', '/data/2.5/weather', {'lat': '$lat', 'lon': '$lon', ..._comunes});

  Future<Clima> porCiudad(String ciudad) {
    if (ciudad.trim().isEmpty) {
      return Future.error(const ClimaException('Escribe el nombre de una ciudad.'));
    }
    return _pedir(urlPorCiudad(ciudad));
  }

  Future<Clima> porCoordenadas(double lat, double lon) => _pedir(urlPorCoordenadas(lat, lon));

  Future<Clima> _pedir(Uri url) async {
    if (apiKey.isEmpty) {
      throw const ClimaException('Falta tu clave de OpenWeatherMap en secrets.json.');
    }
    final http.Response r;
    try {
      r = await cliente.get(url);
    } catch (_) {
      throw const ClimaException('Sin conexión a internet.');
    }
    switch (r.statusCode) {
      case 200:
        return Clima.desdeJson(jsonDecode(r.body) as Map<String, dynamic>);
      case 401:
        throw const ClimaException(
            'Clave inválida. Si la acabas de crear, espera un rato a que se active.');
      case 404:
        throw const ClimaException('No encontré esa ciudad.');
      default:
        throw ClimaException('El servicio del clima falló (${r.statusCode}).');
    }
  }
}
