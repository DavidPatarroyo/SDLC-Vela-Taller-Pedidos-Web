# Inventario de Pedidos Legado

<!--
Etapa 1 · Entender (plan mode).
Una fila por cada archivo de legado/src/ (.pas y .dfm). Puedes agregar legado/PedidosLegado.dpr al final.
- Tipo: Formulario, Data module, Unidad de lógica, Utilidades, Globales…
- Responsabilidad: qué hace, en una frase y con tus palabras.
- Líneas: pídele a Claude que las cuente con una herramienta; no las estimes a ojo.
Punto de control E1: están todos los archivos de legado/src/.
-->

Líneas contadas con `wc -l`. Fuente de las responsabilidades: lectura del código con el subagente `analista-legado` y revisión manual de los puntos citados.

| Archivo | Tipo | Responsabilidad | Líneas |
|---|---|---|---|
| `src/UDMPrincipal.pas` | Data module | Conecta a DBISAM con una contraseña escrita en el código, abre 5 tablas y ofrece `LeerParametro` y `EjecutarSQL`, que ejecuta SQL armado como texto. | 100 |
| `src/UDMPrincipal.dfm` | Definición visual (.dfm) | Declara la conexión `dbPedidos` (DBISAM 4.24, `C:\PEDIDOS\DATOS`), 5 tablas (CLIENTES, PRODUCTOS, PEDIDOS, PEDIDO_LINEAS, PARAMETROS) y 2 queries auxiliares. | 65 |
| `src/UGlobales.pas` | Globales | Guarda el estado de sesión en variables globales que cualquiera puede modificar: usuario, nivel, tasa de IVA, ruta de datos y banderas. | 41 |
| `src/UUtilidades.pas` | Utilidades | Redondeo y formato de pesos, validación de RUT por módulo 11, conversión de fechas y corte horario de las 18:00, que pasa el pedido al día hábil siguiente. | 189 |
| `src/UCalculoTotales.pas` | Unidad de lógica (pura) | Calcula en memoria el subtotal, el descuento (volumen + VIP, tope 10 %, sin la categoría OFE), el flete por región, el IVA y el total. Solo se usa para mostrar los totales en pantalla. | 147 |
| `src/UStock.pas` | Unidad de lógica (con datos y mensajes) | Consulta y descuenta stock por producto y por pedido; permite que un cliente VIP deje el stock en -20. Registra el movimiento en `MOV_STOCK` y descarta los errores. | 93 |
| `src/UFrmPrincipal.pas` | Formulario | Pide el usuario y le asigna nivel, inicializa las globales, conecta la base, carga TASA_IVA e IMPRESORA y abre las pantallas del menú (Informes requiere nivel 2 o más). | 104 |
| `src/UFrmPrincipal.dfm` | Definición visual (.dfm) | Ventana principal con el menú Archivo / Maestros / Ventas y una barra de estado; no tiene componentes de datos. | 62 |
| `src/UFrmClientes.pas` | Formulario | Mantenedor de clientes con validaciones (RUT, tipo N/V, VIP solo para jefatura, región entre 1 y 16). Asigna el ID con MAX+1 e impide borrar clientes que tienen pedidos. | 215 |
| `src/UFrmClientes.dfm` | Definición visual (.dfm) | Pantalla de clientes con su propia tabla `tblCli` sobre CLIENTES y campos enlazados a RUT, razón social, tipo, región, dirección y teléfono. | 213 |
| `src/UFrmProductos.pas` | Formulario | Mantenedor de productos con filtro por descripción o stock bajo el mínimo. Convierte los textos a mayúsculas al grabar y solo deja borrar al nivel 9. | 105 |
| `src/UFrmProductos.dfm` | Definición visual (.dfm) | Grilla y navegador sobre su propia tabla `tblProd` (PRODUCTOS). | 98 |
| `src/UFrmPedidos.pas` | Formulario (concentra la lógica de negocio) | Toma de pedidos completa: bloqueo por deuda vencida, líneas, totales, validaciones (máximo 40 líneas, mínimo $30.000 fuera de la región 13), folio con MAX+1, INSERT, recálculo del total con SQL y descuento de stock. | 420 |
| `src/UFrmPedidos.dfm` | Definición visual (.dfm) | Pantalla de toma de pedidos con grilla de líneas, observación y botones. **No tiene componentes de datos**: todo el acceso a la base se hace desde código. | 226 |
| `src/UFrmInformes.pas` | Formulario | Informe de pedidos por rango de fechas, cliente y estado. Calcula el neto con IVA fijo de 0,19 y exporta a CSV en la carpeta de datos. | 137 |
| `src/UFrmInformes.dfm` | Definición visual (.dfm) | Filtros del informe más la query `qryInforme`, cuyo SQL se arma desde el `.pas`. | 160 |
| `PedidosLegado.dpr` | Programa | Registra las 10 unidades, crea DMPrincipal y FrmPrincipal y arranca la aplicación. | 24 |
| **Total** (16 archivos de `src/` + `.dpr`) | | | **2.399** |

