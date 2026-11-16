import 'package:flutter_test/flutter_test.dart';
import 'package:memes_gatos/url_gato.dart';

void main() {
  test('sin texto pide un gato normal', () {
    final url = urlGato();
    expect(url.host, 'cataas.com');
    expect(url.path, '/cat');
    expect(url.queryParameters.containsKey('fontSize'), isFalse);
  });

  test('con texto usa /cat/says/ y codifica los espacios', () {
    final url = urlGato(texto: 'Hola mundo');
    expect(url.toString(), contains('/cat/says/Hola%20mundo'));
  });

  test('los acentos y la ñ también se codifican', () {
    final url = urlGato(texto: 'Año niño');
    expect(url.toString(), isNot(contains(' ')));
    expect(Uri.decodeFull(url.path), '/cat/says/Año niño');
  });

  test('una diagonal no rompe la ruta', () {
    expect(urlGato(texto: 'sí/no').pathSegments, ['cat', 'says', 'sí no']);
  });

  test('pasa tamaño y color de la letra', () {
    final url = urlGato(texto: 'miau', tamanoLetra: 60, colorLetra: 'yellow');
    expect(url.queryParameters['fontSize'], '60');
    expect(url.queryParameters['fontColor'], 'yellow');
  });

  test('agrega el filtro solo si se eligió uno', () {
    expect(urlGato(filtro: FiltroGato.mono).queryParameters['filter'], 'mono');
    expect(urlGato().queryParameters.containsKey('filter'), isFalse);
  });

  test('cambiar la semilla cambia la URL (gato nuevo)', () {
    expect(urlGato(semilla: 1), isNot(urlGato(semilla: 2)));
  });

  test('el texto con espacios de más se limpia', () {
    expect(urlGato(texto: '   ').path, '/cat');
  });
}
