namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Filtro ya validado para listar pedidos (HU-01). Los filtros nulos no se aplican.
/// </summary>
/// <param name="ClienteId">Código de cliente; se compara igual, sin distinguir mayúsculas (RN3).</param>
/// <param name="ClienteNombre">Texto contenido en el nombre del cliente, sin distinguir mayúsculas ni tildes (RN4).</param>
/// <param name="Estado">Uno de <see cref="EstadosPedido.Validos"/>, sin distinguir mayúsculas (RN5).</param>
/// <param name="Desde">Inicio del rango de fechas, inclusivo (RN6).</param>
/// <param name="Hasta">Fin del rango de fechas, inclusivo (RN6).</param>
/// <param name="Pagina">Número de página, desde 1 (RN8).</param>
public sealed record FiltroPedidos(
    string? ClienteId = null,
    string? ClienteNombre = null,
    string? Estado = null,
    DateOnly? Desde = null,
    DateOnly? Hasta = null,
    int Pagina = 1);