## Tablas de la base (DBISAM 4.24)

Esquema en `legado/db/esquema-dbisam.sql` (74 líneas). Las filas son las del CSV de `legado/db/datos/`, sin contar el encabezado. L = lectura, E = escritura.

| Tabla | Responsabilidad | PK / índices (esquema:línea) | Filas CSV | Usada por (archivo:línea) |
|---|---|---|---|---|
| REGIONES | Catálogo de regiones con su flete base. | PK `CODIGO` :9 | 16 | L `UFrmPedidos.pas:101` (JOIN con CLIENTES). Es el único acceso; el DataModule no la carga. |
| CLIENTES | Maestro de clientes: RUT, tipo N/V, región, deuda vencida y estado activo. | PK `ID_CLIENTE` :24 · `IDX_CLIENTES_RUT` :27 | 30 | L/E `UFrmClientes.dfm:204` y `UFrmClientes.pas:76,93,100,113,160` · L `UFrmPedidos.pas:101` · L `UFrmInformes.pas:66` · se abre en `UDMPrincipal.pas:62` |
| PRODUCTOS | Maestro de productos: código, categoría, precio, stock y stock mínimo. | PK `ID_PRODUCTO` :38 · `IDX_PRODUCTOS_CODIGO` :41 | 40 | L/E `UFrmProductos.dfm:89` · L `UFrmPedidos.pas:152,285` · L/E `UStock.pas:23,51` · se abre en `UDMPrincipal.pas:63` |
| PEDIDOS | Cabecera del pedido: folio, fecha, cliente, usuario, estado y total. | PK `FOLIO` :52 · `IDX_PEDIDOS_CLIENTE` :55 · `IDX_PEDIDOS_FECHA` :56 | 60 | L/E `UFrmPedidos.pas:249,259,320,338` · L `UFrmClientes.pas:207` · L `UFrmInformes.pas:66` · se abre en `UDMPrincipal.pas:64` |
| PEDIDO_LINEAS | Detalle del pedido: producto, cantidad y precio unitario por línea. | PK (`FOLIO`, `LINEA`) :65 | 169 | L/E `UFrmPedidos.pas:268,280,285` · L `UStock.pas:64` · se abre en `UDMPrincipal.pas:65` |
| PARAMETROS | Configuración en pares clave-valor (TASA_IVA, IMPRESORA, PEDIDO_MINIMO, etc.). | PK `CLAVE` :73 | 6 | L `UDMPrincipal.pas:85` (`LeerParametro`), llamada desde `UFrmPrincipal.pas:62,65` · se abre en `UDMPrincipal.pas:66` |
| MOV_STOCK ⚠ | Registro de movimientos de stock. **No está en el esquema ni tiene CSV.** | — | — | E `UStock.pas:85` (el error se descarta en `:89-90`) |

No hay FK declaradas. Las relaciones son implícitas:
- `CLIENTES.REGION` → `REGIONES.CODIGO`
- `PEDIDOS.ID_CLIENTE` → `CLIENTES.ID_CLIENTE`
- `PEDIDO_LINEAS.FOLIO` → `PEDIDOS.FOLIO`
- `PEDIDO_LINEAS.ID_PRODUCTO` → `PRODUCTOS.ID_PRODUCTO`

## Lo que me llamó la atención

<!-- 2 o 3 observaciones rápidas (por ejemplo, algo que no calza con legado/README.md). -->

- **El README no describe el sistema actual.**
  - `legado/README.md:6-7` dice que la base es Paradox vía BDE y que los informes usan Crystal Reports 8.
  - El código usa DBISAM 4.24 (`UDMPrincipal.dfm:10`, `EngineVersion = '4.24 Build 1'`; `UDMPrincipal.pas:58`, `// antes era alias BDE PEDIDOS`).
  - No encontré Crystal Reports: el "informe" es una grilla con exportación a CSV (`UFrmInformes.pas:101-125`).
- **El cálculo de descuento está duplicado y las dos versiones no coinciden.**
  - `UCalculoTotales.pas:77` usa `>` y `UFrmPedidos.pas:296` usa `>=`.
  - Solo `UFrmPedidos.pas:304` suma un 2 % por Navidad.
  - El comentario de `UCalculoTotales.pas:4` habla de "5 % sobre 400.000", pero el código usa 500.000 (`:79`).
  - Lo que se graba en la base es lo que calcula el formulario, no la unidad de cálculo.
- **La base real no coincide con el esquema.**
  - `UStock.pas:85` escribe en `MOV_STOCK`, una tabla que no aparece en `esquema-dbisam.sql`.
  - REGIONES solo se lee en `UFrmPedidos.pas:101`, y el DataModule no la carga.
  - El DataModule abre 5 tablas (`UDMPrincipal.pas:62-66`) que ninguna otra unidad usa: los formularios abren sus propias tablas o queries.
