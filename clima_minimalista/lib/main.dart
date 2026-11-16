import 'package:flutter/material.dart';

import 'clima.dart';
import 'servicio_clima.dart';
import 'ubicacion.dart';

void main() => runApp(const AppClima());

class AppClima extends StatelessWidget {
  const AppClima({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Clima',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.lightBlue, useMaterial3: true),
        home: const PantallaClima(),
      );
}

class PantallaClima extends StatefulWidget {
  const PantallaClima({super.key});
  @override
  State<PantallaClima> createState() => _PantallaClimaState();
}

class _PantallaClimaState extends State<PantallaClima> {
  final servicio = ServicioClima();
  final _ciudad = TextEditingController(text: 'Dolores Hidalgo,MX');
  late Future<Clima> clima = servicio.porCiudad(_ciudad.text);

  @override
  void dispose() {
    _ciudad.dispose();
    super.dispose();
  }

  void buscar() => setState(() => clima = servicio.porCiudad(_ciudad.text));

  void usarMiUbicacion() {
    setState(() {
      clima = obtenerUbicacion().then((p) => servicio.porCoordenadas(p.latitude, p.longitude));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ciudad,
                    decoration: const InputDecoration(
                      hintText: 'Ciudad (ej. León,MX)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => buscar(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: buscar),
                IconButton(
                  tooltip: 'Mi ubicación',
                  icon: const Icon(Icons.my_location),
                  onPressed: usarMiUbicacion,
                ),
              ]),
              Expanded(
                child: FutureBuilder<Clima>(
                  future: clima,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('${snapshot.error}'.replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center),
                      );
                    }
                    return VistaClima(clima: snapshot.data!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VistaClima extends StatelessWidget {
  final Clima clima;
  const VistaClima({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(clima.ciudad, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
        Text(clima.emoji, style: const TextStyle(fontSize: 90)),
        Text(clima.temperaturaTexto, style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w200)),
        Text(clima.descripcionBonita, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Dato('Sensación', '${clima.sensacion.round()}°'),
            _Dato('Humedad', '${clima.humedad}%'),
            _Dato('Viento', '${clima.vientoKmh} km/h'),
          ],
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  final String titulo;
  final String valor;
  const _Dato(this.titulo, this.valor);

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(titulo, style: const TextStyle(color: Colors.grey)),
      ]);
}
