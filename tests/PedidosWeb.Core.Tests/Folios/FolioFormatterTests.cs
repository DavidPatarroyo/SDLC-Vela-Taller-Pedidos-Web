using System.Globalization;
using PedidosWeb.Core.Folios;

namespace PedidosWeb.Core.Tests.Folios;

public class FolioFormatterTests
{
    // Casos base del README (tres primeras filas de la tabla de ejemplos).
    [Theory]
    [InlineData(123, "STGO", "PED-STGO-000123")]
    [InlineData(1, "VAL", "PED-VAL-000001")]
    [InlineData(999999, "CO", "PED-CO-999999")]
    public void FormatearFolio_CasosBase_DevuelveElFolioEsperado(int numero, string sucursal, string esperado)
    {
        var folio = FolioFormatter.FormatearFolio(numero, sucursal);

        Assert.Equal(esperado, folio);
    }

    // R2: se recortan los espacios de los extremos y se pasa a mayúsculas.
    [Theory]
    [InlineData(45, " stgo ", "PED-STGO-000045")]
    [InlineData(45, "stgo", "PED-STGO-000045")]
    [InlineData(45, "StGo", "PED-STGO-000045")]
    [InlineData(45, "   co   ", "PED-CO-000045")]
    public void FormatearFolio_SucursalConEspaciosOMinusculas_LaNormaliza(int numero, string sucursal, string esperado)
    {
        var folio = FolioFormatter.FormatearFolio(numero, sucursal);

        Assert.Equal(esperado, folio);
    }

    // R2 con string.Trim(): también se quitan tabulaciones, saltos de línea y espacio duro de los extremos.
    [Theory]
    [InlineData("\tSTGO")]
    [InlineData("STGO\n")]
    [InlineData("\r\n stgo \t")]
    [InlineData(" STGO ")] // espacio duro (NBSP)
    public void FormatearFolio_SucursalConEspacioEnBlancoEnLosExtremos_LoRecorta(string sucursal)
    {
        var folio = FolioFormatter.FormatearFolio(45, sucursal);

        Assert.Equal("PED-STGO-000045", folio);
    }

    // R4: relleno con ceros hasta 6 dígitos.
    [Theory]
    [InlineData(7, "PED-VAL-000007")]
    [InlineData(12345, "PED-VAL-012345")]
    [InlineData(123456, "PED-VAL-123456")]
    public void FormatearFolio_Numero_SeCompletaConCerosHastaSeisDigitos(int numero, string esperado)
    {
        var folio = FolioFormatter.FormatearFolio(numero, "VAL");

        Assert.Equal(esperado, folio);
    }

    // R1: número fuera de rango.
    [Theory]
    [InlineData(0)]
    [InlineData(1000000)]
    [InlineData(-5)]
    [InlineData(int.MinValue)]
    [InlineData(int.MaxValue)]
    public void FormatearFolio_NumeroFueraDeRango_LanzaArgumentOutOfRange(int numero)
    {
        var ex = Assert.Throws<ArgumentOutOfRangeException>(() => FolioFormatter.FormatearFolio(numero, "STGO"));

        Assert.Equal("numero", ex.ParamName);
    }

    // R3: sucursal nula, vacía o solo espacio en blanco.
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("\t\n")]
    public void FormatearFolio_SucursalNulaOVacia_LanzaArgumentException(string? sucursal)
    {
        var ex = Assert.ThrowsAny<ArgumentException>(() => FolioFormatter.FormatearFolio(7, sucursal!));

        Assert.IsNotType<ArgumentOutOfRangeException>(ex);
        Assert.Equal("sucursal", ex.ParamName);
    }

    // R3: largo o caracteres inválidos.
    [Theory]
    [InlineData("S")]       // 1 letra
    [InlineData(" S ")]     // 1 letra después de recortar
    [InlineData("SANTI")]   // 5 letras
    [InlineData("ÑUÑO")]    // la Ñ no es A–Z
    [InlineData("ST1")]     // tiene un número
    [InlineData("ST GO")]   // espacio interno
    [InlineData("S GO")]    // espacio interno con largo 4
    [InlineData("S\tGO")]   // tabulación interna (Trim solo limpia los extremos)
    [InlineData("ÁVAL")]    // tilde
    [InlineData("VAL-")]    // símbolo
    [InlineData("lıma")]    // 'ı' (i sin punto) pasaría a 'I' en mayúsculas
    [InlineData("ſtgo")]    // 'ſ' (s larga) pasaría a 'S' en mayúsculas
    [InlineData("ＳＴＧＯ")] // letras de ancho completo
    public void FormatearFolio_SucursalInvalida_LanzaArgumentException(string sucursal)
    {
        var ex = Assert.ThrowsAny<ArgumentException>(() => FolioFormatter.FormatearFolio(7, sucursal));

        Assert.IsNotType<ArgumentOutOfRangeException>(ex);
        Assert.Equal("sucursal", ex.ParamName);
    }

    // R5: si ambos son inválidos, gana la validación del número.
    [Theory]
    [InlineData(0, "S")]
    [InlineData(0, null)]
    [InlineData(1000000, "ÑUÑO")]
    public void FormatearFolio_NumeroYSucursalInvalidos_ValidaPrimeroElNumero(int numero, string? sucursal)
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => FolioFormatter.FormatearFolio(numero, sucursal!));
    }

    // El resultado no depende de la cultura del equipo (por ejemplo, la turca con la 'i').
    [Fact]
    public void FormatearFolio_ConCulturaTurca_DevuelveElMismoFolio()
    {
        var culturaOriginal = CultureInfo.CurrentCulture;
        try
        {
            CultureInfo.CurrentCulture = new CultureInfo("tr-TR");

            var folio = FolioFormatter.FormatearFolio(45, "lima");

            Assert.Equal("PED-LIMA-000045", folio);
        }
        finally
        {
            CultureInfo.CurrentCulture = culturaOriginal;
        }
    }
}
