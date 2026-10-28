const metaInicial = 100.0;
const pasoMeta = 10.0;
const metaMinima = 10.0;

// Suma el cambio a la meta, pero nunca baja de metaMinima.
double ajustarMeta(double actual, double cambio) {
  final nueva = actual + cambio;
  return nueva < metaMinima ? metaMinima : nueva;
}

// Qué fracción de la meta ya se usó, siempre entre 0 y 1.
double avanceDeMeta({required double total, required double meta}) {
  if (meta <= 0) return 0; // evita dividir entre cero
  return (total / meta).clamp(0, 1).toDouble();
}