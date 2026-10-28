import 'package:flutter/foundation.dart';

import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this._repositorio);

  // Recibe el CONTRATO; no sabe si es memoria, nube o lo que sea.
  final ConsumoRepository _repositorio;

  // ── Estado compartido (con sus valores iniciales) ──
  List<Consumo> consumos = [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // ── Estado derivado: getters, se calculan cada vez ──
  double get total => consumos.fold(0.0, (suma, c) => suma + c.litros);
  double get avance => avanceDeMeta(total: total, meta: meta);
  bool get metaSuperada => total > meta;

  // ── Acciones ──
  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    // a. Texto a número: acepta "12,5" y espacios alrededor.
    final litros = double.tryParse(litrosTexto.trim().replaceAll(',', '.'));

    // b. Le pregunta al dominio. Si no es válido, NO toca el repositorio.
    final mensaje = validarLitros(litros);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    // c. Es válido: marca guardando y limpia el error.
    guardando = true;
    error = null;
    notifyListeners();

    // d. Guarda y vuelve a leer la lista completa (reasignar, no .add).
    await _repositorio.guardar(Consumo(laboratorio: laboratorio, litros: litros!));
    consumos = await _repositorio.todos();

    // e. Termina.
    guardando = false;
    notifyListeners();
    return true;
  }

  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}