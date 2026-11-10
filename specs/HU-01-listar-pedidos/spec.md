# HU-01 · Listar pedidos con filtros

Estado: APROBADA

## Historia de usuario
Como vendedor, quiero listar pedidos filtrando por cliente, estado y rango de fechas.

## Objetivo
Permitir que un vendedor encuentre rápido los pedidos que le interesan sin recorrer los 45 (y en el futuro miles) de pedidos
del sistema, combinando filtros por cliente, estado y período. El listado se expone en `GET /api/pedidos`, paginado,
y la lógica de filtrado vive en `PedidosWeb.Core`, de modo que siga funcionando cuando el repositorio en memoria se reemplace por PostgreSQL.

## Contrato
`GET /api/pedidos?clienteId=&clienteNombre=&estado=&desde=&hasta=&pagina=`

| Parámetro | Tipo | Regla |
|---|---|---|
| `clienteId` | texto | Igual a `ClienteId`, sin distinguir mayúsculas (RN3) |
| `clienteNombre` | texto | Contenido en `ClienteNombre`, sin distinguir mayúsculas ni tildes (RN4) |
| `estado` | texto | Uno de los 5 estados válidos, sin distinguir mayúsculas (RN5) |
| `desde`, `hasta` | fecha `yyyy-MM-dd` | Inclusivos y obligatorios juntos (RN6) |
| `pagina` | entero ≥ 1 | Opcional, por defecto 1. No es un filtro (RN9) |

Respuesta 200:
```json
{ "total": 3, "pagina": 1, "tamanoPagina": 20, "items": [ { "id": 8, "folio": "PED-STGO-000008", "clienteId": "C-001", "...": "..." } ] }
```
`items` son objetos `Pedido` completos. `total` es la cantidad de pedidos que cumplen los filtros (todas las páginas).

Errores: 400 con cuerpo ProblemDetails (RFC 9457) que indica el parámetro y el motivo.

## Reglas de negocio
- RN1 · Filtros: `clienteId`, `clienteNombre`, `estado` y rango (`desde`+`hasta`). Debe venir **al menos uno**.
- RN2 · Los filtros presentes se combinan con **Y (AND)**.
- RN3 · `clienteId`: coincide si es **igual a `ClienteId`**, ignorando mayúsculas. No hay coincidencia parcial (`C-00` no encuentra nada).
- RN4 · `clienteNombre`: coincide si está **contenido en `ClienteNombre`**, ignorando mayúsculas, **tildes y ñ** (`dona` encuentra "Doña Rosa", `almacen` encuentra "Almacén La Esquina").
- RN5 · `estado`: un solo valor, de esta lista: **Pendiente, Confirmado, Despachado, Entregado, Anulado**; se ignoran mayúsculas.
- RN6 · `desde`/`hasta` sobre `Fecha` (`DateOnly`), formato `yyyy-MM-dd`, **inclusivos**, **obligatorios juntos** y con `desde ≤ hasta`.
- RN7 · Orden: **`Fecha` descendente**; a igual fecha, **`Id` ascendente**.
- RN8 · Paginación: **20 pedidos por página** (fijo); `pagina` por defecto 1. Una página más allá de la última responde 200 con `items` vacío y el `total` real.
- RN9 · `pagina` no cuenta como filtro para RN1.
- RN10 · Un parámetro presente pero vacío o solo con espacios es un error (no se ignora).
- RN11 · Sin coincidencias (ej. cliente inexistente) no es error: 200 con `total` 0 e `items` vacío.
- RN12 · El vendedor ve todos los pedidos (no hay restricción por vendedor en esta historia).

## Criterios de aceptación
Datos: los 45 pedidos de `PedidoRepositorioEnMemoria`. Los Id se listan en el orden esperado (RN7).

Filtrado (Core):
- [ ] CA1 · `clienteId=C-001` → total 5: 8, 16, 24, 32, 40.
- [ ] CA2 · `clienteId=c-001` → mismo resultado que CA1.
- [ ] CA3 · `clienteId=C-00` → total 0 (sin coincidencia parcial).
- [ ] CA4 · `clienteNombre=clavo` → mismo resultado que CA1.
- [ ] CA5 · `clienteNombre=ANDES` → total 6: 42, 2, 10, 18, 26, 34.
- [ ] CA6 · `clienteNombre=dona` → total 6 (Doña Rosa): 21, 29, 37, 45, 5, 13.
- [ ] CA7 · `clienteNombre=almacen` → total 5 (Almacén La Esquina): 23, 31, 39, 7, 15.
- [ ] CA8 · `estado=Pendiente` → total 5: 27, 18, 45, 9, 36.
- [ ] CA9 · `estado=anulado` → total 5: 2, 29, 20, 11, 38.
- [ ] CA10 · `desde=2026-10-20&hasta=2026-10-20` → total 1: 8 (límites inclusivos).
- [ ] CA11 · `clienteId=C-001&estado=Entregado` → total 3: 8, 24, 40.
- [ ] CA12 · `clienteId=C-001&estado=Entregado&desde=2026-09-01&hasta=2026-09-30` → total 2: 24, 40.
- [ ] CA13 · `clienteId=C-001&clienteNombre=andes` → total 0 (AND entre ambos parámetros de cliente).
- [ ] CA14 · `clienteId=C-999` → 200, total 0, `items` vacío.
- [ ] CA15 · Orden: en todo resultado, cada pedido tiene `Fecha` ≤ la del anterior; a igual fecha, `Id` creciente.

