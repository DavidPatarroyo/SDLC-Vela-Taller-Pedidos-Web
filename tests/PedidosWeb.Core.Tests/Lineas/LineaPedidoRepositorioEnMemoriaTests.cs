using PedidosWeb.Core.Lineas;

namespace PedidosWeb.Core.Tests.Lineas;

public class LineaPedidoRepositorioEnMemoriaTests
{
    private readonly LineaPedidoRepositorioEnMemoria _repositorio = new();

    [Fact]
    public void ObtenerPorPedido_DatosDeEjemplo_LosPedidos1a45TienenLineas()
    {
        var sinLineas = Enumerable.Range(1, 45)
            .Where(id => _repositorio.ObtenerPorPedido(id).Count == 0)
            .ToList();

        Assert.Empty(sinLineas);
    }

    [Fact]
    public void ObtenerPorPedido_PedidoExistente_DevuelveSusLineasEnOrden()
    {
        var lineas = _repositorio.ObtenerPorPedido(8);

        Assert.Equal(3, lineas.Count);
        Assert.Equal(new[] { 1, 2, 3 }, lineas.Select(l => l.Numero));
        Assert.All(lineas, l => Assert.Equal(8, l.PedidoId));
    }

    [Fact]
    public void ObtenerPorPedido_PedidoInexistente_DevuelveListaVacia()
    {
        var lineas = _repositorio.ObtenerPorPedido(999);

        Assert.Empty(lineas);
    }
}
