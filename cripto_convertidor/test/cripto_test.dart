import 'package:cripto_convertidor/cripto.dart';
import 'package:cripto_convertidor/servicio_cripto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const jsonEjemplo = '{"bitcoin":{"usd":50000},"ethereum":{"usd":2500.5},"solana":{"usd":100}}';

void main() {
  group('parsearPrecios', () {
    test('lee las 3 monedas en orden', () {
      final lista = parsearPrecios(jsonEjemplo);
      expect(lista.map((c) => c.simbolo), ['BTC', 'ETH', 'SOL']);
      expect(lista[1].precioUsd, 2500.5);
      expect(lista[0].precioUsd, 50000.0); // un int también funciona
    });

    test('si falta una moneda, solo regresa las que llegaron', () {
      expect(parsearPrecios('{"bitcoin":{"usd":1}}').length, 1);
    });
  });

  group('cuantoCompras', () {
    test('100 USD de Bitcoin a 50,000 son 0.002 BTC', () {
      expect(cuantoCompras(100, 50000), closeTo(0.002, 1e-12));
    });
    test('con precio 0 no truena (no divide entre cero)', () {
      expect(cuantoCompras(100, 0), 0);
    });
  });

  group('leerMonto', () {
    test('acepta punto o coma decimal', () {
      expect(leerMonto('12.5'), 12.5);
      expect(leerMonto(' 12,5 '), 12.5);
    });
    test('texto, vacío o negativo es inválido', () {
      expect(leerMonto('abc'), isNull);
      expect(leerMonto(''), isNull);
      expect(leerMonto('-3'), isNull);
    });
  });

  test('formatearUsd pone comas de miles y 2 decimales', () {
    expect(formatearUsd(67000.5), r'$67,000.50');
    expect(formatearUsd(0.1), r'$0.10');
  });

  group('servicio (con un cliente falso, sin internet)', () {
    test('la URL pide las 3 monedas en dólares', () {
      final url = ServicioCripto().url;
      expect(url.queryParameters['ids'], 'bitcoin,ethereum,solana');
      expect(url.queryParameters['vs_currencies'], 'usd');
    });

    test('200 regresa los precios', () async {
      final s = ServicioCripto(cliente: MockClient((_) async => http.Response(jsonEjemplo, 200)));
      expect((await s.precios()).length, 3);
    });

    test('429 (demasiadas consultas) lanza un error claro', () async {
      final s = ServicioCripto(cliente: MockClient((_) async => http.Response('', 429)));
      await expectLater(s.precios(), throwsA(isA<Exception>()));
    });
  });
}
