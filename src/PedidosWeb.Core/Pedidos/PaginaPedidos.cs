namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Una página del listado de pedidos (HU-01).
/// </summary>
/// <param name="Total">Cantidad de pedidos que cumplen los filtros, sumando todas las páginas.</param>
/// <param name="Pagina">Número de la página devuelta.</param>
/// <param name="TamanoPagina">Pedidos por página (fijo).</param>
/// <param name="Items">Pedidos de esta página, en el orden de RN7.</param>
public sealed record PaginaPedidos(
    int Total,
    int Pagina,
    int TamanoPagina,
    IReadOnlyList<Pedido> Items);
