# HU-02 · Detalle de un pedido

Estado: APROBADO

**Historia:** Como vendedor, quiero ver el detalle de un pedido (cliente, líneas, total y estado),
para responderle al cliente sin entrar al sistema legado.

## Qué devuelve

La ruta nueva `GET /api/pedidos/{id}/detalle` devuelve:

- Del pedido: `id`, `folio`, `fecha` (`yyyy-MM-dd`), `estado` y `sucursal`.
- Del cliente: `clienteId`, `clienteNombre`, `clienteRut` y `clienteRegion`.
  - `clienteRut` normalizado: sin puntos ni espacios y con la `K` en mayúscula (`76.990.011-k` → `76990011-K`).
  - `clienteRegion`: el código tal como está guardado (`RM`, `II`, `V`, `VIII`).
  - Si el cliente del pedido no está entre los clientes conocidos, ambos van en `null`.
- De cada línea, ordenadas por `numero`: `numero`, `producto`, `cantidad`, `precioUnitario` y `subtotal` (`cantidad × precioUnitario`).
- Total: `total`, la suma de los subtotales de las líneas (0 si no tiene líneas).

Montos en pesos chilenos (CLP), `decimal` sin decimales, **sin IVA**.

```json
{ "id": 8, "folio": "PED-STGO-000008", "fecha": "2026-10-20", "estado": "Entregado", "sucursal": "STGO",
  "clienteId": "C-001", "clienteNombre": "Ferretería El Clavo", "clienteRut": "76123456-0", "clienteRegion": "RM",
  "lineas": [ { "numero": 1, "producto": "Harina para pan 25 kg", "cantidad": 3, "precioUnitario": 21500, "subtotal": 64500 }, "..." ],
  "total": 120100 }
```

## Fases

Se construye en 3 fases. Cada una termina con `dotnet test` en verde y la revisión del PO (que hace el commit) **antes** de pasar a la siguiente.

| Fase | Qué se construye | Dónde | Se verifica con |
|---|---|---|---|
| 1 · Calcular el total | Subtotal de una línea y total de un pedido desde sus líneas | `PedidosWeb.Core` | CA-01 a CA-04 (tests Core) |
| 2 · Obtener el detalle | Armar el detalle: pedido + cliente + líneas + total | `PedidosWeb.Core` | CA-05 a CA-08 (tests Core) |
| 3 · Publicarlo en la API | Ruta `GET /api/pedidos/{id}/detalle` que solo traduce Core ↔ HTTP | `PedidosWeb.Api` | CA-09 a CA-11 (tests Api) |

## Criterios de aceptación

Datos: los 45 pedidos, sus líneas y los 8 clientes de ejemplo. Cada criterio se puede comprobar con un sí o un no.

**Fase 1 · Calcular el total**
- **CA-01** · Dada la línea 1 del pedido 8 (3 × 21500), cuando calculo su subtotal, entonces es 64500.
- **CA-02** · Dado el pedido 8, cuando calculo su total, entonces es 120100 (64500 + 35400 + 20200).
- **CA-03** · Dados los 45 pedidos de ejemplo, cuando calculo el total de cada uno desde sus líneas, entonces es igual a su `Pedido.Total`.
- **CA-04** · Dado un pedido sin líneas, cuando calculo su total, entonces es 0.

**Fase 2 · Obtener el detalle**
- **CA-05** · Dado el pedido 8, cuando obtengo su detalle, entonces trae folio `PED-STGO-000008`, fecha 2026-10-20, estado `Entregado`,
  sucursal `STGO`, cliente `C-001` `Ferretería El Clavo`, RUT `76123456-0`, región `RM`, 3 líneas con números 1, 2, 3 y total 120100.
- **CA-06** · Dados el pedido 7 (RUT guardado `76.990.011-k`) y el pedido 3 (RUT guardado `76 432 198-7`), cuando obtengo su detalle,
  entonces el RUT es `76990011-K` y `76432198-7`.
- **CA-07** · Dado un pedido cuyo `ClienteId` no está entre los clientes conocidos, cuando obtengo su detalle, entonces se entrega
  con `clienteId` y `clienteNombre` del pedido, y `clienteRut` y `clienteRegion` en `null`.
- **CA-08** · Dado el id 999 (no existe), cuando obtengo su detalle, entonces no hay detalle.

**Fase 3 · Publicarlo en la API**
- **CA-09** · Dado el pedido 8, cuando llamo a `GET /api/pedidos/8/detalle`, entonces responde 200 JSON con `total` 120100,
  `clienteRut` `76123456-0` y 3 `lineas`.
- **CA-10** · Dado el id 999, cuando llamo a `GET /api/pedidos/999/detalle`, entonces responde 404.
- **CA-11** · Dado el pedido 8, cuando llamo a `GET /api/pedidos/8`, entonces responde 200 con el mismo `Pedido` de siempre (la ruta no cambia).

## Si el pedido no existe

`GET /api/pedidos/{id}/detalle` responde **404**, sin cuerpo, igual que `GET /api/pedidos/{id}`.

## Restricciones

- La ruta `GET /api/pedidos/{id}` no cambia.
- La lógica (subtotal, total, normalización del RUT y armado del detalle) vive en `PedidosWeb.Core`; la API solo la expone.
- `ClientesService` no se modifica en esta historia (se refactoriza en la etapa 2, con sus 4 tests como red).
- Un test xUnit por criterio de aceptación (AGENTS.md): Fases 1 y 2 en `tests/PedidosWeb.Core.Tests/`, Fase 3 en `tests/PedidosWeb.Api.Tests/`.

## Fuera de alcance

- IVA, descuentos y recargos (llegan con la migración del cálculo de totales, en la Unidad 5).
- Zona del cliente ("Zona centro", etc.) y si el cliente está activo.
- Formato de moneda para mostrar en pantalla.
- Validar el dígito verificador del RUT.
- Crear o editar pedidos o líneas.
