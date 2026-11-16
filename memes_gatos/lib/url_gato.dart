/// Filtros que acepta la API de Cataas.
enum FiltroGato {
  ninguno('Sin filtro', null),
  blur('Borroso', 'blur'),
  mono('Blanco y negro', 'mono'),
  negate('Negativo', 'negate');

  final String texto;
  final String? valorApi;
  const FiltroGato(this.texto, this.valorApi);
}

/// Construye la URL dinámica de Cataas.
/// - Sin texto:  https://cataas.com/cat
/// - Con texto:  https://cataas.com/cat/says/<texto>?fontSize=..&fontColor=..
/// [semilla] cambia en cada toque para que Flutter no use la imagen guardada en caché.
Uri urlGato({
  String texto = '',
  FiltroGato filtro = FiltroGato.ninguno,
  int tamanoLetra = 40,
  String colorLetra = 'white',
  int semilla = 0,
}) {
  // La "/" partiría la ruta en dos, así que la cambiamos por un espacio.
  final limpio = texto.trim().replaceAll('/', ' ');
  final ruta = limpio.isEmpty ? '/cat' : '/cat/says/$limpio';

  final parametros = <String, String>{
    if (limpio.isNotEmpty) 'fontSize': '$tamanoLetra',
    if (limpio.isNotEmpty) 'fontColor': colorLetra,
    if (filtro.valorApi != null) 'filter': filtro.valorApi!,
    'semilla': '$semilla',
  };
  // Uri.https codifica sola los espacios y acentos (Hola mundo -> Hola%20mundo).
  return Uri.https('cataas.com', ruta, parametros);
}
