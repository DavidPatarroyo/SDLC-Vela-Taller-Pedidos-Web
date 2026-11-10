using PedidosWeb.Core.Pedidos;

namespace PedidosWeb.Core.Tests.Pedidos;

public class PedidoRepositorioEnMemoriaTests
{
    private readonly PedidoRepositorioEnMemoria _repositorio = new();

    [Fact]
    public void ObtenerTodos_DatosDeEjemplo_Devuelve45Pedidos()
    {
        var pedidos = _repositorio.ObtenerTodos();

        Assert.Equal(45, pedidos.Count);
    }

    [Fact]
    public void ObtenerTodos_DatosDeEjemplo_LosIdsNoSeRepiten()
    {
        var ids = _repositorio.ObtenerTodos().Select(p => p.Id).ToList();

        Assert.Equal(ids.Count, ids.Distinct().Count());
    }

    [Fact]
    public void ObtenerPorId_IdExistente_DevuelveElPedido()
    {
        var pedido = _repositorio.ObtenerPorId(8);

        Assert.NotNull(pedido);
        Assert.Equal("C-001", pedido.ClienteId);
    }

    [Fact]
    public void ObtenerPorId_IdInexistente_DevuelveNull()
    {
        var pedido = _repositorio.ObtenerPorId(999);

        Assert.Null(pedido);
    }
}
