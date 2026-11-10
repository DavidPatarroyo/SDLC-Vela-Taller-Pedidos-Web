namespace PedidosWeb.Core.Clientes;

/// <summary>Acceso a los clientes. Hoy en memoria; desde la Unidad 5, PostgreSQL.</summary>
public interface IClienteRepositorio
{
    /// <summary>El cliente con ese id, o null si no existe.</summary>
    Cliente? ObtenerPorId(string id);
}
