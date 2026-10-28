# Gestión de estado — EcoTrack Meta

**Equipo:** Tomás Ramírez Bartolo y [nombre de tu compañero]
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero: solo le importa al contenedor de pestañas y cambia con `setState`. | Campo `_pestana` en `_PantallasEcoTrackState` (`lib/presentacion/vistas.dart`). |
| Texto del campo de litros | Efímero: solo le importa al formulario hasta que se guarda. | `_litrosController` en `_FormularioRegistroState` (`lib/presentacion/vistas.dart`). |
| consumos y meta | Compartido: las tres pestañas dependen de ellos y avisan con `notifyListeners()`. | Campos `consumos` y `meta` de `ConsumosViewModel` (`lib/presentacion/consumos_view_model.dart`). |
| total y metaSuperada | Derivado: se calculan a partir de `consumos` y `meta`, no se guardan. | Getters `total` y `metaSuperada` de `ConsumosViewModel`; `avance` usa `avanceDeMeta` del dominio. |
| Lo que regresa todos() | Persistido: es la fuente de verdad y se entrega como lista no modificable. | Lista privada `_consumos` de `MemoriaConsumoRepository` (`lib/datos/memoria_consumo_repository.dart`), probado en `test/etapa2_datos_test.dart`. |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Un solo `ConsumosViewModel` creado en `_AppChangeNotifierState` y pasado a `RegistroCN`, `HistorialCN` y `MetaCN`; comprobado en `test/etapa4_change_notifier_test.dart`. | Un solo `ConsumosViewModel` creado por `ChangeNotifierProvider` en `AppProvider`; las tres pestañas lo leen con `context.watch`; comprobado en `test/etapa5_provider_test.dart`. |
| Capas | `vistas.dart` solo importa `material.dart` y `dominio/consumo.dart`; el ViewModel importa `foundation.dart`, no `material.dart`. | Igual que A: `consumos_view_model.dart` y `vistas.dart` no cambiaron; solo `b_provider.dart` importa `provider`. |
| Encaje con el diagrama | Vista tonta → adaptador con `ListenableBuilder` → ViewModel → contrato `ConsumoRepository`. | Mismo diagrama; solo cambia el adaptador, que usa `context.watch` en lugar de `ListenableBuilder`. |
| Constructores que reciben vm | 3: `RegistroCN`, `HistorialCN` y `MetaCN`; una subpantalla nueva sumaría otro. | 0: `RegistroProvider`, `HistorialProvider` y `MetaProvider` son `const` y piden el ViewModel al árbol. |
| Quién libera el ViewModel | Nosotros, en `_AppChangeNotifierState.dispose()`, porque ese `State` lo creó. | `ChangeNotifierProvider` lo libera solo; no escribimos ningún `dispose()`. |
| Costo de adoptarla ahora | Sin dependencias extra, pero hay que pasar `vm` por constructor y escribir `dispose()` y un `ListenableBuilder` por pantalla. | Una dependencia (`provider` en `pubspec.yaml`) y aprender `watch`/`read`; a cambio, menos código de cableado. |
| Sustitución de la fuente de datos | Solo `main_change_notifier.dart` conoce `MemoriaConsumoRepository`; `AppChangeNotifier` recibe el contrato. | Solo `main.dart` conoce `MemoriaConsumoRepository`; `AppProvider` recibe el contrato. |

## Elección

Elegimos: B · provider, porque usa el mismo ViewModel con menos cableado (0 constructores reciben `vm`) y libera el ViewModel automáticamente.
Se mantiene esta pieza del diagrama: `ConsumosViewModel`, que no cambió ni una línea entre la etapa 4 y la 5.
Esta pieza es la que podría sustituirse después: `MemoriaConsumoRepository`, que se puede cambiar por otra implementación de `ConsumoRepository` (por ejemplo, una base de datos o una API) tocando solo `main.dart`.