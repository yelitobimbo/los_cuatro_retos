import 'package:http/http.dart' as http;

import 'cripto.dart';

/// CoinGecko tiene una API pública que no necesita clave.
class ServicioCripto {
  final http.Client cliente;
  ServicioCripto({http.Client? cliente}) : cliente = cliente ?? http.Client();

  Uri get url => Uri.https('api.coingecko.com', '/api/v3/simple/price', {
        'ids': monedas.map((m) => m.$1).join(','),
        'vs_currencies': 'usd',
      });

  Future<List<Cripto>> precios() async {
    final r = await cliente.get(url);
    if (r.statusCode == 429) {
      throw Exception('Muchas consultas seguidas. Espera un minuto y vuelve a intentar.');
    }
    if (r.statusCode != 200) {
      throw Exception('No se pudieron obtener los precios (${r.statusCode}).');
    }
    return parsearPrecios(r.body);
  }
}
