using System.Globalization;

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
        // R1 y R5: el número se valida antes que la sucursal.
        if (numero < 1 || numero > 999999)
            throw new ArgumentOutOfRangeException(nameof(numero), numero, "El número del pedido debe estar entre 1 y 999999.");

        if (sucursal is null)
            throw new ArgumentNullException(nameof(sucursal));

        // R2: sin espacios al inicio ni al final y en mayúsculas, sin depender de la cultura del equipo.
        var codigo = sucursal.Trim().ToUpperInvariant();

        // R3: de 2 a 4 letras A–Z (campo ASCII del legado). Rechaza vacíos, Ñ, tildes, números y espacios internos.
        if (codigo.Length < 2 || codigo.Length > 4 || !codigo.All(c => c >= 'A' && c <= 'Z'))
            throw new ArgumentException("La sucursal debe tener entre 2 y 4 letras de la A a la Z.", nameof(sucursal));

        // R4: número con ceros a la izquierda hasta 6 dígitos.
        return $"PED-{codigo}-{numero.ToString("D6", CultureInfo.InvariantCulture)}";
    }
}
