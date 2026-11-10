namespace PedidosWeb.Core.Pedidos;

/// <summary>Estados de pedido aceptados como filtro en HU-01 (RN5).</summary>
public static class EstadosPedido
{
    /// <summary>Los 5 estados válidos, tal como los guarda el legado.</summary>
    public static readonly IReadOnlyList<string> Validos =
        new[] { "Pendiente", "Confirmado", "Despachado", "Entregado", "Anulado" };

    private static readonly HashSet<string> ValidosSinMayusculas = new(Validos, StringComparer.OrdinalIgnoreCase);

    /// <summary>Indica si <paramref name="estado"/> es uno de los estados válidos, sin distinguir mayúsculas.</summary>
    public static bool EsValido(string estado) => ValidosSinMayusculas.Contains(estado);
}
