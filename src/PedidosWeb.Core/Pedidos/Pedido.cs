namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Un pedido del sistema, tal como viene del legado.
/// </summary>
/// <param name="Id">Número correlativo del pedido.</param>
/// <param name="Folio">Folio con formato PED-{SUCURSAL}-{NUMERO}, por ejemplo "PED-STGO-000008".</param>
/// <param name="ClienteId">Código del cliente, por ejemplo "C-001".</param>
/// <param name="ClienteNombre">Nombre del cliente.</param>
/// <param name="Fecha">Fecha en que se emitió el pedido (hora local de Chile; sin hora).</param>
/// <param name="Estado">Estado del pedido como texto, tal como lo guarda el legado.</param>
/// <param name="Total">Total en pesos chilenos (CLP): <c>decimal</c> sin decimales; nunca <c>double</c> ni <c>float</c>.</param>
/// <param name="Sucursal">Código de la sucursal que emitió el pedido.</param>
public sealed record Pedido(
    int Id,
    string Folio,
    string ClienteId,
    string ClienteNombre,
    DateOnly Fecha,
    string Estado,
    decimal Total,
    string Sucursal);
