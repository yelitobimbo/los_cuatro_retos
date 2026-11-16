import 'package:flutter/material.dart';

import 'estado_animo.dart';
import 'pelicula.dart';
import 'servicio_peliculas.dart';

void main() => runApp(const AppPeliculas());

class AppPeliculas extends StatelessWidget {
  const AppPeliculas({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Peli del finde',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const PantallaPeliculas(),
      );
}

class PantallaPeliculas extends StatefulWidget {
  const PantallaPeliculas({super.key});
  @override
  State<PantallaPeliculas> createState() => _PantallaPeliculasState();
}

class _PantallaPeliculasState extends State<PantallaPeliculas> {
  final servicio = ServicioPeliculas();
  EstadoAnimo? animo; // null = tendencias
  late Future<List<Pelicula>> peliculas = servicio.tendencias();
  Pelicula? alAzar;

  void cambiarAnimo(EstadoAnimo? nuevo) {
    setState(() {
      animo = nuevo;
      alAzar = null;
      peliculas = nuevo == null ? servicio.tendencias() : servicio.porAnimo(nuevo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍿 ¿Qué vemos este finde?')),
      body: Column(
        children: [
          if (servicio.modoDemo)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text('Modo demo: agrega tu clave de TMDB en secrets.json para ver películas reales.'),
            ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: const Text('🔥 Tendencias'),
                    selected: animo == null,
                    onSelected: (_) => cambiarAnimo(null),
                  ),
                ),
                for (final a in EstadoAnimo.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('${a.emoji} ${a.texto}'),
                      selected: animo == a,
                      onSelected: (_) => cambiarAnimo(a),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pelicula>>(
              future: peliculas,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }
                final lista = snapshot.data!;
                if (lista.isEmpty) return const Center(child: Text('No hay películas.'));
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FilledButton.icon(
                        icon: const Icon(Icons.casino),
                        label: const Text('Escoger una al azar'),
                        onPressed: () => setState(() => alAzar = peliculaAlAzar(lista)),
                      ),
                    ),
                    if (alAzar != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TarjetaPelicula(pelicula: alAzar!, destacada: true),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: lista.length,
                        itemBuilder: (_, i) => TarjetaPelicula(pelicula: lista[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TarjetaPelicula extends StatelessWidget {
  final Pelicula pelicula;
  final bool destacada;
  const TarjetaPelicula({super.key, required this.pelicula, this.destacada = false});

  @override
  Widget build(BuildContext context) {
    final url = pelicula.posterUrl;
    return Card(
      color: destacada ? Theme.of(context).colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: url == null
                  ? Container(
                      width: 80,
                      height: 120,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.movie, size: 40),
                    )
                  : Image.network(url, width: 80, height: 120, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (destacada) const Text('🎬 Tu película del finde:'),
                  Text(pelicula.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('⭐ ${pelicula.calificacion.toStringAsFixed(1)}   ${pelicula.anio}'),
                  const SizedBox(height: 4),
                  Text(pelicula.resumen, maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
