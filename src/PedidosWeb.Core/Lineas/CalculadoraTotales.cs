namespace PedidosWeb.Core.Lineas;

/// <summary>
/// Subtotal de una línea y total de un pedido a partir de sus líneas (HU-02, Fase 1).
/// Montos en CLP, <c>decimal</c> sin decimales, sin IVA.
/// </summary>
public static class CalculadoraTotales
{
    /// <summary>Cantidad × precio unitario de la línea.</summary>
    public static decimal Subtotal(LineaPedido linea) => linea.Cantidad * linea.PrecioUnitario;

    /// <summary>Suma de los subtotales de las líneas; 0 si no hay líneas.</summary>
    public static decimal Total(IEnumerable<LineaPedido> lineas) => lineas.Sum(Subtotal);
}
