# Pedidos Web

Portal web de pedidos de la distribuidora. Es la modernización de **Pedidos Legado**, un sistema de escritorio hecho en Delphi con DBISAM que la empresa usa hace 18 años.

Este repositorio es el **caso hilo** del curso *Desarrollando con IA* (Vela LATAM). Crece unidad a unidad: hoy tiene la biblioteca de dominio (Unidad 1) y una API en ASP.NET Core con 45 pedidos de ejemplo en memoria (Unidad 2); después se suman el módulo de totales migrado, PostgreSQL y el pipeline de CI.

> Todo el contenido es ficticio y tiene fines educativos.

## Stack

| Pieza | Versión | Para qué |
|---|---|---|
| .NET SDK | 10 | Compilar y ejecutar |
| C# | el que trae el SDK | Lenguaje del proyecto |
| xUnit | 2.9 | Tests |
| JetBrains Rider | la versión vigente del All Products Pack | IDE del curso |
| Claude Code | 2.1.277 o superior | Agente de código (lee `AGENTS.md`) |

## Estructura

```
pedidos-web/
├── AGENTS.md                         ← U2: vacío a propósito; lo escribes en el paso 1 del taller
├── PedidosWeb.sln
├── src/
│   ├── PedidosWeb.Core/              ← lógica de dominio
│   │   ├── Folios/FolioFormatter.cs  ← U1: aquí implementas FormatearFolio()
│   │   └── Pedidos/                  ← U2: modelo Pedido y repositorio en memoria
│   └── PedidosWeb.Api/               ← U2: API REST (Minimal API)
│       └── Program.cs
├── tests/
│   └── PedidosWeb.Core.Tests/        ← tests xUnit
│       ├── Folios/FolioFormatterTests.cs
│       └── Pedidos/PedidoRepositorioEnMemoriaTests.cs
├── docs/                             ← U1: aquí va tu mapa-sdlc.md
└── specs/                            ← U2: aquí van las specs de cada historia
```

## Cómo empezar

Elige **un** camino. El A es el normal.

### A. Ya tienes tu repo `pedidos-web` de la Unidad 1 (lo normal)

No copies la carpeta completa: pisarías tu `FolioFormatter.cs` y tu `docs/mapa-sdlc.md`. Copia **solo lo nuevo de la Unidad 2**. Trabaja en la carpeta que contiene tu `pedidos-web` y el material del curso, uno al lado del otro.

```bash
# macOS, Linux o WSL
cd material-curso-ia-desarrolladores && git pull && cd ..
U2=material-curso-ia-desarrolladores/unidad-2/taller/pedidos-web
cp -r $U2/src/PedidosWeb.Api pedidos-web/src/
cp -r $U2/src/PedidosWeb.Core/Pedidos pedidos-web/src/PedidosWeb.Core/
cp -r $U2/tests/PedidosWeb.Core.Tests/Pedidos pedidos-web/tests/PedidosWeb.Core.Tests/
cp -r $U2/specs pedidos-web/
cp $U2/PedidosWeb.sln $U2/AGENTS.md $U2/README.md pedidos-web/
```

```powershell
# Windows PowerShell
cd material-curso-ia-desarrolladores; git pull; cd ..
$U2 = "material-curso-ia-desarrolladores/unidad-2/taller/pedidos-web"
Copy-Item -Recurse "$U2/src/PedidosWeb.Api" pedidos-web/src/
Copy-Item -Recurse "$U2/src/PedidosWeb.Core/Pedidos" pedidos-web/src/PedidosWeb.Core/
Copy-Item -Recurse "$U2/tests/PedidosWeb.Core.Tests/Pedidos" pedidos-web/tests/PedidosWeb.Core.Tests/
Copy-Item -Recurse "$U2/specs" pedidos-web/
Copy-Item "$U2/PedidosWeb.sln", "$U2/AGENTS.md", "$U2/README.md" pedidos-web/
```

