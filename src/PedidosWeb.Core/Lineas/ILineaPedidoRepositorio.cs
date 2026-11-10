namespace PedidosWeb.Core.Lineas;

/// <summary>Acceso a las líneas de los pedidos. Hoy en memoria; desde la Unidad 5, PostgreSQL.</summary>
public interface ILineaPedidoRepositorio
{
    /// <summary>Las líneas del pedido, ordenadas por número. Lista vacía si el pedido no tiene líneas o no existe.</summary>
    IReadOnlyList<LineaPedido> ObtenerPorPedido(int pedidoId);
}
