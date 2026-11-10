# Plan HU-01 · Listar pedidos con filtros

## Contexto
La spec `specs/HU-01-listar-pedidos/spec.md` define `GET /api/pedidos` con filtros (clienteId, clienteNombre, estado,
desde/hasta), orden fijo, paginación de 20 y errores 400 ProblemDetails, con 27 criterios de aceptación (CA1–CA27).
Hoy solo existen `GET /salud` y `GET /api/pedidos/{id}`. Línea base: `dotnet test` → 7/7 en verde.

**Precondiciones y permisos (AGENTS.md + PO):**
- El PO marca la spec como `Estado: APROBADA` **antes** de escribir código; el agente no edita la spec y no empieza mientras no lo vea.
- **Solo se implementa lo que dice la spec.** Nada de reglas adicionales (las antiguas D1–D6 quedan descartadas).
- El agente no usa git; el PO hace los commits, siempre con tests en verde.
- Aprobados por el PO: paquete `Microsoft.AspNetCore.Mvc.Testing`, proyecto `tests/PedidosWeb.Api.Tests`,
  **editar `PedidosWeb.sln`** para agregarlo y guardar este plan como `specs/HU-01-listar-pedidos/plan.md`.

## Enfoque
**Toda la lógica en Core; la Api solo traduce HTTP ↔ Core.**

1. **La Api lee cada parámetro como texto** desde `request.Query` (`TryGetValue(nombre, out v) ? v.ToString() : null`)
   y Core lo valida/parsea. Motivo técnico: si se enlazara `int pagina` o `DateOnly desde`, ASP.NET respondería su
   propio 400 a `pagina=abc` o `desde=31-10-2026` sin el ProblemDetails de la spec, y no se distinguiría "ausente" de "vacío" (RN10).
2. **Validación** (Core) produce `parámetro → mensajes`; la Api lo entrega a `Results.ValidationProblem(...)`
   → 400 `application/problem+json` (RFC 9457) que indica parámetro y motivo.
3. **Búsqueda** (Core): filtra `IPedidoRepositorio.ObtenerTodos()` con AND, ordena `Fecha` desc + `Id` asc, pagina 20.
   No se cambia `IPedidoRepositorio`.
4. **Nombres sin tildes** (RN4): `Normalize(FormD)` + quitar `UnicodeCategory.NonSpacingMark` + `ToUpperInvariant()` en ambos lados.

## Casos que la spec no cubre (no se agregan reglas)
El código no tiene lógica especial para estos casos; esto es lo que resulta de aplicar solo la spec. **No se prueban ni se garantizan.**
| Caso | Comportamiento resultante |
|---|---|
| Espacios alrededor de un valor con texto (`clienteId=%20C-001%20`) | No se recorta: no coincide → 200 vacío. En `estado`/fechas/`pagina` falla la validación de RN5/RN6/RN8 → 400. |
| Parámetro repetido (`estado=Pendiente&estado=Anulado`) | ASP.NET une los valores con coma (`"Pendiente,Anulado"`): estado inválido → 400 (RN5); en `clienteId` no coincide → 200 vacío. |
| Parámetro fuera del contrato (`?sucursal=STGO`) | No se lee. Si es el único, no hay filtros → 400 (RN1). |
| `pagina` que no cabe en `int` | `int.TryParse` falla → 400 (E6, "no entera"). |
| Varios errores a la vez | Cada parámetro se valida por separado; la cantidad de errores informados no se garantiza. |
| Clave de E1 (ningún filtro) | La spec no nombra un parámetro: el mensaje va en `detail` del ProblemDetails, sin inventar una clave en `errors`. |

Si el PO quiere fijar alguno, se agrega a la spec como RN + CA y se implementa en una iteración posterior.

## Archivos

