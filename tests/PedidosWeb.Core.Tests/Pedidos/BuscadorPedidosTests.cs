using PedidosWeb.Core.Pedidos;

namespace PedidosWeb.Core.Tests.Pedidos;

/// <summary>
/// Criterios de aceptación CA1–CA19 de specs/HU-01-listar-pedidos/spec.md,
/// sobre los 45 pedidos de ejemplo de <see cref="PedidoRepositorioEnMemoria"/>.
/// </summary>
public class BuscadorPedidosTests
{
    private readonly BuscadorPedidos _buscador = new(new PedidoRepositorioEnMemoria());

    private static int[] Ids(PaginaPedidos pagina) => pagina.Items.Select(p => p.Id).ToArray();

    // CA-01
    [Fact]
    public void Buscar_ClienteIdC001_Devuelve5PedidosOrdenados()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "C-001"));

        Assert.Equal(5, resultado.Total);
        Assert.Equal(new[] { 8, 16, 24, 32, 40 }, Ids(resultado));
    }

    // CA-02
    [Fact]
    public void Buscar_ClienteIdEnMinusculas_DevuelveLosMismosQueC001()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "c-001"));

        Assert.Equal(5, resultado.Total);
        Assert.Equal(new[] { 8, 16, 24, 32, 40 }, Ids(resultado));
    }

    // CA-03
    [Fact]
    public void Buscar_ClienteIdParcial_NoDevuelvePedidos()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "C-00"));

        Assert.Equal(0, resultado.Total);
        Assert.Empty(resultado.Items);
    }

    // CA-04
    [Fact]
    public void Buscar_ClienteNombreClavo_DevuelveLosPedidosDeC001()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteNombre: "clavo"));

        Assert.Equal(5, resultado.Total);
        Assert.Equal(new[] { 8, 16, 24, 32, 40 }, Ids(resultado));
    }

    // CA-05
    [Fact]
    public void Buscar_ClienteNombreAndesEnMayusculas_Devuelve6Pedidos()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteNombre: "ANDES"));

        Assert.Equal(6, resultado.Total);
        Assert.Equal(new[] { 42, 2, 10, 18, 26, 34 }, Ids(resultado));
    }

    // CA-06
    [Fact]
    public void Buscar_ClienteNombreDonaSinTilde_EncuentraDonaRosa()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteNombre: "dona"));

        Assert.Equal(6, resultado.Total);
        Assert.Equal(new[] { 21, 29, 37, 45, 5, 13 }, Ids(resultado));
    }

    // CA-07
    [Fact]
    public void Buscar_ClienteNombreAlmacenSinTilde_EncuentraAlmacenLaEsquina()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteNombre: "almacen"));

        Assert.Equal(5, resultado.Total);
        Assert.Equal(new[] { 23, 31, 39, 7, 15 }, Ids(resultado));
    }

    // CA-08
    [Fact]
    public void Buscar_EstadoPendiente_Devuelve5Pedidos()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(Estado: "Pendiente"));

        Assert.Equal(5, resultado.Total);
        Assert.Equal(new[] { 27, 18, 45, 9, 36 }, Ids(resultado));
    }

    // CA-09
    [Fact]
    public void Buscar_EstadoAnuladoEnMinusculas_Devuelve5Pedidos()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(Estado: "anulado"));

        Assert.Equal(5, resultado.Total);
        Assert.Equal(new[] { 2, 29, 20, 11, 38 }, Ids(resultado));
    }

    // CA-10
    [Fact]
    public void Buscar_RangoDeUnDia_IncluyeLosLimites()
    {
        var dia = new DateOnly(2026, 10, 20);

        var resultado = _buscador.Buscar(new FiltroPedidos(Desde: dia, Hasta: dia));

        Assert.Equal(1, resultado.Total);
        Assert.Equal(new[] { 8 }, Ids(resultado));
    }

    // CA-11
    [Fact]
    public void Buscar_ClienteYEstado_CombinaConY()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "C-001", Estado: "Entregado"));

        Assert.Equal(3, resultado.Total);
        Assert.Equal(new[] { 8, 24, 40 }, Ids(resultado));
    }

    // CA-12
    [Fact]
    public void Buscar_ClienteEstadoYRango_CombinaConY()
    {
        var filtro = new FiltroPedidos(
            ClienteId: "C-001",
            Estado: "Entregado",
            Desde: new DateOnly(2026, 9, 1),
            Hasta: new DateOnly(2026, 9, 30));

        var resultado = _buscador.Buscar(filtro);

        Assert.Equal(2, resultado.Total);
        Assert.Equal(new[] { 24, 40 }, Ids(resultado));
    }

    // CA-13
    [Fact]
    public void Buscar_ClienteIdYNombreDeOtroCliente_NoDevuelvePedidos()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "C-001", ClienteNombre: "andes"));

        Assert.Equal(0, resultado.Total);
        Assert.Empty(resultado.Items);
    }

    // CA-14
    [Fact]
    public void Buscar_ClienteInexistente_DevuelveTotalCeroYSinItems()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "C-999"));

        Assert.Equal(0, resultado.Total);
        Assert.Empty(resultado.Items);
    }

    // CA-15
    [Theory]
    [InlineData("C-001", null, null, false)]
    [InlineData(null, "andes", null, false)]
    [InlineData(null, null, "Entregado", false)]
    [InlineData(null, null, null, true)]
    public void Buscar_CualquierFiltro_OrdenaPorFechaDescYIdAsc(
        string? clienteId, string? clienteNombre, string? estado, bool rangoSeptiembre)
    {
        DateOnly? desde = rangoSeptiembre ? new DateOnly(2026, 9, 1) : null;
        DateOnly? hasta = rangoSeptiembre ? new DateOnly(2026, 9, 30) : null;

        var items = _buscador.Buscar(new FiltroPedidos(clienteId, clienteNombre, estado, desde, hasta)).Items;

        Assert.NotEmpty(items);
        for (var i = 1; i < items.Count; i++)
        {
            var anterior = items[i - 1];
            var actual = items[i];
            Assert.True(
                actual.Fecha < anterior.Fecha || (actual.Fecha == anterior.Fecha && actual.Id > anterior.Id),
                $"El pedido {actual.Id} ({actual.Fecha}) no debería ir después del {anterior.Id} ({anterior.Fecha}).");
        }
    }

    // CA-16
    [Fact]
    public void Buscar_RangoOctubrePagina1_Devuelve20DeTotal23()
    {
        var filtro = new FiltroPedidos(Desde: new DateOnly(2026, 10, 1), Hasta: new DateOnly(2026, 10, 31));

        var resultado = _buscador.Buscar(filtro);

        Assert.Equal(23, resultado.Total);
        Assert.Equal(1, resultado.Pagina);
        Assert.Equal(20, resultado.TamanoPagina);
        Assert.Equal(20, resultado.Items.Count);
        Assert.Equal(21, resultado.Items[0].Id);
        Assert.Equal(18, resultado.Items[^1].Id);
    }

    // CA-17
    [Fact]
    public void Buscar_RangoOctubrePagina2_DevuelveLos3Restantes()
    {
        var filtro = new FiltroPedidos(Desde: new DateOnly(2026, 10, 1), Hasta: new DateOnly(2026, 10, 31), Pagina: 2);

        var resultado = _buscador.Buscar(filtro);

        Assert.Equal(23, resultado.Total);
        Assert.Equal(new[] { 39, 20, 41 }, Ids(resultado));
    }

    // CA-18
    [Fact]
    public void Buscar_RangoSeptiembrePagina2_DevuelveLos2Restantes()
    {
        var filtro = new FiltroPedidos(Desde: new DateOnly(2026, 9, 1), Hasta: new DateOnly(2026, 9, 30), Pagina: 2);

        var resultado = _buscador.Buscar(filtro);

        Assert.Equal(22, resultado.Total);
        Assert.Equal(new[] { 19, 40 }, Ids(resultado));
    }

    // CA-19
    [Fact]
    public void Buscar_PaginaMasAllaDeLaUltima_DevuelveItemsVacioYTotalReal()
    {
        var resultado = _buscador.Buscar(new FiltroPedidos(ClienteId: "C-001", Pagina: 99));

        Assert.Equal(5, resultado.Total);
        Assert.Empty(resultado.Items);
    }
}
