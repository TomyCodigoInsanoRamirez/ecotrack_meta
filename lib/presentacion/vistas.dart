import 'package:flutter/material.dart';

import '../dominio/consumo.dart';

// ─────────────── Registro ───────────────
class FormularioRegistro extends StatefulWidget {
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  final String? error;
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<FormularioRegistro> {
  // Estado EFÍMERO: solo le importa a este formulario.
  final _litrosController = TextEditingController();
  String _laboratorio = laboratoriosUtez.first;

  @override
  void dispose() {
    _litrosController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final guardado = await widget.alGuardar(_laboratorio, _litrosController.text);
    if (!mounted) return; // la pantalla pudo cerrarse mientras esperábamos
    if (guardado) {
      _litrosController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consumo guardado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _laboratorio,
            decoration: const InputDecoration(labelText: 'Laboratorio'),
            items: [
              for (final lab in laboratoriosUtez)
                DropdownMenuItem(value: lab, child: Text(lab)),
            ],
            onChanged: (valor) {
              if (valor != null) setState(() => _laboratorio = valor);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('litros'),
            controller: _litrosController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litros',
              errorText: widget.error,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.guardando ? null : _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────── Historial ───────────────
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({super.key, required this.consumos, required this.total});

  final List<Consumo> consumos;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }
    return ListView(
      children: [
        ListTile(title: Text('Total: ${total.toStringAsFixed(1)} L')),
        for (final c in consumos)
          ListTile(
            title: Text(c.laboratorio),
            trailing: Text('${c.litros.toStringAsFixed(1)} L'),
          ),
      ],
    );
  }
}

// ─────────────── Meta ───────────────
class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.usado,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  final double usado;
  final double meta;
  final double avance;
  final bool superada;
  final VoidCallback alSubir;
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Usado: ${usado.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: avance),
          const SizedBox(height: 12),
          Text(superada ? 'Te pasaste de la meta' : 'Dentro de la meta'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const Key('bajarMeta'),
                onPressed: alBajar,
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                key: const Key('subirMeta'),
                onPressed: alSubir,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────── Contenedor con pestañas ───────────────
class PantallasEcoTrack extends StatefulWidget {
  const PantallasEcoTrack({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  final String titulo;
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<PantallasEcoTrack> createState() => _PantallasEcoTrackState();
}

class _PantallasEcoTrackState extends State<PantallasEcoTrack> {
  int _pestana = 0; // estado efímero: qué pestaña se ve

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: IndexedStack(
        index: _pestana,
        children: [widget.registro, widget.historial, widget.meta],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit), label: 'Registro'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Meta'),
        ],
      ),
    );
  }
}