import 'package:geolocator/geolocator.dart';

/// El "plus" del reto: pide permiso y regresa la ubicación del teléfono.
Future<Position> obtenerUbicacion() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw Exception('Activa la ubicación (GPS) del teléfono.');
  }
  var permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
  }
  if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
    throw Exception('Sin permiso de ubicación. Busca tu ciudad por nombre.');
  }
  return Geolocator.getCurrentPosition();
}
