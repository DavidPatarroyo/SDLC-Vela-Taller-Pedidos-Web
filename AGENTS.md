# AGENTS.md

## Proyecto
Pedidos Web: portal de pedidos de una distribuidora, modernización del sistema de escritorio "Pedidos Legado" (Delphi + DBISAM).
API REST en ASP.NET Core (.NET 10, Minimal API) con 45 pedidos de ejemplo en memoria; todavía sin base de datos.

## Comandos
- Compilar: `dotnet build`
- Testear: `dotnet test`
- Ejecutar la API: `dotnet run --project src/PedidosWeb.Api` (http://localhost:5080; comprobación en `GET /salud`)

## Estilo de código
- Nombres en español: tipos, métodos, variables y tests (`Pedido`, `ObtenerPorId`, `PedidoRepositorioEnMemoria`).
- Dinero: `decimal` (CLP, sin decimales). Nunca `double` ni `float`.
- Fechas: `DateOnly` (fecha local de Chile, sin hora).
- `Nullable` e `ImplicitUsings` habilitados; los modelos son `sealed record`.
- `src/PedidosWeb.Core`: dominio (modelos, interfaces de repositorio, repositorio en memoria, lógica). No depende de ASP.NET.
- `src/PedidosWeb.Api`: `Program.cs` con endpoints Minimal API y registro de dependencias; delega la lógica en Core.

## Tests
- xUnit 2.9; tests de dominio en `tests/PedidosWeb.Core.Tests/`, con carpetas espejo de Core (`Pedidos/`, `Folios/`).
- Clase `<Clase>Tests`; método `Metodo_Escenario_Resultado` (ej. `ObtenerPorId_IdInexistente_DevuelveNull`).
- Se ejecutan con `dotnet test` después de cada cambio y siempre antes de un commit. No hay CI todavía.
- Tests de la Api (HTTP, errores, contrato) en `tests/PedidosWeb.Api.Tests/` con `WebApplicationFactory<Program>`; se crea con HU-01.

## Seguridad
- Nunca secretos, claves ni cadenas de conexión en el código ni en el repo (`.env` y `*.pem` ya están en `.gitignore`).

## Reglas de trabajo
- Toda funcionalidad parte de una spec aprobada en `specs/<historia>/spec.md`.
- Un test xUnit por criterio de aceptación.
- No hacer commit sin tests en verde.
- Sin preguntar, el agente puede: leer archivos, compilar, ejecutar tests y editar código y tests en `src/` y `tests/`.
- Cualquier otra acción (por ejemplo agregar paquetes NuGet) requiere aprobación del PO.
- El agente no ejecuta comandos de git (commit, push, ramas): los hace el PO.
