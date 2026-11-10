using PedidosWeb.Core.Clientes;

namespace PedidosWeb.Core.Tests.Clientes;

public class ClientesServiceTests
{
    private readonly ClientesService _servicio = new();

    [Fact]
    public void Proc2_ClienteInexistente_DevuelveTextoVacio()
    {
        var ficha = _servicio.proc2("C-999");

        Assert.Equal("", ficha);
    }

    [Fact]
    public void Proc2_ClienteActivo_DevuelveLaFicha()
    {
        var ficha = _servicio.proc2("C-001");

        Assert.Equal("Ferretería El Clavo | 76123456-0 | Zona centro | Activo", ficha);
    }

    [Fact]
    public void Proc2_RutConPuntosYKMinuscula_LoNormaliza()
    {
        var ficha = _servicio.proc2("C-004");

        Assert.Equal("Almacén La Esquina | 76990011-K | Zona centro | Activo", ficha);
    }

    [Fact]
    public void Proc3_ClienteActivoEInactivo_DevuelveSiEstaActivo()
    {
        Assert.True(_servicio.proc3("C-001"));
        Assert.False(_servicio.proc3("C-007"));
        Assert.False(_servicio.proc3("C-999"));
    }
}
