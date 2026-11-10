namespace PedidosWeb.Core.Pedidos;

/// <summary>Acceso a los pedidos. Hoy en memoria; desde la Unidad 5, PostgreSQL.</summary>
public interface IPedidoRepositorio
{
    /// <summary>Todos los pedidos, sin filtros ni orden garantizado.</summary>
    IReadOnlyList<Pedido> ObtenerTodos();

    /// <summary>El pedido con ese id, o null si no existe.</summary>
    Pedido? ObtenerPorId(int id);
}
