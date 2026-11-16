import 'package:clima_minimalista/clima.dart';
import 'package:clima_minimalista/servicio_clima.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const jsonEjemplo = '''
{
  "name": "Dolores Hidalgo",
  "main": {"temp": 23.6, "feels_like": 22.9, "humidity": 40},
  "wind": {"speed": 2.5},
  "weather": [{"description": "cielo claro", "icon": "01d"}]
}
''';

ServicioClima conRespuesta(String body, int codigo) => ServicioClima(
      apiKey: 'abc',
      cliente: MockClient((_) async => http.Response(body, codigo,
          headers: {'content-type': 'application/json; charset=utf-8'})),
    );

void main() {
  group('Clima', () {
    final c = Clima.desdeJson({
      'name': 'Dolores Hidalgo',
      'main': {'temp': 23.6, 'feels_like': 22.9, 'humidity': 40},
      'wind': {'speed': 2.5},
      'weather': [
        {'description': 'cielo claro', 'icon': '01d'}
      ],
    });

    test('lee los datos del JSON', () {
      expect(c.ciudad, 'Dolores Hidalgo');
      expect(c.humedad, 40);
    });
    test('temperatura redondeada con símbolo de grados', () => expect(c.temperaturaTexto, '24°'));
    test('descripción con mayúscula inicial', () => expect(c.descripcionBonita, 'Cielo claro'));
    test('viento de m/s a km/h', () => expect(c.vientoKmh, 9));
    test('emoji de día soleado', () => expect(c.emoji, '☀️'));
  });

  group('URLs', () {
    final s = ServicioClima(apiKey: 'abc');
    test('por ciudad pide grados Celsius y español', () {
      final url = s.urlPorCiudad(' León,MX ');
      expect(url.queryParameters['q'], 'León,MX');
      expect(url.queryParameters['units'], 'metric');
      expect(url.queryParameters['lang'], 'es');
      expect(url.queryParameters['appid'], 'abc');
    });
    test('por coordenadas manda lat y lon', () {
      final url = s.urlPorCoordenadas(21.15, -100.93);
      expect(url.queryParameters['lat'], '21.15');
      expect(url.queryParameters['lon'], '-100.93');
    });
  });

  group('servicio (con un cliente falso, sin internet)', () {
    test('200 regresa el clima', () async {
      final c = await conRespuesta(jsonEjemplo, 200).porCiudad('Dolores Hidalgo');
      expect(c.temperaturaTexto, '24°');
    });
    test('404 dice que no encontró la ciudad', () async {
      await expectLater(conRespuesta('{}', 404).porCiudad('Narnia'),
          throwsA(predicate((e) => e.toString() == 'No encontré esa ciudad.')));
    });
    test('401 avisa de la clave', () async {
      await expectLater(conRespuesta('{}', 401).porCiudad('León'),
          throwsA(isA<ClimaException>()));
    });
    test('ciudad vacía no hace la petición', () async {
      await expectLater(conRespuesta(jsonEjemplo, 200).porCiudad('  '),
          throwsA(isA<ClimaException>()));
    });
    test('sin clave avisa que falta en secrets.json', () async {
      await expectLater(ServicioClima(apiKey: '').porCiudad('León'),
          throwsA(isA<ClimaException>()));
    });
  });
}