`PedidosWeb.sln` se reemplaza porque ahora incluye el proyecto `PedidosWeb.Api`. `AGENTS.md` se reemplaza por uno **vacío a propósito**: en el paso 1 del taller escribes el tuyo con el prompt maestro. Las reglas de la Unidad 1 siguen en tu historial de Git (`git log -p -- AGENTS.md`), por si quieres rescatar alguna.

Guarda el punto de partida con un commit:

```bash
cd pedidos-web
git add .
git commit -m "chore: base de la Unidad 2 (API y pedidos de ejemplo)"
git push
```

### B. No tienes el repo de la Unidad 1

Sigue el paso 1 del README de `unidad-1/taller/pedidos-web` (crear tu repo en GitHub), pero copia esta carpeta (`unidad-2/taller/pedidos-web`) en vez de la de la Unidad 1.

### Compila, prueba y levanta la API

1. Abre **tu** carpeta `pedidos-web` en Rider: **File → Open** y elige `PedidosWeb.sln`.
2. Compila y ejecuta los tests desde la terminal integrada de Rider:

   ```bash
   dotnet build
   dotnet test
   ```

3. **Resultado esperado:** compila y los 4 tests de `PedidoRepositorioEnMemoriaTests` pasan. Los 3 de `FolioFormatterTests` pasan si vienes del camino A con `FormatearFolio()` implementada, y fallan con `NotImplementedException` si vienes del camino B (es normal: esa función es del taller de la Unidad 1).
4. Levanta la API:

   ```bash
   dotnet run --project src/PedidosWeb.Api
   ```

   Abre `http://localhost:5080/salud` (responde `{"estado":"ok"}`) y `http://localhost:5080/api/pedidos/8` (detalle de un pedido). Detén la API con `Ctrl+C`.

---

## La función del taller: `FormatearFolio()`

### Para qué sirve

Cada pedido tiene un **folio**: el código que aparece en la factura, en el correo al cliente y en las búsquedas del portal. El sistema legado lo arma con el código de la sucursal y el número correlativo del pedido. El portal nuevo tiene que generarlo **exactamente igual**, o los clientes no van a encontrar sus pedidos antiguos.

### Firma

Archivo: `src/PedidosWeb.Core/Folios/FolioFormatter.cs`

```csharp
public static string FormatearFolio(int numero, string sucursal)
```

### Formato de salida

```
PED-{SUCURSAL}-{NUMERO}
```

- `PED` es un prefijo fijo.
- `{SUCURSAL}` es el código de la sucursal en mayúsculas.
- `{NUMERO}` es el número del pedido con ceros a la izquierda hasta completar 6 dígitos.

### Reglas

| # | Regla |
|---|---|
| R1 | `numero` debe estar entre **1 y 999999** (ambos incluidos). Si no, lanza `ArgumentOutOfRangeException`. |
| R2 | A `sucursal` se le quitan los espacios del inicio y del final, y se pasa a **mayúsculas**. |
| R3 | Después de R2, `sucursal` debe tener **entre 2 y 4 letras de la A a la Z**. Sin `Ñ`, sin tildes, sin números ni espacios internos: el legado guarda el código en un campo ASCII de 4 caracteres. Si no se cumple, o si `sucursal` es `null` o vacía, lanza `ArgumentException` (vale una derivada, como `ArgumentNullException`). |
| R4 | `numero` se completa con ceros a la izquierda hasta 6 dígitos. |
| R5 | Si `numero` y `sucursal` son inválidos a la vez, se valida primero `numero` (R1). |

### Ejemplos

| `numero` | `sucursal` | Resultado |
|---|---|---|
| `123` | `"STGO"` | `"PED-STGO-000123"` |
| `1` | `"VAL"` | `"PED-VAL-000001"` |
| `999999` | `"CO"` | `"PED-CO-999999"` |
| `45` | `" stgo "` | `"PED-STGO-000045"` |
| `0` | `"STGO"` | `ArgumentOutOfRangeException` |
| `1000000` | `"STGO"` | `ArgumentOutOfRangeException` |
| `-5` | `"VAL"` | `ArgumentOutOfRangeException` |
| `7` | `""`, `"   "` o `null` | `ArgumentException` |
| `7` | `"S"` | `ArgumentException` (1 letra) |
| `7` | `"SANTI"` | `ArgumentException` (5 letras) |
| `7` | `"ÑUÑO"` | `ArgumentException` (la `Ñ` no es A–Z) |
| `7` | `"ST1"` | `ArgumentException` (tiene un número) |
| `0` | `"S"` | `ArgumentOutOfRangeException` (R5) |

