# Matriz de decisión de Pedidos Legado

<!--
Etapa 3 · Decidir (modo por defecto).
1. Reparte los pesos entre los 5 criterios. Deben sumar 100 %.
2. Puntúa cada estrategia de 1 a 5 para cada módulo (5 = la mejor opción para ese criterio)
   y calcula el puntaje ponderado. Pídele a Claude que haga las cuentas, y revísalas.
3. La recomendación de cada módulo debe salir de la matriz, no de la intuición.
Punto de control E3: pesos que suman 100 %, al menos 4 módulos puntuados,
recomendación que se desprende de la matriz y resumen de 5 líneas.
-->

> **Estado: propuesta pendiente de decisión del PO.** Claude propuso los pesos y puntajes a partir de [inventario.md](inventario.md), [reglas-negocio.md](reglas-negocio.md) y [riesgos.md](riesgos.md). Los puntajes ponderados se calcularon con un script (2026-11-10), no a mano.

## Pesos

| Criterio | Qué mide | Peso | Por qué este peso |
|---|---|---|---|
| Costo | Cuánto cuesta en horas y dinero | 15 % | El sistema es pequeño (2.399 líneas) y ya existe una base en Pedidos Web; el costo no decide el proyecto. |
| Complejidad | Qué tan difícil es técnicamente | 15 % | Pesa parecido al costo; la dificultad real se concentra en Toma de pedidos y en los datos. |
| Riesgo | Qué puede salir mal en el camino | 30 % | Es el criterio más pesado porque hay 8 riesgos altos (RS-01 a RS-08) en seguridad e integridad. |
| Impacto | Cuánto valor entrega al negocio | 25 % | El objetivo es el portal Pedidos Web; un módulo que no avanza ese objetivo vale menos. |
| Personas | Conocimiento disponible en el equipo | 15 % | El equipo trabaja en .NET (todo el repo) y nadie mantiene el Delphi (el README es de 2009). Es un supuesto que hay que confirmar. |
| **Total** |  | **100 %** |  |

**Escala de 1 a 5, donde 5 es siempre lo mejor para el negocio:**
- Costo 5 = barato.
- Complejidad 5 = simple.
- Riesgo 5 = poco riesgo. Cuenta tanto lo que puede fallar durante el cambio como los riesgos de `riesgos.md` que quedan abiertos con esa estrategia; por eso «Mantener» no saca automáticamente un 5.
- Impacto 5 = mucho valor.
- Personas 5 = el equipo sabe hacerlo.

**Estrategias:**
- **Mantener**: dejarlo en Delphi tal cual.
- **Refactorizar**: corregirlo dentro de Delphi y DBISAM.
- **Modernizar**: portar las reglas verificadas a `PedidosWeb.Core` / `PedidosWeb.Api` (.NET) con un test xUnit por regla.
- **Reemplazar**: sustituirlo por una solución nueva o estándar, sin portar la lógica del legado.

## Matriz

<!-- Anota el puntaje ponderado de cada estrategia (1–5 por criterio × peso). -->

| Módulo | Mantener | Refactorizar | Modernizar | Reemplazar | Recomendación |
|---|---|---|---|---|---|
| Cálculo de totales | 2,50 | 2,90 | **4,25** | 2,95 | **Modernizar** (margen 1,30) |
| Clientes | 2,80 | 2,90 | **4,00** | 2,85 | **Modernizar** (margen 1,10) |
| Stock | 2,50 | 2,90 | **3,85** | 2,95 | **Modernizar** (margen 0,90) |
| Toma de pedidos | 2,60 | 2,70 | **3,50** | 2,50 | **Modernizar** (margen 0,80) |
| Productos | 3,40 | 2,95 | **3,75** | 3,15 | **Modernizar** (margen 0,35 ⚠) |
| Informes | 2,80 | 2,90 | 3,90 | **4,30** | **Reemplazar** (margen 0,40) |
| Acceso y datos | 2,50 | 2,60 | 3,10 | **3,35** | **Reemplazar** (margen 0,25 ⚠) |

Ponderado = Σ (puntaje × peso) / 100. ⚠ marca un margen menor a 0,40: con un cambio razonable de criterio, la decisión podría ser otra.

**Sensibilidad:** con pesos iguales (20 % cada criterio), la recomendación es **la misma en los 7 módulos**. Los márgenes más estrechos siguen siendo Productos (0,20 sobre Mantener) y Acceso y datos (0,20 sobre Modernizar).

## Detalle de puntajes y justificación

Columnas: C = Costo · X = Complejidad · R = Riesgo · I = Impacto · P = Personas.

