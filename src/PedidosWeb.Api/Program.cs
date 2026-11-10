using PedidosWeb.Core.Clientes;
using PedidosWeb.Core.Lineas;
using PedidosWeb.Core.Pedidos;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IPedidoRepositorio, PedidoRepositorioEnMemoria>();
builder.Services.AddSingleton<BuscadorPedidos>();
builder.Services.AddSingleton<ILineaPedidoRepositorio, LineaPedidoRepositorioEnMemoria>();
// Se crea a mano: si no, el contenedor elige el constructor (IEnumerable<Cliente>) con una lista vacía.
builder.Services.AddSingleton<IClienteRepositorio>(_ => new ClienteRepositorioEnMemoria());
builder.Services.AddSingleton<ServicioDetallePedido>();

var app = builder.Build();

// Para comprobar que la API está arriba.
app.MapGet("/salud", () => Results.Ok(new { estado = "ok" }));

// Detalle de un pedido por id.
app.MapGet("/api/pedidos/{id:int}", (int id, IPedidoRepositorio repositorio) =>
    repositorio.ObtenerPorId(id) is { } pedido
        ? Results.Ok(pedido)
        : Results.NotFound());

// HU-02 · Detalle de un pedido (specs/HU-02-detalle-pedido/spec.md).
// La lógica vive en Core (ServicioDetallePedido); aquí solo se traduce a HTTP.
app.MapGet("/api/pedidos/{id:int}/detalle", (int id, ServicioDetallePedido servicio) =>
    servicio.Obtener(id) is { } detalle
        ? Results.Ok(detalle)
        : Results.NotFound());

// HU-01 · Listar pedidos con filtros (specs/HU-01-listar-pedidos/spec.md).
// Las reglas viven en Core; aquí solo se lee la query como texto y se traduce el resultado a HTTP.
app.MapGet("/api/pedidos", (HttpRequest request, BuscadorPedidos buscador) =>
{
    string? Leer(string nombre) =>
        request.Query.TryGetValue(nombre, out var valor) ? valor.ToString() : null;

    var validacion = ValidadorFiltroPedidos.Validar(
        Leer("clienteId"),
        Leer("clienteNombre"),
        Leer("estado"),
        Leer("desde"),
        Leer("hasta"),
        Leer("pagina"));

    return validacion.Filtro is { } filtro
        ? Results.Ok(buscador.Buscar(filtro))
        : Results.ValidationProblem(validacion.Errores, detail: validacion.Detalle);
});

app.Run();

// Permite crear tests de integración con WebApplicationFactory<Program> más adelante.
public partial class Program { }
