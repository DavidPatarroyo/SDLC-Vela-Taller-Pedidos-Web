using System.Globalization;

namespace PedidosWeb.Core.Folios;

/// <summary>
/// Genera el folio de un pedido con el mismo formato del sistema legado.
/// Las reglas completas y los ejemplos están en el README, sección «La función del taller».
/// </summary>
public static class FolioFormatter
{
    private const int NumeroMinimo = 1;
    private const int NumeroMaximo = 999999;
    private const int LargoMinimoSucursal = 2;
    private const int LargoMaximoSucursal = 4;

    /// <summary>
    /// Devuelve el folio con el formato PED-{SUCURSAL}-{NUMERO}, por ejemplo "PED-STGO-000123".
    /// </summary>
    /// <param name="numero">Número correlativo del pedido, entre 1 y 999999.</param>
    /// <param name="sucursal">Código de la sucursal: de 2 a 4 letras de la A a la Z.</param>
    /// <exception cref="ArgumentOutOfRangeException">Si <paramref name="numero"/> está fuera de rango (R1).</exception>
    /// <exception cref="ArgumentException">Si <paramref name="sucursal"/> es nula, vacía o inválida (R3).</exception>
    public static string FormatearFolio(int numero, string sucursal)
    {
        // R1 y R5: el número se valida antes que la sucursal.
        if (numero < NumeroMinimo || numero > NumeroMaximo)
            throw new ArgumentOutOfRangeException(nameof(numero), numero,
                $"El número del pedido debe estar entre {NumeroMinimo} y {NumeroMaximo}.");

        var codigo = NormalizarSucursal(sucursal);

        // R4: ceros a la izquierda hasta 6 dígitos, sin depender de la cultura del equipo.
        return $"PED-{codigo}-{numero.ToString("D6", CultureInfo.InvariantCulture)}";
    }

    /// <summary>
    /// Aplica R2 (recortar espacios y pasar a mayúsculas) y R3 (2 a 4 letras A–Z).
    /// </summary>
    private static string NormalizarSucursal(string sucursal)
    {
        if (sucursal is null)
            throw new ArgumentNullException(nameof(sucursal), "La sucursal es obligatoria.");

        // R2: string.Trim() quita todo el espacio en blanco de los extremos
        // (espacio, tabulación, salto de línea, espacio duro, etc.).
        var recortada = sucursal.Trim();

        if (recortada.Length < LargoMinimoSucursal || recortada.Length > LargoMaximoSucursal)
            throw new ArgumentException(
                $"La sucursal debe tener entre {LargoMinimoSucursal} y {LargoMaximoSucursal} letras.",
                nameof(sucursal));

        // R3: se valida sobre el texto original, antes de pasar a mayúsculas, para que
        // letras Unicode como 'ı' o 'ſ' no se conviertan en 'I' o 'S' y pasen la validación.
        foreach (var caracter in recortada)
        {
            if (!char.IsAsciiLetter(caracter))
                throw new ArgumentException(
                    "La sucursal solo admite letras de la A a la Z (sin Ñ, tildes, números ni espacios).",
                    nameof(sucursal));
        }

        return recortada.ToUpperInvariant();
    }
}