### 1. Cálculo de totales
`UCalculoTotales.pas` y el cálculo de `UFrmPedidos.pas:284-319`. Reglas 1 a 9; riesgos RS-08 y RS-13.

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 1 | 1 | 3 | 2,50 | No cuesta nada, pero el total de pantalla sigue siendo distinto del grabado en 13 de 60 folios (RS-08), y el dinero sigue en `Double`. |
| Refactorizar | 4 | 4 | 3 | 2 | 2 | 2,90 | Unificar en `UCalculoTotales` es poco código, pero sigue en Delphi con `Double` y depende de que alguien sepa Delphi. |
| Modernizar | 3 | 4 | 4 | 5 | 5 | **4,25** | Es una unidad pura: sin formularios ni base. `CalculadoraTotales` ya existe en Core (por ahora solo el subtotal). Los 60 folios recalculados sirven de prueba de regresión, y `decimal` cierra RS-13. Costo 3 porque antes hay que fijar la regla oficial. |
| Reemplazar | 2 | 3 | 2 | 4 | 4 | 2,95 | Rediseñar desde cero cambiaría totales que los clientes ya conocen y perdería reglas verificadas (OFE, flete × 1,15, redondeo). |

### 2. Toma de pedidos
`UFrmPedidos.pas/.dfm` sin el cálculo: búsqueda, validaciones, folio y grabación. Reglas 10 a 15 y 29 a 31; riesgos RS-01, RS-04, RS-05 y RS-16.

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 1 | 2 | 2 | 2,60 | Deja abiertos tres riesgos altos (inyección, grabación sin transacción, folio MAX+1). Impacto 2 porque hoy el negocio funciona con él. |
| Refactorizar | 3 | 2 | 3 | 3 | 2 | 2,70 | Meter transacción y parámetros en un handler de 150 líneas pegado a la interfaz y sin tests es delicado. Cierra RS-01 y RS-04, pero no RS-16. |
| Modernizar | 2 | 2 | 3 | 5 | 5 | **3,50** | Es el módulo más grande y necesita base de datos y transacciones en Pedidos Web, por eso el riesgo de transición es medio. Cierra RS-01, RS-04, RS-05 y RS-16, y es el corazón del portal. |
| Reemplazar | 1 | 2 | 2 | 4 | 3 | 2,50 | Rediseñar el flujo sin las reglas del legado (mínimo, deuda, corte de las 18:00) arriesga perder reglas que el negocio usa sin tenerlas escritas. |

### 3. Stock
`UStock.pas`. Regla 16; riesgos RS-06 y RS-07.

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 1 | 1 | 3 | 2,50 | El stock ya está negativo en los datos (producto 9: −12) y `MOV_STOCK` falla sin avisar. |
| Refactorizar | 4 | 4 | 3 | 2 | 2 | 2,90 | Los arreglos son acotados: UPDATE relativo, validar antes de grabar, quitar el `except` vacío. Pero quedan en Delphi. |
| Modernizar | 3 | 3 | 4 | 4 | 5 | **3,85** | Es lógica pequeña. Depende de la transacción del pedido y de decidir qué hacer con `MOV_STOCK`. |
| Reemplazar | 2 | 2 | 3 | 4 | 3 | 2,95 | Un sistema de inventario externo es un proyecto aparte con su propia integración; excede el alcance. |

### 4. Clientes
`UFrmClientes.pas/.dfm`. Reglas 17, 18, 21 y 23 a 27; riesgos RS-09, RS-05 y RS-01.

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 2 | 1 | 3 | 2,80 | Hoy no se pueden editar 5 de los 30 clientes, porque `RutOk` tiene K y 0 invertidos. |
| Refactorizar | 4 | 4 | 3 | 2 | 2 | 2,90 | Corregir `RutOk` es un cambio de dos líneas, pero el ID con MAX+1 y el SQL concatenado siguen ahí. |
| Modernizar | 3 | 4 | 4 | 4 | 5 | **4,00** | `Cliente`, `IClienteRepositorio` y `NormalizadorRut` ya existen en Core. Faltan la validación del dígito verificador y las reglas de VIP, región y borrado. |
| Reemplazar | 2 | 3 | 3 | 3 | 3 | 2,85 | Un CRM externo es caro para un maestro de 30 clientes, y aun así habría que integrar el bloqueo por deuda. |

