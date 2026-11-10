# Plan HU-02 · Detalle de un pedido

Estado: APROBADO

## Contexto
La spec `specs/HU-02-detalle-pedido/spec.md` (APROBADA) define `GET /api/pedidos/{id}/detalle`: datos del pedido,
cliente con RUT normalizado y región, líneas con subtotal y total calculado desde las líneas. 11 CA en 3 fases.
Hoy existen `GET /salud`, `GET /api/pedidos/{id}` y `GET /api/pedidos` (HU-01).
Línea base: `dotnet test` → Core 36 y Api 12 en verde.

**Precondiciones y permisos (AGENTS.md + PO):**
- El PO marca este plan como APROBADO antes de escribir código.
- Solo se implementa lo que dice la spec; nada de reglas adicionales.
- **Una fase a la vez**: al cerrar cada fase el agente se detiene, informa y espera que el PO revise y haga el commit.
- El agente no usa git. No se agregan paquetes NuGet ni proyectos (`PedidosWeb.Api.Tests` ya existe), no se edita `PedidosWeb.sln`.
- No se modifican `ClientesService`, `Cliente`, `ClientesDeEjemplo`, `LineaPedido` ni la ruta `GET /api/pedidos/{id}`.

## Enfoque
**Toda la lógica en Core; la Api solo traduce Core ↔ HTTP** (igual que HU-01).

1. **Totales** (Fase 1): una clase estática calcula subtotal y total. No se agrega `Subtotal` a `LineaPedido`
   (es un archivo del material de la U3 y la spec no lo pide).
2. **Clientes** (Fase 2): `ClientesService` no expone los clientes (solo `proc2`/`proc3`) y no se toca, así que se agrega
   un repositorio mínimo `IClienteRepositorio` sobre `ClientesDeEjemplo.Crear()`. Sigue el patrón de pedidos y líneas,
   se inyecta por DI y permite probar CA-07 con un repositorio vacío.
3. **RUT** (Fase 2): `NormalizadorRut` quita puntos y espacios y pasa a mayúsculas (la misma regla que hoy está dentro de `proc2`).
4. **Detalle** (Fase 2): `ServicioDetallePedido.Obtener(id)` junta pedido + cliente + líneas + total; `null` si el pedido no existe.
5. **API** (Fase 3): `Results.Ok(detalle)` o `Results.NotFound()`. .NET 10 serializa en camelCase y `DateOnly` como
   `"2026-10-20"`, así que los nombres de los records producen el JSON de la spec sin atributos.

## Archivos

### Fase 1 · Calcular el total
| Archivo | Contenido |
|---|---|
| `src/PedidosWeb.Core/Lineas/CalculadoraTotales.cs` (nuevo) | `static class`: `decimal Subtotal(LineaPedido linea)` = `Cantidad × PrecioUnitario`; `decimal Total(IEnumerable<LineaPedido> lineas)` = suma de subtotales (0 si vacía). |
| `tests/PedidosWeb.Core.Tests/Lineas/CalculadoraTotalesTests.cs` (nuevo) | CA-01 a CA-04. |

### Fase 2 · Obtener el detalle
| Archivo | Contenido |
|---|---|
| `src/PedidosWeb.Core/Clientes/IClienteRepositorio.cs` (nuevo) | `Cliente? ObtenerPorId(string id)`. |
| `src/PedidosWeb.Core/Clientes/ClienteRepositorioEnMemoria.cs` (nuevo) | `sealed class`; constructor sin parámetros → `ClientesDeEjemplo.Crear()`; constructor `(IEnumerable<Cliente>)` para tests. Búsqueda por `Id` exacto. |
| `src/PedidosWeb.Core/Clientes/NormalizadorRut.cs` (nuevo) | `static string Normalizar(string rut)`: quita `.` y espacios, `ToUpperInvariant()`. Sin validar dígito verificador. |
| `src/PedidosWeb.Core/Pedidos/LineaDetalle.cs` (nuevo) | `sealed record LineaDetalle(int Numero, string Producto, int Cantidad, decimal PrecioUnitario, decimal Subtotal)`. |
| `src/PedidosWeb.Core/Pedidos/DetallePedido.cs` (nuevo) | `sealed record DetallePedido(int Id, string Folio, DateOnly Fecha, string Estado, string Sucursal, string ClienteId, string ClienteNombre, string? ClienteRut, string? ClienteRegion, IReadOnlyList<LineaDetalle> Lineas, decimal Total)`. |
| `src/PedidosWeb.Core/Pedidos/ServicioDetallePedido.cs` (nuevo) | `sealed class`, constructor `(IPedidoRepositorio, ILineaPedidoRepositorio, IClienteRepositorio)`; `DetallePedido? Obtener(int id)`. Usa `CalculadoraTotales`; `ClienteId`/`ClienteNombre` del pedido; RUT normalizado y región del cliente, o `null` si no se encuentra. Las líneas ya vienen ordenadas por `ObtenerPorPedido`. |
| `tests/PedidosWeb.Core.Tests/Pedidos/ServicioDetallePedidoTests.cs` (nuevo) | CA-05 a CA-08. |

