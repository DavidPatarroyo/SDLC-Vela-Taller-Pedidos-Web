namespace PedidosWeb.Core.Pedidos;

/// <summary>Una línea dentro del detalle de un pedido (HU-02).</summary>
/// <param name="Numero">Número de la línea dentro del pedido, desde 1.</param>
/// <param name="Producto">Descripción del producto.</param>
/// <param name="Cantidad">Unidades pedidas.</param>
/// <param name="PrecioUnitario">Precio de una unidad en CLP, sin IVA.</param>
/// <param name="Subtotal">Cantidad × precio unitario, en CLP, sin IVA.</param>
public sealed record LineaDetalle(
    int Numero,
    string Producto,
    int Cantidad,
    decimal PrecioUnitario,
    decimal Subtotal);
