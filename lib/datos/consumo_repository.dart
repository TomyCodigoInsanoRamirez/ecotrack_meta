import '../dominio/consumo.dart';

// Contrato: qué se puede hacer con los consumos, no cómo.
abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}