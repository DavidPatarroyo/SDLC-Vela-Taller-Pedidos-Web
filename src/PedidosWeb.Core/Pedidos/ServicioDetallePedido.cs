using PedidosWeb.Core.Clientes;
using PedidosWeb.Core.Lineas;

namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Arma el detalle de un pedido: pedido + cliente + líneas + total (HU-02, Fase 2).
/// </summary>
public sealed class ServicioDetallePedido
{
    private readonly IPedidoRepositorio _pedidos;
    private readonly ILineaPedidoRepositorio _lineas;
    private readonly IClienteRepositorio _clientes;

    public ServicioDetallePedido(
        IPedidoRepositorio pedidos,
        ILineaPedidoRepositorio lineas,
        IClienteRepositorio clientes)
    {
        _pedidos = pedidos;
        _lineas = lineas;
        _clientes = clientes;
    }

    /// <summary>El detalle del pedido con ese id, o null si el pedido no existe.</summary>
    public DetallePedido? Obtener(int id)
    {
        if (_pedidos.ObtenerPorId(id) is not { } pedido)
            return null;

        // Las líneas ya vienen ordenadas por número desde el repositorio.
        var lineas = _lineas.ObtenerPorPedido(pedido.Id);

        // Si el cliente no está entre los conocidos, RUT y región van en null.
        var cliente = _clientes.ObtenerPorId(pedido.ClienteId);

        return new DetallePedido(
            pedido.Id,
            pedido.Folio,
            pedido.Fecha,
            pedido.Estado,
            pedido.Sucursal,
            pedido.ClienteId,
            pedido.ClienteNombre,
            cliente is null ? null : NormalizadorRut.Normalizar(cliente.Rut),
            cliente?.Region,
            lineas.Select(l => new LineaDetalle(
                    l.Numero,
                    l.Producto,
                    l.Cantidad,
                    l.PrecioUnitario,
                    CalculadoraTotales.Subtotal(l)))
                .ToList(),
            CalculadoraTotales.Total(lineas));
    }
}
