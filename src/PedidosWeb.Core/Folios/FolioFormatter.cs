namespace PedidosWeb.Core.Folios;

/// <summary>
/// Genera el folio de un pedido con el mismo formato del sistema legado.
/// Las reglas completas y los ejemplos están en el README, sección «La función del taller».
/// </summary>
public static class FolioFormatter
{
    /// <summary>
    /// Devuelve el folio con el formato PED-{SUCURSAL}-{NUMERO}, por ejemplo "PED-STGO-000123".
    /// </summary>
    /// <param name="numero">Número correlativo del pedido, entre 1 y 999999.</param>
    /// <param name="sucursal">Código de la sucursal: de 2 a 4 letras de la A a la Z.</param>
    public static string FormatearFolio(int numero, string sucursal)
    {
        if (numero < 1 || numero > 999999)
            throw new ArgumentOutOfRangeException("numero");
        if (sucursal is null)
            throw new ArgumentNullException("sucursal");
        sucursal = sucursal.ToUpper().Trim();

        return $"PED-{sucursal.ToUpper().Trim()}-{numero.ToString().PadLeft(6, '0')}";
    }
}