### 5. Productos
`UFrmProductos.pas/.dfm`. Reglas 22 y 28; riesgo RS-01 (filtro, bajo).

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 4 | 1 | 3 | 3,40 | Es un mantenedor simple y de bajo riesgo. El único problema es el filtro armado como texto. |
| Refactorizar | 4 | 4 | 4 | 1 | 2 | 2,95 | Hay poco que arreglar y aporta poco. |
| Modernizar | 3 | 4 | 4 | 3 | 5 | **3,75** | Es un CRUD sencillo. Cuando los pedidos se tomen en la web, los productos tienen que estar en la misma base. |
| Reemplazar | 3 | 3 | 3 | 3 | 4 | 3,15 | El maestro podría venir de otro sistema, pero habría que integrarlo. |

⚠ **Decisión ajustada:** si el PO prioriza el costo, mantenerlo en Delphi mientras se migra Toma de pedidos es defendible, siempre que se acepte sincronizar los productos entre las dos bases durante la transición.

### 6. Informes
`UFrmInformes.pas/.dfm`. Reglas 8 y 15; riesgos RS-10, RS-01 y RS-17.

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 2 | 1 | 3 | 2,80 | El IVA fijo y los años de 2 dígitos producen cifras erróneas sin avisar. |
| Refactorizar | 4 | 4 | 3 | 2 | 2 | 2,90 | Los arreglos son posibles, pero solo los puede usar el nivel 9 y seguiría en el escritorio. |
| Modernizar | 4 | 4 | 4 | 3 | 5 | 3,90 | Portarlo tal cual arrastra el IVA fijo y el "neto" que incluye el flete, así que aporta menos valor. |
| Reemplazar | 5 | 4 | 4 | 4 | 5 | **4,30** | La HU-01 ya lista pedidos por fecha y estado en la API. Basta con agregar totales y exportación sobre lo existente, con un neto bien calculado. |

### 7. Acceso y datos
`UFrmPrincipal.pas`, `UGlobales.pas`, `UDMPrincipal.pas/.dfm` y DBISAM. Riesgos RS-02, RS-03, RS-11, RS-14 y RS-17.

| Estrategia | C | X | R | I | P | Pond. | Por qué |
|---|---|---|---|---|---|---|---|
| Mantener | 5 | 5 | 1 | 1 | 3 | 2,50 | La contraseña en el código y el login sin clave siguen abiertos. |
| Refactorizar | 3 | 3 | 3 | 2 | 2 | 2,60 | En Delphi se puede pedir clave y sacar la contraseña del código, pero DBISAM y las globales se quedan. |
| Modernizar | 2 | 2 | 3 | 4 | 4 | 3,10 | Portar el esquema DBISAM tal cual a otro motor y las globales a configuración arrastra la falta de FK y el login por nombre. |
| Reemplazar | 2 | 2 | 3 | 5 | 4 | **3,35** | Autenticación estándar de ASP.NET más una base relacional nueva con FK y transacciones: elimina RS-02 y RS-03 en lugar de portarlos. Requiere que el PO elija el motor y apruebe los paquetes NuGet (AGENTS.md). |

⚠ **Decisión ajustada:** si se prefiere migrar primero el esquema tal cual y rediseñarlo después, Modernizar queda solo 0,25 por debajo.

## Resumen ejecutivo

<!-- Exactamente 5 líneas, para alguien que no leerá el resto. -->

1. **Qué es y su estado:** Pedidos Legado es un sistema Delphi sobre DBISAM 4.24, no Paradox como dice el README. Tiene 2.399 líneas en 17 archivos y 6 tablas, más `MOV_STOCK`, que no está en el esquema, y la lógica de negocio vive en los formularios.
2. **Hallazgo principal (con evidencia):** el total que ve el vendedor no es el que se graba. La pantalla compara el descuento con `>` (`UCalculoTotales.pas:77`) y la grabación con `>=` (`UFrmPedidos.pas:296`); 13 de 60 folios difieren, y los 60 grabados cuadran con la regla del formulario.
3. **Riesgo más urgente:** hay SQL armado concatenando texto en 7 puntos, entre ellos la grabación del pedido (`UFrmPedidos.pas:261-262`, RS-01), y el login no pide contraseña (`UFrmPrincipal.pas:46-50`, RS-03): cualquiera puede leer o alterar pedidos.
4. **Estrategia y por dónde empezar:** modernizar 5 módulos hacia `PedidosWeb.Core` y reemplazar Informes (con la HU-01) y Acceso y datos. Se empieza por Cálculo de totales, que tiene la mejor nota (4,25), es una unidad pura y tiene 60 folios como prueba de regresión.
5. **Próximo paso que se pide aprobar:** que el PO fije la regla oficial de descuento (umbral `>=` 500.000 / 1.000.000, Navidad, tope de 10 %) y apruebe la spec de la historia «Cálculo de totales» en `specs/`.
