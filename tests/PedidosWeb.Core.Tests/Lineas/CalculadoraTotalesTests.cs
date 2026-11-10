using PedidosWeb.Core.Lineas;
using PedidosWeb.Core.Pedidos;

namespace PedidosWeb.Core.Tests.Lineas;

/// <summary>
/// Criterios de aceptación CA-01 a CA-04 (Fase 1) de specs/HU-02-detalle-pedido/spec.md,
/// sobre los pedidos y líneas de ejemplo.
/// </summary>
public class CalculadoraTotalesTests
{
    private readonly LineaPedidoRepositorioEnMemoria _lineas = new();

    // CA-01
    [Fact]
    public void Subtotal_Linea1DelPedido8_Devuelve64500()
    {
        var linea = _lineas.ObtenerPorPedido(8)[0];

        var subtotal = CalculadoraTotales.Subtotal(linea);

        Assert.Equal(64500m, subtotal);
    }

    // CA-02
    [Fact]
    public void Total_Pedido8_Devuelve120100()
    {
        var total = CalculadoraTotales.Total(_lineas.ObtenerPorPedido(8));

        Assert.Equal(120100m, total);
    }

    // CA-03
    [Fact]
    public void Total_Los45PedidosDeEjemplo_CoincideConPedidoTotal()
    {
        var pedidos = new PedidoRepositorioEnMemoria().ObtenerTodos();

        var noCoinciden = pedidos
            .Where(p => CalculadoraTotales.Total(_lineas.ObtenerPorPedido(p.Id)) != p.Total)
            .Select(p => p.Id)
            .ToList();

        Assert.Equal(45, pedidos.Count);
        Assert.Empty(noCoinciden);
    }

    // CA-04
    [Fact]
    public void Total_SinLineas_DevuelveCero()
    {
        var total = CalculadoraTotales.Total(Array.Empty<LineaPedido>());

        Assert.Equal(0m, total);
    }
}
