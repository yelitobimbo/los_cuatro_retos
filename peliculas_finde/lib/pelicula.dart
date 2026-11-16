/// Una película como la regresa TMDB.
class Pelicula {
  final String titulo;
  final String resumen;
  final String? posterPath;
  final double calificacion;
  final String fecha;

  const Pelicula({
    required this.titulo,
    required this.resumen,
    this.posterPath,
    this.calificacion = 0,
    this.fecha = '',
  });

  /// Convierte el JSON de una película en un objeto Pelicula.
  factory Pelicula.desdeJson(Map<String, dynamic> json) => Pelicula(
        titulo: (json['title'] ?? 'Sin título') as String,
        resumen: (json['overview'] ?? '') as String,
        posterPath: json['poster_path'] as String?,
        calificacion: ((json['vote_average'] ?? 0) as num).toDouble(),
        fecha: (json['release_date'] ?? '') as String,
      );

  /// Dirección completa del póster, o null si no tiene.
  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

  /// Solo el año ("2024-05-10" -> "2024").
  String get anio => fecha.length >= 4 ? fecha.substring(0, 4) : '';
}
