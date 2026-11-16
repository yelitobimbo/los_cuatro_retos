/// Datos del clima actual que nos interesan de OpenWeatherMap.
class Clima {
  final String ciudad;
  final double temperatura;
  final double sensacion;
  final int humedad;
  final double viento; // m/s
  final String descripcion;
  final String icono; // por ejemplo "01d"

  const Clima({
    required this.ciudad,
    required this.temperatura,
    required this.sensacion,
    required this.humedad,
    required this.viento,
    required this.descripcion,
    required this.icono,
  });

  factory Clima.desdeJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return Clima(
      ciudad: (json['name'] ?? '') as String,
      temperatura: (main['temp'] as num).toDouble(),
      sensacion: (main['feels_like'] as num).toDouble(),
      humedad: (main['humidity'] as num).toInt(),
      viento: ((json['wind']?['speed'] ?? 0) as num).toDouble(),
      descripcion: (weather['description'] ?? '') as String,
      icono: (weather['icon'] ?? '') as String,
    );
  }

  /// "23°" (redondeado, sin decimales).
  String get temperaturaTexto => '${temperatura.round()}°';

  /// "cielo claro" -> "Cielo claro".
  String get descripcionBonita =>
      descripcion.isEmpty ? '' : descripcion[0].toUpperCase() + descripcion.substring(1);

  /// Viento en km/h (la API lo da en metros por segundo).
  int get vientoKmh => (viento * 3.6).round();

  String get iconoUrl => 'https://openweathermap.org/img/wn/$icono@4x.png';

  /// Emoji según el código del ícono (los dos primeros dígitos).
  String get emoji {
    final codigo = icono.length >= 2 ? icono.substring(0, 2) : '';
    return switch (codigo) {
      '01' => icono.endsWith('n') ? '🌙' : '☀️',
      '02' => '🌤️',
      '03' || '04' => '☁️',
      '09' || '10' => '🌧️',
      '11' => '⛈️',
      '13' => '❄️',
      '50' => '🌫️',
      _ => '🌡️',
    };
  }
}
