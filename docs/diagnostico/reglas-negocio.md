# Reglas de negocio de Pedidos Legado

<!--
Etapa 2 · Encontrar (modo por defecto + subagente analista-legado).
Una regla es una decisión del negocio escondida en el código: un monto, un porcentaje, una condición, un tope.
- Archivo:línea: dónde está. Sin esta evidencia, la regla no cuenta.
- Condición: cuándo se aplica. Efecto: qué cambia.
- Verificada: «Sí» solo si TÚ abriste el archivo en esa línea y leíste el código.
  Si la regla aparece en más de un lugar, anota todos.
Punto de control E2: al menos 8 reglas, y al menos 5 verificadas leyendo el código.
-->

Rutas relativas a `legado/src/`. Las reglas describen lo que **ejecuta el código**, no lo que dicen los comentarios.
- **Sí**: abrí el archivo en esa línea y leí el código (2026-11-10). Las reglas de cálculo 1 a 9 se contrastaron además con los 60 folios de `PEDIDOS.csv`: **los 60 totales grabados cuadran con estas reglas**.
- **Por verificar**: el código está leído, pero el comportamiento depende de algo que no se puede confirmar leyendo (la función de la RTL, los datos de producción o el uso de la pantalla).

| # | Regla | Archivo:línea | Condición | Efecto | Verificada |
|---|---|---|---|---|---|
| 1 | Descuento por volumen | `UFrmPedidos.pas:296-301` (al grabar). **Difiere de** `UCalculoTotales.pas:77-82` (en pantalla), que usa `>` | Base de descuento `>= 1.000.000` o `>= 500.000` | 8 % o 5 % sobre la base de descuento. En pantalla, una base exacta de 500.000 o 1.000.000 no tiene descuento, y por eso 13 de los 60 folios muestran un total distinto del grabado | Sí |
| 2 | Recargo de descuento VIP | `UFrmPedidos.pas:302-303` y `UCalculoTotales.pas:88-89` (coinciden). VIP = `TIPO = 'V'` en `UFrmPedidos.pas:119` | Cliente con TIPO exactamente `'V'` | Suma 3 puntos al porcentaje de volumen | Sí |
| 3 | Tope del descuento | `UFrmPedidos.pas:306-307` y `UCalculoTotales.pas:90-91` (coinciden) | Porcentaje acumulado `> 10 %` (después de volumen, VIP y Navidad) | Se fija en 10 % | Sí |
| 4 | Categoría OFE fuera de la base de descuento | `UFrmPedidos.pas:284-287` (SQL `CATEGORIA <> 'OFE'`) y `UCalculoTotales.pas:70` | Línea de un producto de categoría OFE | No suma a la base del descuento, pero sí al bruto: el descuento se resta del bruto completo (`UFrmPedidos.pas:309`) | Sí |
| 5 | Descuento de Navidad | `UFrmPedidos.pas:304-305`. Solo existe al grabar. Bandera fija en `UGlobales.pas:33` | `gDescNavidad` y mes de la fecha del pedido = 12. La fecha es la ya corrida por la regla 13 | Suma 2 puntos. **En la práctica nunca se aplica**: `gDescNavidad` siempre es `False` y nadie lee el parámetro `DESC_NAVIDAD` | Sí |
| 6 | Flete por región | `UFrmPedidos.pas:312-315` y `UCalculoTotales.pas:97-100` (coinciden). Base desde `REGIONES.FLETE_BASE` en `UFrmPedidos.pas:100,121` | Región del cliente 11 o 12 | Flete = `FLETE_BASE × 1,15`; en las demás regiones, `FLETE_BASE`. En pantalla el flete es 0 si no hay líneas (`UCalculoTotales.pas:116-117`) | Sí |
| 7 | IVA sobre neto + flete | `UFrmPedidos.pas:318-319` y `UCalculoTotales.pas:120-121`. Tasa en `UFrmPrincipal.pas:62-64` (por defecto `UGlobales.pas:31`) | Siempre | IVA = (neto + flete) × `TASA_IVA/100`, es decir, **el flete también paga IVA**. `PEDIDOS.TOTAL` guarda neto + flete + IVA | Sí |
| 8 | IVA fijo en el informe | `UFrmInformes.pas:92` | Al generar el informe de ventas | Neto = total ÷ 1,19, sin usar `TASA_IVA`. Ese "neto" incluye el flete | Sí |
| 9 | Redondeo al peso | `UUtilidades.pas:28-31` (`RedondeaPesos`) y `UCalculoTotales.pas:48-51` (`Calc3`), idénticas | Al calcular descuento, flete e IVA | `Trunc(x + 0,49)`: una fracción de ,5 baja (36.964,5 → 36.964) | Sí |
| 10 | Pedido mínimo | `UFrmPedidos.pas:231` | Bruto `< 30.000` y región `<> 13` | No deja grabar. Santiago (región 13) queda exento. El parámetro `PEDIDO_MINIMO = 25000` (`PARAMETROS.csv:3`) **no se lee** | Sí |
| 11 | Máximo de líneas | `UFrmPedidos.pas:214` | Más de 40 líneas (`> 40`) al grabar | No deja grabar. El botón Agregar no tiene límite | Sí |
| 12 | Bloqueo por deuda vencida | `UFrmPedidos.pas:111-112` | `SALDO_VENCIDO > 0` y `DaysBetween(hoy, FECHA_VENCIMIENTO) > 60` | No deja tomar pedidos para el cliente ("hablar con cobranza") | Por verificar: `DaysBetween` da la diferencia absoluta, así que también bloquearía vencimientos a más de 60 días **en el futuro**. Falta ver qué pasa con una fecha nula |
| 13 | Corte horario de las 18:00 | `UUtilidades.pas:133-137` y `:124`. Se llama con `Now` en `UFrmPedidos.pas:240` | Hora del PC `>= 18` | La fecha del pedido pasa al siguiente día de lunes a viernes. No hay feriados. Antes de las 18:00 un pedido de fin de semana conserva su fecha | Sí |
| 14 | Folio correlativo | `UFrmPedidos.pas:249-251` | Al grabar un pedido | Folio = `MAX(FOLIO) + 1`, sin bloqueo ni transacción (`// TODO transaccion` en `:255`) | Sí |
| 15 | Estado del pedido | `UFrmPedidos.pas:262`, `UFrmInformes.pas:71` y `UFrmInformes.dfm:74` | Al grabar y en el informe | Siempre se graba `'C'`. El informe filtra `'C'` con la casilla marcada por defecto. Nada en el código escribe otro estado, pero el CSV tiene `'A'` (folios 1018 y 1042) | Sí (el significado de `'A'`, por verificar) |
| 16 | Descuento de stock | `UStock.pas:40-53` y `:69-72`; llamado en `UFrmPedidos.pas:324` | **Después** de grabar el pedido, línea por línea | Un cliente normal no puede dejar el stock bajo 0 y un VIP puede llegar a −20. Si no alcanza, solo aparece un mensaje: el pedido queda grabado y esa línea no descuenta stock | Sí |
| 17 | Validación de RUT al tomar pedidos | `UUtilidades.pas:52-80` (dígito verificador en `:73-76`); usada en `UFrmPedidos.pas:90` | Al buscar el cliente por RUT | Módulo 11 estándar (resto 11 → `'0'`, 10 → `'K'`). Distingue mayúsculas: rechaza una `'k'` minúscula | Sí |
| 18 | Validación de RUT al grabar clientes | `UFrmClientes.pas:192-198` (`RutOk`); usada en `:126` | En todo Post de cliente | **Invierte** K y 0 (resto 11 → `'K'`, 10 → `'0'`). **Difiere de la regla 17**: rechaza todo RUT válido terminado en K o 0 | Sí |
| 19 | Nivel de usuario | `UFrmPrincipal.pas:46-50`; por defecto en `UGlobales.pas:30` | Al iniciar: solo se pide el nombre, sin contraseña | Nombre vacío → `'VENTAS'`. `ADMIN` o `JEFEVENTAS` → nivel 9. Cualquier otro → nivel 1. El nivel 2 nunca se asigna | Sí |
| 20 | Acceso a informes | `UFrmPrincipal.pas:95` | Nivel `< 2` | No abre el informe. Como no existe el nivel 2, en la práctica solo entra el nivel 9 | Sí |
| 21 | Marcar cliente VIP | `UFrmClientes.pas:143` | TIPO `'V'` y nivel `< 2`, en **todo** Post (también al editar) | No deja grabar, así que un usuario de nivel 1 tampoco puede editar un cliente VIP existente | Sí |
| 22 | Borrar productos | `UFrmProductos.pas:44-45` | Nivel `< 9` | Oculta el botón de borrar del navegador | Por verificar: no hay control en `BeforeDelete`, y hay que comprobar si la grilla permite borrar con Ctrl+Supr |
| 23 | Región válida del cliente | `UFrmClientes.pas:148-149` | REGION `< 1` o `> 16` | No deja grabar. El rango está escrito en el código y no se compara con la tabla REGIONES | Sí |
| 24 | Borrado de clientes | `UFrmClientes.pas:107` y `:202-210` | El cliente tiene al menos un pedido (`COUNT(*) > 0`) | No deja borrar. Cualquier nivel puede borrar un cliente sin pedidos | Sí |
| 25 | Clientes inactivos | `UFrmClientes.pas:93` es la única referencia a `ACTIVO` | — | `ACTIVO` solo se escribe al crear el cliente. No bloquea pedidos ni búsquedas: un cliente inactivo puede comprar (el cliente 30 tiene el folio 1020) | Sí |
| 26 | Valores por defecto del cliente nuevo | `UFrmClientes.pas:90-93` | Botón Nuevo | TIPO `'N'`, REGION 13, SALDO_VENCIDO 0, ACTIVO verdadero | Sí |
| 27 | ID de cliente correlativo | `UFrmClientes.pas:160-163` | Al insertar un cliente | ID = `MAX(ID_CLIENTE) + 1`, sin bloqueo | Sí |
| 28 | Datos obligatorios del producto | `UFrmProductos.pas:82-102` | En todo Post de producto | Código no vacío, precio `> 0`, categoría de 3 caracteres cualquiera (en mayúsculas), descripción en mayúsculas y STOCK_MINIMO 10 si viene vacío | Sí |
| 29 | Líneas válidas | `UFrmPedidos.pas:142-143` y `:221` | Cantidad `<= 0` (un texto no numérico cuenta como 0), o precio `<= 0` al grabar | Rechaza la línea | Sí |
| 30 | Observación del pedido | `UFrmPedidos.pas:257-258` | Texto de más de 200 caracteres | Se recorta a 200 | Sí |
| 31 | Aviso del primer pedido | `UFrmPedidos.pas:341-342` | El cliente queda con exactamente 1 pedido | Mensaje "Avisar a cobranza". Es solo un mensaje: no queda registro | Sí |

