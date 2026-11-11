# Riesgos de Pedidos Legado

<!--
Etapa 2 · Encontrar.
Un riesgo es algo que puede salir mal en producción o al migrar.
- Evidencia: archivo:línea. Sin evidencia, es una sospecha, no un riesgo.
- Categoría: Seguridad · Datos e integridad · Fechas · Mantenibilidad.
- Prioridad: Alta · Media · Baja (¿qué tan grave es y qué tan probable?).
Punto de control E2: al menos 5 riesgos con evidencia y prioridad.
-->

Rutas relativas a `legado/src/` salvo que se indique otra cosa. Toda la evidencia la leí en el código el 2026-11-10. Lo que depende de producción o del comportamiento en ejecución va marcado **por verificar**.

| ID | Riesgo | Evidencia (archivo:línea) | Categoría | Prioridad |
|---|---|---|---|---|
| RS-01 | **SQL armado concatenando texto escrito por el usuario.** Permite inyectar SQL, y un simple apóstrofo (por ejemplo "O'Higgins" en la observación) ya rompe la grabación. `EscapaComillas` existe (`UUtilidades.pas:164`) pero nadie la llama. `ValidaRut` no protege: un texto sin dígitos que termine en `0` pasa la validación | `UFrmPedidos.pas:102` (RUT), `:152` (código de producto), `:261-262` (usuario y observación); `UFrmClientes.pas:76-77` (razón social); `UFrmInformes.pas:69` (cliente); `UStock.pas:87` (usuario); `UFrmProductos.pas:61` (filtro) | Seguridad | Alta: hay 7 puntos con texto libre y uno de ellos está en la grabación del pedido |
| RS-02 | **Contraseña de la base escrita en el código** (no se repite aquí). Queda en el binario y en el repositorio, y es la misma para todas las instalaciones | `UDMPrincipal.pas:41`, `:59` | Seguridad | Alta: cualquiera con el código o el `.exe` abre la base |
| RS-03 | **Login sin contraseña.** El nivel se decide por el nombre escrito: escribir `ADMIN` o `JEFEVENTAS` da nivel 9 (informes, VIP y borrado de productos) | `UFrmPrincipal.pas:46-50` | Seguridad | Alta: cualquier usuario puede subir de nivel |
| RS-04 | **Grabación del pedido sin transacción**: cabecera con TOTAL 0, líneas, UPDATE del total y stock, cada uno por separado. Un fallo intermedio deja un pedido a medias con total 0 o sin líneas | `UFrmPedidos.pas:255` (`// TODO transaccion`), `:263`, `:272`, `:320`, `:324`; no hay `StartTransaction` en `legado/src` | Datos e integridad | Alta: cualquier error de red o de disco deja datos inconsistentes |
| RS-05 | **Folio e ID de cliente con `MAX + 1`, sin bloqueo.** Con dos puestos grabando a la vez sale la misma llave: violación de PK o pedido perdido | `UFrmPedidos.pas:249-251`; `UFrmClientes.pas:160-163` | Datos e integridad | Alta si hay más de un puesto; en un solo puesto es media (por verificar cuántos puestos hay) |
| RS-06 | **Stock descontado después de grabar y escrito como valor absoluto** (`SET STOCK = n`, calculado en el PC). Se pierden actualizaciones concurrentes, y si no hay stock el pedido igual queda grabado con solo un mensaje. Los VIP pueden dejar el stock en −20. El CSV ya tiene stock negativo (producto 9: −12) | `UStock.pas:38-53`, `:69-72`; `UFrmPedidos.pas:324`; `legado/db/datos/PRODUCTOS.csv:10` | Datos e integridad | Alta: hoy ya hay inventario negativo |
| RS-07 | **Errores silenciados al registrar movimientos de stock** en `MOV_STOCK`, una tabla que **no está en el esquema**. Si no existe, el historial se pierde sin que nadie se entere | `UStock.pas:84-90` (`except` vacío en `:89`); ausente en `legado/db/esquema-dbisam.sql` | Datos e integridad | Alta (por verificar si `MOV_STOCK` existe en producción) |
| RS-08 | **La regla de descuento está duplicada y diverge.** La pantalla usa `>` y la grabación usa `>=` (además de Navidad). El vendedor ve un total distinto del grabado en 13 de 60 folios (1008, 1011, 1019, 1023, 1026, 1032, 1035, 1039, 1042, 1048, 1050, 1055 y 1060), y el aviso de diferencia está desactivado | `UCalculoTotales.pas:77-82` frente a `UFrmPedidos.pas:296-305`; aviso apagado en `UFrmPedidos.pas:330` y `UGlobales.pas:34` | Mantenibilidad | Alta: el cliente recibe un total distinto del cotizado, y al migrar es fácil copiar la versión equivocada |
| RS-09 | **Validación de RUT duplicada y contradictoria.** `RutOk` invierte K y 0, y `ValidaRut` rechaza la `k` minúscula. Hoy no se pueden editar los clientes 7, 11, 17, 18 y 23, y el cliente 18 (`76500019-k`) tampoco se puede buscar en Pedidos | `UFrmClientes.pas:193-196` frente a `UUtilidades.pas:73-76` y `:79`; `legado/db/datos/CLIENTES.csv:8,12,18,19,24` | Datos e integridad | Media: afecta a 5 de 30 clientes; hay un rodeo, pero el error es silencioso |
| RS-10 | **Años de 2 dígitos con pivote 50.** Si se escribe "01/01/2025", `Copy(7,2)` toma "20" y la fecha queda en 2020; un texto inválido lanza una excepción. Las fechas se muestran como `dd/mm/yy` | `UUtilidades.pas:102-106`, `:112`; `UFrmInformes.pas:63-64`, `:119` | Fechas | Media: el informe da resultados erróneos sin avisar |
| RS-11 | **Fecha y hora del PC sin zona horaria ni feriados.** El corte de las 18:00 y el bloqueo por deuda dependen del reloj local. Al migrar a un servidor en UTC, el corte se movería 3 o 4 horas | `UFrmPedidos.pas:112`, `:240`; `UUtilidades.pas:124`, `:133`; `UStock.pas:88` | Fechas | Media: es crítico al migrar, aunque en el escritorio funciona |
| RS-12 | **Bloqueo por deuda con `DaysBetween`**, que devuelve la diferencia absoluta. Un vencimiento a más de 60 días **en el futuro** también bloquearía al cliente, y falta ver qué pasa con una fecha nula | `UFrmPedidos.pas:111-112` | Fechas | Media (por verificar en ejecución) |
| RS-13 | **Dinero en `Double`.** `FloatToStr` dentro del SQL depende del separador decimal de Windows, y `StrToFloat` del parámetro `TASA_IVA` también. El redondeo `Trunc(x + 0,49)` hace que una fracción de ,5 baje | `UCalculoTotales.pas:10-26`, `:48-51`; `UUtilidades.pas:28-31`; `UFrmPedidos.pas:271`, `:320`; `UFrmPrincipal.pas:64` | Datos e integridad | Media: una configuración regional distinta puede romper el INSERT o el UPDATE |
| RS-14 | **Valores escritos en el código y parámetros ignorados.** Pedido mínimo de 30.000 frente al parámetro de 25.000, IVA de 0,19 en el informe, regiones 1–16, stock mínimo 10. `PEDIDO_MINIMO`, `DESC_NAVIDAD` y `EMPRESA` no se leen | `UFrmPedidos.pas:231`; `UFrmInformes.pas:92`; `UFrmClientes.pas:148-149`; `UFrmProductos.pas:102`; `legado/db/datos/PARAMETROS.csv:3,6,7` | Mantenibilidad | Media: cambiar la tabla de parámetros no tiene efecto y engaña a quien la mantiene |
| RS-15 | **Datos que el código no explica.** Hay estado `'A'` en los folios 1018 y 1042, aunque el código solo graba `'C'`; esos pedidos no salen en el informe por defecto. Además, el cliente 30 está inactivo y tiene el folio 1020 | `legado/db/datos/PEDIDOS.csv:19,43,21`; `CLIENTES.csv:31`; `UFrmPedidos.pas:262`; `UFrmInformes.pas:71` | Datos e integridad | Media: hay otro proceso que escribe en la base y que no está en este código (por verificar) |
| RS-16 | **Lógica de negocio dentro de los formularios.** El cálculo que se graba, el folio, las validaciones y el bloqueo por deuda viven en los handlers de `TFrmPedidos`, sin pruebas posibles fuera de la interfaz | `UFrmPedidos.pas:195-347` (`btnGrabarClick`), `:86-131` | Mantenibilidad | Media: obliga a reescribir en lugar de portar, y aumenta el riesgo de perder reglas |
| RS-17 | **Ruta de datos fija.** El informe exportado se guarda en la carpeta de la base y sobrescribe el del mismo día | `UGlobales.pas:36`; `UDMPrincipal.dfm:12`; `UFrmInformes.pas:111` | Mantenibilidad | Baja |
| RS-18 | **La documentación no coincide con el código.** El README habla de Paradox/BDE y Crystal Reports, pero el código usa DBISAM 4.24 y no hay informes de Crystal | `legado/README.md:6-7`; `UDMPrincipal.dfm:10`; `UDMPrincipal.pas:58` | Mantenibilidad | Baja: confunde, pero no rompe nada |

## Los 5 más urgentes

1. **RS-01** (SQL inyectable) y **RS-03** (login sin contraseña): cualquier usuario puede leer o modificar todo.
2. **RS-04** y **RS-05** (grabación sin transacción y folio con MAX+1): son la principal fuente de pedidos corruptos o duplicados.
3. **RS-08** (descuento duplicado): hay que decidir cuál es la regla oficial antes de migrar el cálculo a `PedidosWeb.Core`.

## Por verificar con el PO o en producción

- ¿Existe `MOV_STOCK` y tiene datos? (RS-07)
- ¿Cuántos puestos graban pedidos a la vez? (RS-05)
- ¿Quién escribe el estado `'A'`? (RS-15)
- ¿Qué devuelve el bloqueo por deuda con un vencimiento futuro o nulo? (RS-12)
