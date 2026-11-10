using System.Globalization;

namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Valida y convierte los parámetros del listado de pedidos (HU-01), tal como llegan en la query (texto).
/// Un parámetro null significa que no vino; uno vacío o con solo espacios es un error (RN10).
/// </summary>
public static class ValidadorFiltroPedidos
{
    private const string FormatoFecha = "yyyy-MM-dd";

    public static ResultadoValidacionFiltro Validar(
        string? clienteId,
        string? clienteNombre,
        string? estado,
        string? desde,
        string? hasta,
        string? pagina)
    {
        var errores = new Dictionary<string, string[]>();
        string? detalle = null;

        // RN10: presente pero vacío o solo con espacios.
        ValidarNoVacio(nameof(clienteId), clienteId, errores);
        ValidarNoVacio(nameof(clienteNombre), clienteNombre, errores);
        ValidarNoVacio(nameof(estado), estado, errores);
        ValidarNoVacio(nameof(desde), desde, errores);
        ValidarNoVacio(nameof(hasta), hasta, errores);
        ValidarNoVacio(nameof(pagina), pagina, errores);

        // RN1 y RN9: al menos un filtro; pagina no cuenta.
        if (clienteId is null && clienteNombre is null && estado is null && desde is null && hasta is null)
            detalle = "Debe indicar al menos un filtro: clienteId, clienteNombre, estado o el rango desde/hasta.";

        // RN5: estado dentro de la lista válida.
        if (!string.IsNullOrWhiteSpace(estado) && !EstadosPedido.EsValido(estado))
            errores[nameof(estado)] = new[]
            {
                $"El estado '{estado}' no es válido. Valores aceptados: {string.Join(", ", EstadosPedido.Validos)}."
            };

        // RN6: formato yyyy-MM-dd, obligatorios juntos y desde <= hasta.
        var fechaDesde = ConvertirFecha(nameof(desde), desde, errores);
        var fechaHasta = ConvertirFecha(nameof(hasta), hasta, errores);

        if (desde is not null && hasta is null)
            errores[nameof(hasta)] = new[] { "'hasta' es obligatorio cuando se indica 'desde'." };
        if (hasta is not null && desde is null)
            errores[nameof(desde)] = new[] { "'desde' es obligatorio cuando se indica 'hasta'." };
        if (fechaDesde is { } d && fechaHasta is { } h && d > h)
            errores[nameof(desde)] = new[] { "'desde' no puede ser posterior a 'hasta'." };

        // RN8: pagina entero >= 1; por defecto 1.
        var numeroPagina = 1;
        if (!string.IsNullOrWhiteSpace(pagina))
        {
            if (!int.TryParse(pagina, NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out numeroPagina)
                || numeroPagina < 1)
                errores[nameof(pagina)] = new[] { "'pagina' debe ser un número entero mayor o igual a 1." };
        }

        if (errores.Count > 0 || detalle is not null)
            return new ResultadoValidacionFiltro(null, errores, detalle);

        var filtro = new FiltroPedidos(clienteId, clienteNombre, estado, fechaDesde, fechaHasta, numeroPagina);
        return new ResultadoValidacionFiltro(filtro, errores, null);
    }

    private static void ValidarNoVacio(string parametro, string? valor, Dictionary<string, string[]> errores)
    {
        if (valor is not null && string.IsNullOrWhiteSpace(valor))
            errores[parametro] = new[] { $"'{parametro}' no puede venir vacío." };
    }

    private static DateOnly? ConvertirFecha(string parametro, string? valor, Dictionary<string, string[]> errores)
    {
        if (string.IsNullOrWhiteSpace(valor))
            return null;

        if (DateOnly.TryParseExact(valor, FormatoFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out var fecha))
            return fecha;

        errores[parametro] = new[] { $"'{parametro}' debe tener el formato {FormatoFecha}, por ejemplo 2026-10-31." };
        return null;
    }
}
