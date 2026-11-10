namespace PedidosWeb.Core.Lineas;

/// <summary>
/// Una línea de un pedido: qué producto, cuántas unidades y a qué precio.
/// </summary>
/// <param name="PedidoId">Id del pedido al que pertenece (ver <c>Pedido.Id</c>).</param>
/// <param name="Numero">Número de la línea dentro del pedido, desde 1.</param>
/// <param name="Producto">Descripción del producto.</param>
/// <param name="Cantidad">Unidades pedidas.</param>
/// <param name="PrecioUnitario">Precio de una unidad en pesos chilenos (CLP), sin IVA: <c>decimal</c> sin decimales.</param>
public sealed record LineaPedido(
    int PedidoId,
    int Numero,
    string Producto,
    int Cantidad,
    decimal PrecioUnitario);