## Comentarios que contradicen el código

| Comentario | Qué hace el código |
|---|---|
| `UCalculoTotales.pas:4`: "descuento por volumen 5% sobre 400.000 (acta comercial 2011)" | Umbral de 500.000 (regla 1). El folio 1017, con base 400.500, no tiene descuento. |
| `UGlobales.pas:13`: "2 = supervisor" | Ningún código asigna el nivel 2 (regla 19). |
| `UFrmPedidos.pas:326`: "aviso a vendedor si el total cambio" | El aviso solo aparece si `gModoPrueba`, que siempre es `False` (`UGlobales.pas:34`, `UFrmPedidos.pas:330`). |

## Parámetros de `PARAMETROS.csv`

| Clave | Situación |
|---|---|
| `TASA_IVA` | Se lee (`UFrmPrincipal.pas:62`). |
| `IMPRESORA` | Se lee (`UFrmPrincipal.pas:65`), pero no se usa en ninguna parte. |
| `PEDIDO_MINIMO`, `DESC_NAVIDAD`, `VERSION`, `EMPRESA` | **No se leen.** El código usa en su lugar 30.000, `False` y `'2.3.1'`. |

## Dudas para el PO

1. ¿Qué regla de descuento es la oficial? Los datos siguen la de grabación (`>=`, 500.000 y 1.000.000), no la de pantalla (`>`) ni la del acta de 2011 (400.000).
2. ¿El pedido mínimo es 30.000 (código) o 25.000 (parámetro)?
3. ¿Qué significa el estado `'A'` y quién lo asigna?
4. ¿Un cliente inactivo debería poder comprar?
5. ¿El redondeo `Trunc(x + 0,49)` es intencional?
6. ¿El corte horario debe considerar feriados?
