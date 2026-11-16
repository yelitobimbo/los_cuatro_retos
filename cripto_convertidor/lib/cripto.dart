import 'dart:convert';

class Cripto {
  final String id; // id de CoinGecko, ej. "bitcoin"
  final String nombre;
  final String simbolo;
  final String emoji;
  final double precioUsd;

  const Cripto(this.id, this.nombre, this.simbolo, this.emoji, this.precioUsd);
}

/// Las 3 monedas del reto, en el orden en que se muestran.
const monedas = [
  ('bitcoin', 'Bitcoin', 'BTC', '🟠'),
  ('ethereum', 'Ethereum', 'ETH', '🔷'),
  ('solana', 'Solana', 'SOL', '🟣'),
];

/// La respuesta de CoinGecko se ve así:
/// {"bitcoin":{"usd":67000},"ethereum":{"usd":3500},"solana":{"usd":150}}
List<Cripto> parsearPrecios(String body) {
  final datos = jsonDecode(body) as Map<String, dynamic>;
  return [
    for (final (id, nombre, simbolo, emoji) in monedas)
      if (datos[id] is Map && datos[id]['usd'] != null)
        Cripto(id, nombre, simbolo, emoji, (datos[id]['usd'] as num).toDouble()),
  ];
}

/// Cuánta cripto compras con [dolares]. Ej.: 100 USD de BTC a 50,000 = 0.002 BTC.
double cuantoCompras(double dolares, double precio) => precio <= 0 ? 0 : dolares / precio;

/// Convierte lo que escribe el usuario en número. Acepta "1,5" o "1.5".
/// Regresa null si no es un número válido o es negativo.
double? leerMonto(String texto) {
  final n = double.tryParse(texto.trim().replaceAll(',', '.'));
  if (n == null || n < 0) return null;
  return n;
}

/// Muestra el precio con comas de miles: 67000.5 -> "$67,000.50".
String formatearUsd(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final enteros = partes[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '\$$enteros.${partes[1]}';
}
