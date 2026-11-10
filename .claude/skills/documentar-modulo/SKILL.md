---
name: documentar-modulo
description: "Documenta un módulo de PedidosWeb.Core (Pedidos, Lineas, Clientes, Folios) en docs/modulos/<Modulo>.md con propósito, API pública, ejemplo de uso y diagrama Mermaid. Úsala cuando pidan documentar, describir o explicar un módulo o una carpeta de Core, o actualizar su documentación, aunque no nombren la Skill."
---

# Documentar un módulo

Un módulo es una carpeta de `src/PedidosWeb.Core/` (por ejemplo `Pedidos/`, `Lineas/`, `Clientes/`, `Folios/`).

## Pasos
1. Identifica el módulo. Si no queda claro cuál es, pregunta antes de escribir.
2. Lee todo el código del módulo: cada `.cs` de `src/PedidosWeb.Core/<Modulo>/`, sus tests en
   `tests/PedidosWeb.Core.Tests/<Modulo>/` y dónde se usa (otras carpetas de Core y `src/PedidosWeb.Api/Program.cs`).
   Si una spec de `specs/` lo menciona, léela también.
3. Escribe `docs/modulos/<Modulo>.md` con las secciones de abajo. Si el archivo ya existe, actualízalo en vez de crear otro.
4. Revisa que cada afirmación salga del código o de un test, y que el diagrama Mermaid sea válido.
5. Al terminar, muestra la lista de tipos y métodos públicos que documentaste y avisa si quedó algo sin documentar.

## Qué debe tener docs/modulos/<Modulo>.md
- Propósito
- API pública
- Ejemplo de uso
- Diagrama Mermaid

## Reglas
- Solo se escribe `docs/modulos/<Modulo>.md`. No se modifica código, tests ni otros documentos.
- Documenta lo que el código hace hoy, no lo que debería hacer. Si algo no está en el código, no lo inventes.
- Código heredado (por ejemplo `ClientesService`): documenta los nombres tal como están, sin proponer el refactor.
- API pública: solo tipos y miembros `public`, con su firma en C# y una línea que explique qué hace.
- Ejemplo de uso: un fragmento C# corto con datos reales de los repositorios en memoria (los 45 pedidos y los 8 clientes) y el resultado esperado, tomado de un test cuando exista uno.
- Diagrama Mermaid: un `classDiagram` con los tipos del módulo y sus dependencias directas (interfaces, repositorios, otros módulos). Máximo unos 12 nodos.
- Montos en CLP (`decimal`, sin IVA) y fechas `DateOnly`, como en el código.
- Cita los archivos con su ruta relativa (`src/PedidosWeb.Core/<Modulo>/Archivo.cs`).
- Español de Chile, frases cortas.
