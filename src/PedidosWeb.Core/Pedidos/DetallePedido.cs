namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Detalle de un pedido (HU-02): datos del pedido, del cliente, sus líneas y el total calculado desde ellas.
/// </summary>
/// <param name="ClienteRut">RUT normalizado del cliente, o null si el cliente no está entre los conocidos.</param>
/// <param name="ClienteRegion">Código de región del cliente, o null si el cliente no está entre los conocidos.</param>
/// <param name="Lineas">Líneas del pedido, ordenadas por número.</param>
/// <param name="Total">Suma de los subtotales de las líneas, en CLP, sin IVA.</param>
public sealed record DetallePedido(
    int Id,
    string Folio,
    DateOnly Fecha,
    string Estado,
    string Sucursal,
    string ClienteId,
    string ClienteNombre,
    string? ClienteRut,
    string? ClienteRegion,
    IReadOnlyList<LineaDetalle> Lineas,
    decimal Total);
