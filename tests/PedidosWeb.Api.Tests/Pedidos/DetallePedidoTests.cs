using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using PedidosWeb.Core.Pedidos;

namespace PedidosWeb.Api.Tests.Pedidos;

/// <summary>
/// Criterios de aceptación CA-09 a CA-11 (Fase 3) de specs/HU-02-detalle-pedido/spec.md:
/// GET /api/pedidos/{id}/detalle y regresión de GET /api/pedidos/{id}.
/// La lógica vive en PedidosWeb.Core (ServicioDetallePedido); el endpoint solo la traduce a HTTP.
/// </summary>
public class DetallePedidoTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _cliente;

    public DetallePedidoTests(WebApplicationFactory<Program> fabrica) => _cliente = fabrica.CreateClient();

    // CA-09
    [Fact]
    public async Task ObtenerDetalle_Pedido8_Devuelve200ConElDetalle()
    {
        var respuesta = await _cliente.GetAsync("/api/pedidos/8/detalle");

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);
        Assert.Equal("application/json", respuesta.Content.Headers.ContentType?.MediaType);

        var json = await respuesta.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(120100m, json.GetProperty("total").GetDecimal());
        Assert.Equal("76123456-0", json.GetProperty("clienteRut").GetString());
        Assert.Equal(3, json.GetProperty("lineas").GetArrayLength());
    }

    // CA-10
    [Fact]
    public async Task ObtenerDetalle_PedidoInexistente_Devuelve404()
    {
        var respuesta = await _cliente.GetAsync("/api/pedidos/999/detalle");

        Assert.Equal(HttpStatusCode.NotFound, respuesta.StatusCode);
    }

    // CA-11
    [Fact]
    public async Task ObtenerPedido_Pedido8_NoCambia()
    {
        var respuesta = await _cliente.GetAsync("/api/pedidos/8");

        Assert.Equal(HttpStatusCode.OK, respuesta.StatusCode);

        // Exactamente las 8 propiedades de Pedido: si la ruta devolviera el detalle, aparecerían otras (por ejemplo "lineas").
        var json = await respuesta.Content.ReadFromJsonAsync<JsonElement>();
        var propiedades = json.EnumerateObject().Select(p => p.Name).OrderBy(n => n, StringComparer.Ordinal);
        var esperadas = new[] { "id", "folio", "clienteId", "clienteNombre", "fecha", "estado", "total", "sucursal" }
            .OrderBy(n => n, StringComparer.Ordinal);
        Assert.Equal(esperadas, propiedades);

        var pedido = json.Deserialize<Pedido>(JsonSerializerOptions.Web);
        Assert.Equal(new PedidoRepositorioEnMemoria().ObtenerPorId(8), pedido);
    }
}