### Nuevos en `src/PedidosWeb.Core/Pedidos/`
| Archivo | Contenido |
|---|---|
| `EstadosPedido.cs` | `static class` con los 5 estados válidos (RN5); búsqueda con `StringComparer.OrdinalIgnoreCase`. |
| `FiltroPedidos.cs` | `sealed record FiltroPedidos(string? ClienteId, string? ClienteNombre, string? Estado, DateOnly? Desde, DateOnly? Hasta, int Pagina)`: filtro ya validado. |
| `ValidadorFiltroPedidos.cs` | `static ResultadoValidacionFiltro Validar(string? clienteId, string? clienteNombre, string? estado, string? desde, string? hasta, string? pagina)`. Reglas: presente pero vacío/espacios → error (RN10); al menos un filtro, `pagina` no cuenta (RN1, RN9); fechas `DateOnly.TryParseExact("yyyy-MM-dd", InvariantCulture)`, juntas y `desde ≤ hasta` (RN6); estado en la lista (RN5); `pagina` entero ≥ 1, por defecto 1 (RN8). |
| `ResultadoValidacionFiltro.cs` | `sealed record` con `FiltroPedidos? Filtro`, `IReadOnlyDictionary<string, string[]> Errores`, `string? Detalle` (para E1) y `EsValido`. |
| `PaginaPedidos.cs` | `sealed record PaginaPedidos(int Total, int Pagina, int TamanoPagina, IReadOnlyList<Pedido> Items)` → JSON `{ total, pagina, tamanoPagina, items }` (nombre `Items` impuesto por el contrato de la spec). |
| `BuscadorPedidos.cs` | `sealed class` con constructor `(IPedidoRepositorio)`; `const int TamanoPagina = 20`; `PaginaPedidos Buscar(FiltroPedidos filtro)`: AND (RN2–RN6), orden (RN7), salto calculado en `long` para que una página muy alta devuelva `items` vacío sin desbordar (RN8). |

### Modificados
| Archivo | Cambio |
|---|---|
| `src/PedidosWeb.Api/Program.cs` | Registrar `BuscadorPedidos` (singleton, como el repositorio). Reemplazar el comentario "HU-01 · PENDIENTE" por `app.MapGet("/api/pedidos", (HttpRequest request, BuscadorPedidos buscador) => ...)`: leer los 6 parámetros, llamar a `ValidadorFiltroPedidos.Validar` y devolver `Results.ValidationProblem(errores, detail)` o `Results.Ok(buscador.Buscar(filtro))`. Sin reglas de negocio. |
| `PedidosWeb.sln` | Agregar `tests/PedidosWeb.Api.Tests` (autorizado por el PO) **editando el archivo a mano**, sin `dotnet sln add` (evita entradas `x64`/`x86` que la solución no usa). Siguiendo el patrón existente: (1) bloque `Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "PedidosWeb.Api.Tests", "tests\PedidosWeb.Api.Tests\PedidosWeb.Api.Tests.csproj", "{A1B2C3D4-0006-4000-8000-000000000006}"` / `EndProject` tras el de Core.Tests; (2) 4 líneas en `ProjectConfigurationPlatforms` (`Debug`/`Release` × `ActiveCfg`/`Build.0`, solo `Any CPU`); (3) en `NestedProjects`, `{A1B2C3D4-0006-...} = {A1B2C3D4-0002-...}` (carpeta `tests`). Se respetan los tabs del archivo. |

### Nuevo proyecto `tests/PedidosWeb.Api.Tests/`
- `PedidosWeb.Api.Tests.csproj`: igual al de Core.Tests (net10.0, `Nullable`, `ImplicitUsings`, `IsTestProject`,
  `Microsoft.NET.Test.Sdk` 17.11.1, `xunit` 2.9.2, `xunit.runner.visualstudio` 2.8.2, `<Using Include="Xunit" />`)
  + `Microsoft.AspNetCore.Mvc.Testing` 10.0.x + `ProjectReference` a `src/PedidosWeb.Api`.
- `Pedidos/ListarPedidosTests.cs`: `IClassFixture<WebApplicationFactory<Program>>` (reutiliza el
  `public partial class Program { }` que ya existe en `Program.cs`).

### Nuevo test en Core
- `tests/PedidosWeb.Core.Tests/Pedidos/BuscadorPedidosTests.cs`: `new BuscadorPedidos(new PedidoRepositorioEnMemoria())`
  (los mismos 45 pedidos de la spec); helper privado que devuelve los `Id` de `Items`.

