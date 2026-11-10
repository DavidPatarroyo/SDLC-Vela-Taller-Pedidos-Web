using PedidosWeb.Core.Clientes;
using PedidosWeb.Core.Lineas;
using PedidosWeb.Core.Pedidos;

namespace PedidosWeb.Core.Tests.Pedidos;

/// <summary>
/// Criterios de aceptación CA-05 a CA-08 (Fase 2) de specs/HU-02-detalle-pedido/spec.md,
/// sobre los pedidos, líneas y clientes de ejemplo.
/// </summary>
public class ServicioDetallePedidoTests
{
    private readonly ServicioDetallePedido _servicio = CrearServicio(new ClienteRepositorioEnMemoria());

    private static ServicioDetallePedido CrearServicio(IClienteRepositorio clientes) =>
        new(new PedidoRepositorioEnMemoria(), new LineaPedidoRepositorioEnMemoria(), clientes);

    // CA-05
    [Fact]
    public void Obtener_Pedido8_DevuelveElDetalleCompleto()
    {
        var detalle = _servicio.Obtener(8);

        Assert.NotNull(detalle);
        Assert.Equal(8, detalle.Id);
        Assert.Equal("PED-STGO-000008", detalle.Folio);
        Assert.Equal(new DateOnly(2026, 10, 20), detalle.Fecha);
        Assert.Equal("Entregado", detalle.Estado);
        Assert.Equal("STGO", detalle.Sucursal);
        Assert.Equal("C-001", detalle.ClienteId);
        Assert.Equal("Ferretería El Clavo", detalle.ClienteNombre);
        Assert.Equal("76123456-0", detalle.ClienteRut);
        Assert.Equal("RM", detalle.ClienteRegion);
        Assert.Equal(new[] { 1, 2, 3 }, detalle.Lineas.Select(l => l.Numero));
        Assert.Equal(120100m, detalle.Total);
    }

    // CA-06
    [Theory]
    [InlineData(7, "76990011-K")]
    [InlineData(3, "76432198-7")]
    public void Obtener_RutGuardadoComoElLegado_LoNormaliza(int pedidoId, string rutEsperado)
    {
        var detalle = _servicio.Obtener(pedidoId);

        Assert.NotNull(detalle);
        Assert.Equal(rutEsperado, detalle.ClienteRut);
    }

    // CA-07
    [Fact]
    public void Obtener_ClienteDesconocido_DevuelveDatosDelPedidoYRutYRegionNull()
    {
        var servicio = CrearServicio(new ClienteRepositorioEnMemoria(Array.Empty<Cliente>()));

        var detalle = servicio.Obtener(8);

        Assert.NotNull(detalle);
        Assert.Equal("C-001", detalle.ClienteId);
        Assert.Equal("Ferretería El Clavo", detalle.ClienteNombre);
        Assert.Null(detalle.ClienteRut);
        Assert.Null(detalle.ClienteRegion);
    }

    // CA-08
    [Fact]
    public void Obtener_PedidoInexistente_DevuelveNull()
    {
        var detalle = _servicio.Obtener(999);

        Assert.Null(detalle);
    }
}
