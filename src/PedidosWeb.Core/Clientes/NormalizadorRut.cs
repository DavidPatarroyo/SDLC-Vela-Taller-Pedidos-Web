namespace PedidosWeb.Core.Clientes;

/// <summary>
/// Normaliza un RUT tal como lo guarda el legado (HU-02): sin puntos ni espacios y con la K en mayúscula.
/// No valida el dígito verificador.
/// </summary>
public static class NormalizadorRut
{
    /// <summary>"76.990.011-k" → "76990011-K"; "76 432 198-7" → "76432198-7".</summary>
    public static string Normalizar(string rut) =>
        rut.Replace(".", "").Replace(" ", "").ToUpperInvariant();
}
