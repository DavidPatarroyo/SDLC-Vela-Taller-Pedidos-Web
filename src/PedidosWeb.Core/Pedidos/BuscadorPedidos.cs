using System.Globalization;
using System.Text;

namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Lista pedidos con filtros, orden y paginación (HU-01).
/// Recibe un <see cref="FiltroPedidos"/> ya validado por <see cref="ValidadorFiltroPedidos"/>.
/// </summary>
public sealed class BuscadorPedidos
{
    /// <summary>Pedidos por página (RN8).</summary>
    public const int TamanoPagina = 20;

    private readonly IPedidoRepositorio _repositorio;

    public BuscadorPedidos(IPedidoRepositorio repositorio) => _repositorio = repositorio;

    /// <summary>Devuelve la página pedida de los pedidos que cumplen todos los filtros presentes.</summary>
    public PaginaPedidos Buscar(FiltroPedidos filtro)
    {
        IEnumerable<Pedido> pedidos = _repositorio.ObtenerTodos();

        // RN2: los filtros presentes se combinan con Y.
        // RN3: clienteId igual, sin distinguir mayúsculas.
        if (filtro.ClienteId is not null)
            pedidos = pedidos.Where(p => string.Equals(p.ClienteId, filtro.ClienteId, StringComparison.OrdinalIgnoreCase));

        // RN4: clienteNombre contenido, sin distinguir mayúsculas ni tildes.
        if (filtro.ClienteNombre is not null)
        {
            var buscado = SinTildesEnMayusculas(filtro.ClienteNombre);
            pedidos = pedidos.Where(p => SinTildesEnMayusculas(p.ClienteNombre).Contains(buscado, StringComparison.Ordinal));
        }

        // RN5: estado igual, sin distinguir mayúsculas.
        if (filtro.Estado is not null)
            pedidos = pedidos.Where(p => string.Equals(p.Estado, filtro.Estado, StringComparison.OrdinalIgnoreCase));

        // RN6: rango inclusivo.
        if (filtro.Desde is { } desde)
            pedidos = pedidos.Where(p => p.Fecha >= desde);
        if (filtro.Hasta is { } hasta)
            pedidos = pedidos.Where(p => p.Fecha <= hasta);

        // RN7: Fecha descendente; a igual fecha, Id ascendente.
        var ordenados = pedidos
            .OrderByDescending(p => p.Fecha)
            .ThenBy(p => p.Id)
            .ToList();

        // RN8: 20 por página. El salto se calcula en long para que una página muy alta
        // devuelva items vacío en vez de desbordar.
        var salto = (filtro.Pagina - 1L) * TamanoPagina;
        var items = salto >= ordenados.Count
            ? new List<Pedido>()
            : ordenados.Skip((int)salto).Take(TamanoPagina).ToList();

        return new PaginaPedidos(ordenados.Count, filtro.Pagina, TamanoPagina, items);
    }

    /// <summary>
    /// Quita tildes y diacríticos (á → a, ñ → n) y pasa a mayúsculas, para comparar nombres (RN4).
    /// </summary>
    private static string SinTildesEnMayusculas(string texto)
    {
        var descompuesto = texto.Normalize(NormalizationForm.FormD);
        var resultado = new StringBuilder(descompuesto.Length);
        foreach (var caracter in descompuesto)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(caracter) != UnicodeCategory.NonSpacingMark)
                resultado.Append(caracter);
        }

        return resultado.ToString().Normalize(NormalizationForm.FormC).ToUpperInvariant();
    }
}