### Lo que ya está y lo que falta

- `FolioFormatterTests.cs` trae **3 tests** con los casos base (las tres primeras filas de la tabla).
- **Los demás casos no tienen test.** Si tu implementación, o la de Claude, olvida una regla, los tests no te van a avisar. Escribe tú los tests que faltan.

---

## Taller de la Unidad 1: lo que haces en este repo

| Paso | Qué haces aquí |
|---|---|
| 1 | Abres `claude` en la terminal integrada de Rider, dentro de esta carpeta, y le preguntas: *«¿Cuáles son las reglas de este proyecto?»*. Debe citar `AGENTS.md`. |
| 3 | Implementas `FormatearFolio()` dos veces: **ronda A sin IA** y **ronda B con Claude Code**. Anotas tiempo, errores y qué corregiste. Entre una ronda y otra puedes volver al estado inicial con `git stash` o `git checkout -- src`. |
| 4 | Creas `docs/mapa-sdlc.md` con la plantilla de la guía. |
| 5 | Haces commit: `git add docs/mapa-sdlc.md` y `git commit -m "docs: mapa de uso de IA en el SDLC (U1)"`. |

## Licencias

- Claude Team Standard (Claude Code se autentica con la cuenta Team).
- JetBrains All Products Pack (Rider).

---

## Taller de la Unidad 2: los pedidos

### Qué hay hoy

- **Modelo** `Pedido` (`src/PedidosWeb.Core/Pedidos/Pedido.cs`): `Id`, `Folio`, `ClienteId`, `ClienteNombre`, `Fecha` (`DateOnly`), `Estado` (texto), `Total` (CLP, `decimal` sin decimales, nunca `double` ni `float`) y `Sucursal`.
- **Repositorio en memoria** con **45 pedidos de ejemplo** entre el 2 de septiembre y el 31 de octubre de 2026. Todos son ficticios.
- **Endpoints:** `GET /salud` y `GET /api/pedidos/{id}`.
- **Todavía no existe** el listado con filtros: es la historia **HU-01** que construyes en el taller.
- **`AGENTS.md` está vacío a propósito.** Lo escribes tú en el paso 1, con el prompt maestro y la guía de [agents.md](https://agents.md/).

### Los datos de ejemplo, en números

| Cliente | Pedidos |
|---|---|
| C-001 · Ferretería El Clavo | 5 |
| C-002 · Minimarket Doña Rosa | 6 |
| C-003 · Botillería Los Andes | 6 |
| C-004 · Almacén La Esquina | 5 |
| C-005 · Panadería San Camilo | 6 |
| C-006 · Supermercado del Valle | 6 |
| C-007 · Kiosco Central | 5 |
| C-008 · Distribuidora Norte | 6 |

| Estado (texto en los datos) | Pedidos |
|---|---|
| Pendiente | 5 |
| Confirmado | 10 |
| Despachado | 10 |
| Entregado | 15 |
| Anulado | 5 |

Hay 22 pedidos en septiembre y 23 en octubre.

### La historia del Product Owner

> «Como vendedor, quiero listar pedidos filtrando por cliente, estado y rango de fechas.»

La historia es vaga a propósito: no dice qué estados son válidos para filtrar, qué pasa con fechas invertidas, cuántos resultados se devuelven ni cómo se informa un error. **Esas decisiones las tomas tú en `specs/HU-01-listar-pedidos/spec.md`** (paso 2 del taller). Que los datos tengan cinco estados no significa que tu API deba aceptar cualquier texto como filtro.
