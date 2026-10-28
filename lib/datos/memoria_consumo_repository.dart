import '../dominio/consumo.dart';
import 'consumo_repository.dart';

// Implementación que guarda los consumos en memoria (se pierden al cerrar la app).
class MemoriaConsumoRepository implements ConsumoRepository {
  // Lista privada: aquí viven realmente los datos.
  final List<Consumo> _consumos = [];

  @override
  Future<void> guardar(Consumo consumo) async {
    _consumos.add(consumo);
  }

  // Regresa una copia que nadie puede modificar desde fuera.
  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_consumos);
}