### Fase 3 · Publicarlo en la API
| Archivo | Contenido |
|---|---|
| `src/PedidosWeb.Api/Program.cs` (modificado) | Registrar como singleton `ILineaPedidoRepositorio`, `IClienteRepositorio` y `ServicioDetallePedido`. Agregar `app.MapGet("/api/pedidos/{id:int}/detalle", (int id, ServicioDetallePedido servicio) => servicio.Obtener(id) is { } detalle ? Results.Ok(detalle) : Results.NotFound())`. La ruta `/api/pedidos/{id:int}` queda igual. |
| `tests/PedidosWeb.Api.Tests/Pedidos/DetallePedidoTests.cs` (nuevo) | CA-09 a CA-11, con `IClassFixture<WebApplicationFactory<Program>>` como `ListarPedidosTests`. |

## Un test xUnit por criterio de aceptación
Convención de AGENTS.md: `<Clase>Tests`, `Metodo_Escenario_Resultado`, en español, comentario `// CA-xx` sobre cada test.
Repositorios usados en los datos: `PedidoRepositorioEnMemoria`, `LineaPedidoRepositorioEnMemoria` y `ClienteRepositorioEnMemoria`.

**Core · `CalculadoraTotalesTests`** (Fase 1)
| CA | Test | Datos | Qué comprueba |
|---|---|---|---|
| CA-01 | `Subtotal_Linea1DelPedido8_Devuelve64500` | `ObtenerPorPedido(8)[0]` (3 × 21500) | `Subtotal` = 64500 |
| CA-02 | `Total_Pedido8_Devuelve120100` | `ObtenerPorPedido(8)` | `Total` = 120100 |
| CA-03 | `Total_Los45PedidosDeEjemplo_CoincideConPedidoTotal` | Los 45 pedidos de `ObtenerTodos()` y sus líneas | Lista de Id cuyo total calculado ≠ `Pedido.Total` → `Assert.Empty` |
| CA-04 | `Total_SinLineas_DevuelveCero` | Lista de líneas vacía | `Total` = 0 |

**Core · `ServicioDetallePedidoTests`** (Fase 2)
| CA | Test | Datos | Qué comprueba |
|---|---|---|---|
| CA-05 | `Obtener_Pedido8_DevuelveElDetalleCompleto` | Id 8, repositorios de ejemplo | `Id` 8, `Folio` `PED-STGO-000008`, `Fecha` 2026-10-20, `Estado` `Entregado`, `Sucursal` `STGO`, `ClienteId` `C-001`, `ClienteNombre` `Ferretería El Clavo`, `ClienteRut` `76123456-0`, `ClienteRegion` `RM`, `Lineas` con `Numero` 1, 2, 3 y `Total` 120100 |
| CA-06 | `Obtener_RutGuardadoComoElLegado_LoNormaliza` (`[Theory]`) | Id 7 y Id 3, repositorios de ejemplo | `ClienteRut` = `76990011-K` (7) y `76432198-7` (3) |
| CA-07 | `Obtener_ClienteDesconocido_DevuelveDatosDelPedidoYRutYRegionNull` | Id 8 con `ClienteRepositorioEnMemoria` vacío | Detalle no nulo; `ClienteId` `C-001` y `ClienteNombre` `Ferretería El Clavo` (del pedido); `ClienteRut` y `ClienteRegion` `null` |
| CA-08 | `Obtener_PedidoInexistente_DevuelveNull` | Id 999 | Resultado `null` |

