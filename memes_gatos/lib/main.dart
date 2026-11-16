import 'package:flutter/material.dart';

import 'url_gato.dart';

void main() => runApp(const AppMemes());

class AppMemes extends StatelessWidget {
  const AppMemes({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Memes de gatos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
        home: const PantallaMemes(),
      );
}

class PantallaMemes extends StatefulWidget {
  const PantallaMemes({super.key});
  @override
  State<PantallaMemes> createState() => _PantallaMemesState();
}

class _PantallaMemesState extends State<PantallaMemes> {
  final _texto = TextEditingController(text: 'Hola UTNG');
  FiltroGato filtro = FiltroGato.ninguno;
  double tamano = 40;
  String color = 'white';
  int semilla = 0;

  static const colores = {'white': Colors.white, 'yellow': Colors.yellow, 'red': Colors.red, 'black': Colors.black};

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void nuevoGato() => setState(() => semilla++);

  @override
  Widget build(BuildContext context) {
    final url = urlGato(
      texto: _texto.text,
      filtro: filtro,
      tamanoLetra: tamano.round(),
      colorLetra: color,
      semilla: semilla,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('🐱 Generador de memes de gatos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey.shade200,
                child: Image.network(
                  url.toString(),
                  key: ValueKey(url.toString()),
                  fit: BoxFit.contain,
                  // En Chrome permite mostrar la imagen aunque el servidor no tenga CORS.
                  // Si tu versión de Flutter marca error en esta línea, bórrala.
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  loadingBuilder: (context, hijo, progreso) =>
                      progreso == null ? hijo : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, pila) =>
                      const Center(child: Text('😿 No se pudo cargar el gato. Revisa tu internet.')),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _texto,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'Frase del meme',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => nuevoGato(),
          ),
          Text('Tamaño de letra: ${tamano.round()}'),
          Slider(
            value: tamano,
            min: 20,
            max: 80,
            divisions: 12,
            onChanged: (v) => setState(() => tamano = v),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final entrada in colores.entries)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: entrada.value),
                  label: Text(entrada.key),
                  selected: color == entrada.key,
                  onSelected: (_) => setState(() => color = entrada.key),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FiltroGato>(
            value: filtro,
            decoration: const InputDecoration(labelText: 'Filtro', border: OutlineInputBorder()),
            items: [
              for (final f in FiltroGato.values) DropdownMenuItem(value: f, child: Text(f.texto)),
            ],
            onChanged: (f) => setState(() => filtro = f ?? FiltroGato.ninguno),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Otro gato'),
            onPressed: nuevoGato,
          ),
          const SizedBox(height: 8),
          SelectableText('URL: $url', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