## Un test xUnit por criterio de aceptación
Convención de AGENTS.md: clase `<Clase>Tests`, método `Metodo_Escenario_Resultado`, todo en español.
Los CA con varios casos usan `[Theory]` (un test por CA). Cada test va en la sección que le asigna la spec.

**Core · `BuscadorPedidosTests`** — spec: "Filtrado (Core)" y "Paginación" (CA1–CA19)
| CA | Test |
|---|---|
| CA1 | `Buscar_ClienteIdC001_Devuelve5PedidosOrdenados` → 8, 16, 24, 32, 40 |
| CA2 | `Buscar_ClienteIdEnMinusculas_DevuelveLosMismosQueC001` |
| CA3 | `Buscar_ClienteIdParcial_NoDevuelvePedidos` (`C-00` → 0) |
| CA4 | `Buscar_ClienteNombreClavo_DevuelveLosPedidosDeC001` |
| CA5 | `Buscar_ClienteNombreAndesEnMayusculas_Devuelve6Pedidos` → 42, 2, 10, 18, 26, 34 |
| CA6 | `Buscar_ClienteNombreDonaSinTilde_EncuentraDonaRosa` → 21, 29, 37, 45, 5, 13 |
| CA7 | `Buscar_ClienteNombreAlmacenSinTilde_EncuentraAlmacenLaEsquina` → 23, 31, 39, 7, 15 |
| CA8 | `Buscar_EstadoPendiente_Devuelve5Pedidos` → 27, 18, 45, 9, 36 |
| CA9 | `Buscar_EstadoAnuladoEnMinusculas_Devuelve5Pedidos` → 2, 29, 20, 11, 38 |
| CA10 | `Buscar_RangoDeUnDia_IncluyeLosLimites` → 8 |
| CA11 | `Buscar_ClienteYEstado_CombinaConY` → 8, 24, 40 |
| CA12 | `Buscar_ClienteEstadoYRango_CombinaConY` → 24, 40 |
| CA13 | `Buscar_ClienteIdYNombreDeOtroCliente_NoDevuelvePedidos` |
| CA14 | `Buscar_ClienteInexistente_DevuelveTotalCeroYSinItems` |
| CA15 | `Buscar_CualquierFiltro_OrdenaPorFechaDescYIdAsc` (`[Theory]` sobre varios filtros) |
| CA16 | `Buscar_RangoOctubrePagina1_Devuelve20DeTotal23` (primero 21, último 18, `TamanoPagina` 20) |
| CA17 | `Buscar_RangoOctubrePagina2_DevuelveLos3Restantes` → 39, 20, 41 |
| CA18 | `Buscar_RangoSeptiembrePagina2_DevuelveLos2Restantes` → 19, 40 |
| CA19 | `Buscar_PaginaMasAllaDeLaUltima_DevuelveItemsVacioYTotalReal` (`Total` 5) |

**Api · `ListarPedidosTests`** — spec: "Errores (Api, 400 ProblemDetails)" (CA20–CA27)
Cada test comprueba 400 y `Content-Type: application/problem+json`.
| CA | Test |
|---|---|
| CA20 | `ListarPedidos_SinParametros_Devuelve400` |
| CA21 | `ListarPedidos_SoloPagina_Devuelve400` |
| CA22 | `ListarPedidos_SoloUnLimiteDeFecha_Devuelve400` (`[Theory]`: solo desde / solo hasta) |
| CA23 | `ListarPedidos_FechasInvertidas_Devuelve400` |
| CA24 | `ListarPedidos_FechaConFormatoInvalido_Devuelve400` |
| CA25 | `ListarPedidos_EstadoInvalido_Devuelve400` |
| CA26 | `ListarPedidos_PaginaInvalida_Devuelve400` (`[Theory]`: 0, -1, abc) |
| CA27 | `ListarPedidos_ParametroVacio_Devuelve400` (`[Theory]`: `estado=&clienteId=C-001`, `clienteNombre=%20%20`) |

Total: **27 métodos de test nuevos, uno por CA** (19 Core + 8 Api).
`dotnet test` informará **más de 34 casos**, porque cada `[InlineData]` de un `[Theory]` cuenta por separado
(CA15, CA22 ×2, CA26 ×3, CA27 ×2); siguen siendo un test por criterio.