Paginación:
- [ ] CA16 · `desde=2026-10-01&hasta=2026-10-31` → total 23, pagina 1, tamanoPagina 20, 20 items (primero 21, último 18).
- [ ] CA17 · `desde=2026-10-01&hasta=2026-10-31&pagina=2` → total 23, 3 items: 39, 20, 41.
- [ ] CA18 · `desde=2026-09-01&hasta=2026-09-30&pagina=2` → total 22, 2 items: 19, 40.
- [ ] CA19 · `clienteId=C-001&pagina=99` → 200, total 5, `items` vacío.

Errores (Api, 400 ProblemDetails):
- [ ] CA20 · Sin parámetros → 400.
- [ ] CA21 · Solo `pagina=2` → 400 (RN9).
- [ ] CA22 · `desde=2026-10-01` sin `hasta` → 400; y `hasta=2026-10-31` sin `desde` → 400.
- [ ] CA23 · `desde=2026-10-31&hasta=2026-10-01` → 400 (fechas invertidas).
- [ ] CA24 · `desde=31-10-2026&hasta=2026-10-31` → 400 (formato inválido).
- [ ] CA25 · `estado=Perdido` → 400.
- [ ] CA26 · `pagina=0`, `pagina=-1` y `pagina=abc` (con `clienteId=C-001`) → 400.
- [ ] CA27 · `estado=&clienteId=C-001` y `clienteNombre=%20%20` → 400 (parámetro vacío).

## Ejemplos de entrada y salida
| Entrada | Salida esperada |
|---|---|
| `GET /api/pedidos?clienteId=C-001&estado=Entregado` | 200 `{ total: 3, pagina: 1, tamanoPagina: 20, items: [8, 24, 40] }` |
| `GET /api/pedidos?clienteNombre=dona` | 200 `{ total: 6, ..., items: [21, 29, 37, 45, 5, 13] }` |
| `GET /api/pedidos?desde=2026-10-01&hasta=2026-10-31&pagina=2` | 200 `{ total: 23, pagina: 2, tamanoPagina: 20, items: [39, 20, 41] }` |
| `GET /api/pedidos?clienteId=C-999` | 200 `{ total: 0, pagina: 1, tamanoPagina: 20, items: [] }` |
| `GET /api/pedidos` | 400 ProblemDetails: al menos un filtro es obligatorio |
| `GET /api/pedidos?desde=2026-10-31&hasta=2026-10-01` | 400 ProblemDetails: `desde` no puede ser posterior a `hasta` |

(En la tabla, `items` muestra solo los Id por brevedad.)

## Errores esperados
Todos responden **400** con cuerpo **ProblemDetails** que identifica el parámetro y el motivo:
- E1 · Ningún filtro (RN1, RN9).
- E2 · Solo uno de `desde`/`hasta` (RN6).
- E3 · `desde` > `hasta` (RN6).
- E4 · Fecha con formato distinto de `yyyy-MM-dd` (RN6).
- E5 · `estado` fuera de la lista válida (RN5).
- E6 · `pagina` no entera o < 1 (RN8).
- E7 · Parámetro vacío o solo con espacios (RN10).

## Fuera de alcance
- Crear, editar o anular pedidos.
- Persistencia en base de datos (PostgreSQL llega en una unidad posterior).
- Filtros por sucursal, folio o total; varios estados a la vez.
- Tamaño de página configurable.
- Autenticación y restricción de pedidos por vendedor.

## Notas de implementación
- Tests de reglas de filtrado y orden en `tests/PedidosWeb.Core.Tests/Pedidos/`.
- Tests de contrato HTTP y errores en el nuevo `tests/PedidosWeb.Api.Tests/` con `WebApplicationFactory<Program>`
  (paquete `Microsoft.AspNetCore.Mvc.Testing`, aprobado por el PO para esta historia).
- Un test xUnit por criterio de aceptación (AGENTS.md).

## Preguntas abiertas
Ninguna.