**Api · `DetallePedidoTests`** (Fase 3)
| CA | Test | Datos | Qué comprueba |
|---|---|---|---|
| CA-09 | `ObtenerDetalle_Pedido8_Devuelve200ConElDetalle` | `GET /api/pedidos/8/detalle` | Status 200; `Content-Type` `application/json`; en el JSON (`JsonElement`): `total` 120100, `clienteRut` `76123456-0`, `lineas` con 3 elementos |
| CA-10 | `ObtenerDetalle_PedidoInexistente_Devuelve404` | `GET /api/pedidos/999/detalle` | Status 404 |
| CA-11 | `ObtenerPedido_Pedido8_NoCambia` | `GET /api/pedidos/8` | Status 200; el JSON tiene **exactamente** las 8 propiedades de `Pedido` (`id`, `folio`, `clienteId`, `clienteNombre`, `fecha`, `estado`, `total`, `sucursal`), sin `lineas`; deserializado a `Pedido` es igual a `PedidoRepositorioEnMemoria().ObtenerPorId(8)` |

Total: **11 métodos nuevos** (8 Core + 3 Api). `dotnet test` cuenta 12 casos nuevos porque CA-06 es `[Theory]` con 2 casos.

**Limitaciones:**
- `NormalizadorRut` y `ClienteRepositorioEnMemoria` no tienen tests propios; se prueban a través de CA-05 a CA-07 (un test por CA).
- El 404 "sin cuerpo" de la sección "Si el pedido no existe" no es un CA: CA-10 solo comprueba el status.
- CA-11 pasa desde antes de la Fase 3: es un test de regresión.

## Riesgos y mitigación
| Riesgo | Mitigación |
|---|---|
| Duplicar la regla del RUT que está dentro de `proc2` | Aceptado: `ClientesService` no se toca en esta historia. |
| `decimal` en JSON (`120100` vs `120100.0`) | CA-09 compara con `GetDecimal()`, que acepta ambos. |
| Total calculado ≠ `Pedido.Total` en datos futuros | La spec manda el total desde las líneas; CA-03 detecta cualquier diferencia en los datos de ejemplo. |
| Que `GET /api/pedidos/{id}` cambie sin que se note (`DetallePedido` contiene todos los campos de `Pedido`) | CA-11 comprueba el conjunto exacto de propiedades, no solo los valores. |

## Pasos
Cada fase: implementación + sus tests → `dotnet test` en verde → **parar y avisar al PO** (revisa y hace el commit).

**Fase 1 · Calcular el total**
1. Implementar `CalculadoraTotales` y escribir `CalculadoraTotalesTests` (CA-01 a CA-04).
2. `dotnet test` verde (Core 40, Api 12). **Parar.**

**Fase 2 · Obtener el detalle**
3. Implementar `IClienteRepositorio`, `ClienteRepositorioEnMemoria`, `NormalizadorRut`, `LineaDetalle`, `DetallePedido` y `ServicioDetallePedido`.
4. Escribir `ServicioDetallePedidoTests` (CA-05 a CA-08).
5. `dotnet test` verde (Core 45, Api 12). **Parar.**

**Fase 3 · Publicarlo en la API**
6. Registrar dependencias y la ruta en `Program.cs`; escribir `DetallePedidoTests` (CA-09 a CA-11).
7. `dotnet test` verde (Core 45, Api 15). **Parar.**
8. Verificación manual y aviso final al PO con los 11 CA cumplidos.

## Verificación
- Al cierre de cada fase: `dotnet build` sin advertencias nuevas y `dotnet test` con 0 fallos y los conteos indicados.
- Cada CA-01 a CA-11 tiene exactamente un método de test (tablas de arriba).
- Manual (Fase 3): `dotnet run --project src/PedidosWeb.Api` y abrir
  - `/api/pedidos/8/detalle` → 200, JSON como el ejemplo de la spec, `total` 120100.
  - `/api/pedidos/999/detalle` → 404.
  - `/api/pedidos/8` → igual que antes.