**Limitación aceptada por el PO:** CA20–CA27 prueban las reglas de `ValidadorFiltroPedidos` (Core) **a través del endpoint**,
como pide la spec; el validador no tiene tests propios en Core. Si uno falla, revisar tanto el validador como la lectura de la query en `Program.cs`.

**Limitación aceptada por el PO:** CA14 y CA19 se prueban en Core (como los ubica la spec). Verifican `Total` e `Items`,
pero **no el código HTTP 200** que mencionan, porque Core no conoce HTTP. El 200 solo se observa en la verificación manual.

## Riesgos y mitigación
| Riesgo | Mitigación |
|---|---|
| ASP.NET responde su propio 400 si se enlazan `int`/`DateOnly` | Leer los parámetros como texto y parsear en Core. |
| No distinguir `?estado=` (vacío) de ausente | `request.Query.TryGetValue` conserva la clave con valor vacío ⇒ error RN10 (CA27). |
| Desbordamiento: `pagina=2147483647` cabe en `int` pero `(pagina-1)*20` no | Salto en `long`; si supera el total ⇒ `items` vacío (RN8). |
| `ToLower`/`Contains` simples no encuentran `Doña` con `dona` | Normalización FormD sin marcas (CA6, CA7). |
| Cultura del equipo (es-CL) altera el parseo | `CultureInfo.InvariantCulture` y `TryParseExact("yyyy-MM-dd")`. |
| Restaurar `Microsoft.AspNetCore.Mvc.Testing` requiere NuGet | Si falla, avisar al PO y no continuar con los tests de Api. |
| Nombres JSON / `DateOnly` | .NET 10 usa camelCase y serializa `DateOnly` como `"2026-10-20"`; se revisa en la verificación manual. |

## Pasos
0. Guardar este plan como `specs/HU-01-listar-pedidos/plan.md`. **Esperar** a que el PO marque la spec como APROBADA.
1. Core: `EstadosPedido`, `FiltroPedidos`, `ResultadoValidacionFiltro`, `PaginaPedidos` (solo tipos). `dotnet build`.
2. Core tests: los 19 tests de `BuscadorPedidosTests` (CA1–CA19) → en rojo.
3. Core: implementar `BuscadorPedidos` hasta verde. `dotnet test`.
4. Core: implementar `ValidadorFiltroPedidos` (RN1, RN5, RN6, RN8–RN10).
5. Crear `tests/PedidosWeb.Api.Tests` (csproj + Mvc.Testing) y agregarlo a `PedidosWeb.sln` a mano. `dotnet sln list` debe mostrar 4 proyectos; `dotnet build`.
6. Api tests: los 8 tests de `ListarPedidosTests` (CA20–CA27) → en rojo.
7. Api: endpoint `GET /api/pedidos` + registro de `BuscadorPedidos`. `dotnet test` → todo en verde, 0 fallos.
8. Avisar al PO: tests en verde y lista de CA cumplidos (el PO marca la spec y hace el commit).

## Verificación
- `dotnet build` sin advertencias nuevas; `dotnet test` → 0 fallos, con los 7 tests previos más los 27 métodos nuevos
  (cada caso de `[Theory]` cuenta aparte en el total).
- Comprobar que cada CA1–CA27 tiene exactamente un método de test (tabla de arriba).
- Manual: `dotnet run --project src/PedidosWeb.Api` y probar
  - `/api/pedidos?clienteId=C-001&estado=Entregado` → 200, `total` 3, items 8, 24, 40.
  - `/api/pedidos?desde=2026-10-01&hasta=2026-10-31&pagina=2` → items 39, 20, 41.
  - `/api/pedidos` → 400 `application/problem+json`.
  - `/api/pedidos?clienteId=C-999` → **200**, `total` 0 (código HTTP de CA14, no cubierto por test).
  - `/api/pedidos?clienteId=C-001&pagina=99` → **200**, `total` 5, `items` vacío (código HTTP de CA19, no cubierto por test).
  - `/api/pedidos/8` sigue funcionando (sin regresión).
