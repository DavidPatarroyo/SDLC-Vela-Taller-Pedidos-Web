namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Resultado de validar los parámetros del listado de pedidos.
/// </summary>
/// <param name="Filtro">El filtro listo para usar, o null si hubo errores.</param>
/// <param name="Errores">Errores por parámetro (nombre del parámetro → mensajes).</param>
/// <param name="Detalle">Error que no corresponde a un parámetro concreto (E1: ningún filtro).</param>
public sealed record ResultadoValidacionFiltro(
    FiltroPedidos? Filtro,
    IReadOnlyDictionary<string, string[]> Errores,
    string? Detalle)
{
    /// <summary>True si no hubo errores y <see cref="Filtro"/> tiene valor.</summary>
    public bool EsValido => Filtro is not null;
}
