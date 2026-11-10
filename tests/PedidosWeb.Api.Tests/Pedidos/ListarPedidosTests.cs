using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace PedidosWeb.Api.Tests.Pedidos;

/// <summary>
/// Criterios de aceptación CA20–CA27 de specs/HU-01-listar-pedidos/spec.md:
/// errores de GET /api/pedidos (400 con ProblemDetails).
/// Las reglas viven en PedidosWeb.Core (ValidadorFiltroPedidos); el endpoint solo las traduce a HTTP.
/// </summary>
public class ListarPedidosTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _cliente;

    public ListarPedidosTests(WebApplicationFactory<Program> fabrica) => _cliente = fabrica.CreateClient();

    private async Task AssertDevuelve400ConProblemDetails(string url)
    {
        var respuesta = await _cliente.GetAsync(url);

        Assert.Equal(HttpStatusCode.BadRequest, respuesta.StatusCode);
        Assert.Equal("application/problem+json", respuesta.Content.Headers.ContentType?.MediaType);
    }

    // CA-20
    [Fact]
    public async Task ListarPedidos_SinParametros_Devuelve400()
    {
        await AssertDevuelve400ConProblemDetails("/api/pedidos");
    }

    // CA-21
    [Fact]
    public async Task ListarPedidos_SoloPagina_Devuelve400()
    {
        await AssertDevuelve400ConProblemDetails("/api/pedidos?pagina=2");
    }

    // CA-22
    [Theory]
    [InlineData("/api/pedidos?desde=2026-10-01")]
    [InlineData("/api/pedidos?hasta=2026-10-31")]
    public async Task ListarPedidos_SoloUnLimiteDeFecha_Devuelve400(string url)
    {
        await AssertDevuelve400ConProblemDetails(url);
    }

    // CA-23
    [Fact]
    public async Task ListarPedidos_FechasInvertidas_Devuelve400()
    {
        await AssertDevuelve400ConProblemDetails("/api/pedidos?desde=2026-10-31&hasta=2026-10-01");
    }

    // CA-24
    [Fact]
    public async Task ListarPedidos_FechaConFormatoInvalido_Devuelve400()
    {
        await AssertDevuelve400ConProblemDetails("/api/pedidos?desde=31-10-2026&hasta=2026-10-31");
    }

    // CA-25
    [Fact]
    public async Task ListarPedidos_EstadoInvalido_Devuelve400()
    {
        await AssertDevuelve400ConProblemDetails("/api/pedidos?estado=Perdido");
    }

    // CA-26
    [Theory]
    [InlineData("/api/pedidos?clienteId=C-001&pagina=0")]
    [InlineData("/api/pedidos?clienteId=C-001&pagina=-1")]
    [InlineData("/api/pedidos?clienteId=C-001&pagina=abc")]
    public async Task ListarPedidos_PaginaInvalida_Devuelve400(string url)
    {
        await AssertDevuelve400ConProblemDetails(url);
    }

    // CA-27
    [Theory]
    [InlineData("/api/pedidos?estado=&clienteId=C-001")]
    [InlineData("/api/pedidos?clienteNombre=%20%20")]
    public async Task ListarPedidos_ParametroVacio_Devuelve400(string url)
    {
        await AssertDevuelve400ConProblemDetails(url);
    }
}
