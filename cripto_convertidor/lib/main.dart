import 'package:flutter/material.dart';

import 'cripto.dart';
import 'servicio_cripto.dart';

void main() => runApp(const AppCripto());

class AppCripto extends StatelessWidget {
  const AppCripto({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Convertidor cripto',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const PantallaCripto(),
      );
}

class PantallaCripto extends StatefulWidget {
  const PantallaCripto({super.key});
  @override
  State<PantallaCripto> createState() => _PantallaCriptoState();
}

class _PantallaCriptoState extends State<PantallaCripto> {
  final servicio = ServicioCripto();
  final _monto = TextEditingController(text: '100');
  late Future<List<Cripto>> precios = servicio.precios();
  DateTime actualizado = DateTime.now();

  @override
  void dispose() {
    _monto.dispose();
    super.dispose();
  }

  void refrescar() => setState(() {
        precios = servicio.precios();
        actualizado = DateTime.now();
      });

  @override
  Widget build(BuildContext context) {
    final monto = leerMonto(_monto.text);
    final hora = '${actualizado.hour.toString().padLeft(2, '0')}:'
        '${actualizado.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🪙 Convertidor de cripto'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: refrescar)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto en dólares (USD)',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                errorText: monto == null ? 'Escribe un número válido' : null,
              ),
              onChanged: (_) => setState(() {}), // recalcula al escribir
            ),
            const SizedBox(height: 8),
            Text('Precios de CoinGecko · actualizado a las $hora',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Cripto>>(
                future: precios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('${snapshot.error}'.replaceFirst('Exception: ', ''),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        FilledButton(onPressed: refrescar, child: const Text('Reintentar')),
                      ]),
                    );
                  }
                  final lista = snapshot.data!;
                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (_, i) {
                      final c = lista[i];
                      final compras = monto == null ? null : cuantoCompras(monto, c.precioUsd);
                      return Card(
                        child: ListTile(
                          leading: Text(c.emoji, style: const TextStyle(fontSize: 32)),
                          title: Text('${c.nombre} (${c.simbolo})'),
                          subtitle: Text('1 ${c.simbolo} = ${formatearUsd(c.precioUsd)}'),
                          trailing: Text(
                            compras == null ? '-' : '${compras.toStringAsFixed(6)} ${c.simbolo}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
