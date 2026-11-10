namespace PedidosWeb.Core.Pedidos;

/// <summary>
/// Repositorio con 45 pedidos de ejemplo en memoria (septiembre y octubre de 2026).
/// Todos los datos son ficticios. En la Unidad 5 se reemplaza por PostgreSQL.
/// </summary>
public sealed class PedidoRepositorioEnMemoria : IPedidoRepositorio
{
    private static readonly IReadOnlyList<Pedido> Pedidos = new Pedido[]
    {
        new(1, "PED-ANT-000001", "C-006", "Supermercado del Valle", new DateOnly(2026, 9, 30), "Despachado", 98950, "ANT"),
        new(2, "PED-CON-000002", "C-003", "Botillería Los Andes", new DateOnly(2026, 10, 29), "Anulado", 68400, "CON"),
        new(3, "PED-VAL-000003", "C-008", "Distribuidora Norte", new DateOnly(2026, 9, 27), "Despachado", 37850, "VAL"),
        new(4, "PED-STGO-000004", "C-005", "Panadería San Camilo", new DateOnly(2026, 10, 26), "Entregado", 124800, "STGO"),
        new(5, "PED-ANT-000005", "C-002", "Minimarket Doña Rosa", new DateOnly(2026, 9, 24), "Confirmado", 94250, "ANT"),
        new(6, "PED-CON-000006", "C-007", "Kiosco Central", new DateOnly(2026, 10, 23), "Entregado", 63700, "CON"),
        new(7, "PED-VAL-000007", "C-004", "Almacén La Esquina", new DateOnly(2026, 9, 21), "Confirmado", 33150, "VAL"),
        new(8, "PED-STGO-000008", "C-001", "Ferretería El Clavo", new DateOnly(2026, 10, 20), "Entregado", 120100, "STGO"),
        new(9, "PED-ANT-000009", "C-006", "Supermercado del Valle", new DateOnly(2026, 9, 18), "Pendiente", 89550, "ANT"),
        new(10, "PED-CON-000010", "C-003", "Botillería Los Andes", new DateOnly(2026, 10, 17), "Despachado", 59000, "CON"),
        new(11, "PED-VAL-000011", "C-008", "Distribuidora Norte", new DateOnly(2026, 9, 15), "Anulado", 28450, "VAL"),
        new(12, "PED-STGO-000012", "C-005", "Panadería San Camilo", new DateOnly(2026, 10, 14), "Despachado", 115400, "STGO"),
        new(13, "PED-ANT-000013", "C-002", "Minimarket Doña Rosa", new DateOnly(2026, 9, 12), "Entregado", 84850, "ANT"),
        new(14, "PED-CON-000014", "C-007", "Kiosco Central", new DateOnly(2026, 10, 11), "Confirmado", 54300, "CON"),
        new(15, "PED-VAL-000015", "C-004", "Almacén La Esquina", new DateOnly(2026, 9, 9), "Entregado", 23750, "VAL"),
        new(16, "PED-STGO-000016", "C-001", "Ferretería El Clavo", new DateOnly(2026, 10, 8), "Confirmado", 110700, "STGO"),
        new(17, "PED-ANT-000017", "C-006", "Supermercado del Valle", new DateOnly(2026, 9, 6), "Entregado", 80150, "ANT"),
        new(18, "PED-CON-000018", "C-003", "Botillería Los Andes", new DateOnly(2026, 10, 5), "Pendiente", 49600, "CON"),
        new(19, "PED-VAL-000019", "C-008", "Distribuidora Norte", new DateOnly(2026, 9, 3), "Despachado", 19050, "VAL"),
        new(20, "PED-STGO-000020", "C-005", "Panadería San Camilo", new DateOnly(2026, 10, 2), "Anulado", 106000, "STGO"),
        new(21, "PED-ANT-000021", "C-002", "Minimarket Doña Rosa", new DateOnly(2026, 10, 31), "Despachado", 75450, "ANT"),
        new(22, "PED-CON-000022", "C-007", "Kiosco Central", new DateOnly(2026, 9, 29), "Entregado", 44900, "CON"),
        new(23, "PED-VAL-000023", "C-004", "Almacén La Esquina", new DateOnly(2026, 10, 28), "Confirmado", 14350, "VAL"),
        new(24, "PED-STGO-000024", "C-001", "Ferretería El Clavo", new DateOnly(2026, 9, 26), "Entregado", 101300, "STGO"),
        new(25, "PED-ANT-000025", "C-006", "Supermercado del Valle", new DateOnly(2026, 10, 25), "Confirmado", 70750, "ANT"),
        new(26, "PED-CON-000026", "C-003", "Botillería Los Andes", new DateOnly(2026, 9, 23), "Entregado", 40200, "CON"),
        new(27, "PED-VAL-000027", "C-008", "Distribuidora Norte", new DateOnly(2026, 10, 22), "Pendiente", 127150, "VAL"),
        new(28, "PED-STGO-000028", "C-005", "Panadería San Camilo", new DateOnly(2026, 9, 20), "Despachado", 96600, "STGO"),
        new(29, "PED-ANT-000029", "C-002", "Minimarket Doña Rosa", new DateOnly(2026, 10, 19), "Anulado", 66050, "ANT"),
        new(30, "PED-CON-000030", "C-007", "Kiosco Central", new DateOnly(2026, 9, 17), "Despachado", 35500, "CON"),
        new(31, "PED-VAL-000031", "C-004", "Almacén La Esquina", new DateOnly(2026, 10, 16), "Entregado", 122450, "VAL"),
        new(32, "PED-STGO-000032", "C-001", "Ferretería El Clavo", new DateOnly(2026, 9, 14), "Confirmado", 91900, "STGO"),
        new(33, "PED-ANT-000033", "C-006", "Supermercado del Valle", new DateOnly(2026, 10, 13), "Entregado", 61350, "ANT"),
        new(34, "PED-CON-000034", "C-003", "Botillería Los Andes", new DateOnly(2026, 9, 11), "Confirmado", 30800, "CON"),
        new(35, "PED-VAL-000035", "C-008", "Distribuidora Norte", new DateOnly(2026, 10, 10), "Entregado", 117750, "VAL"),
        new(36, "PED-STGO-000036", "C-005", "Panadería San Camilo", new DateOnly(2026, 9, 8), "Pendiente", 87200, "STGO"),
        new(37, "PED-ANT-000037", "C-002", "Minimarket Doña Rosa", new DateOnly(2026, 10, 7), "Despachado", 56650, "ANT"),
        new(38, "PED-CON-000038", "C-007", "Kiosco Central", new DateOnly(2026, 9, 5), "Anulado", 26100, "CON"),
        new(39, "PED-VAL-000039", "C-004", "Almacén La Esquina", new DateOnly(2026, 10, 4), "Despachado", 113050, "VAL"),
        new(40, "PED-STGO-000040", "C-001", "Ferretería El Clavo", new DateOnly(2026, 9, 2), "Entregado", 82500, "STGO"),
        new(41, "PED-ANT-000041", "C-006", "Supermercado del Valle", new DateOnly(2026, 10, 1), "Confirmado", 51950, "ANT"),
        new(42, "PED-CON-000042", "C-003", "Botillería Los Andes", new DateOnly(2026, 10, 30), "Entregado", 21400, "CON"),
        new(43, "PED-VAL-000043", "C-008", "Distribuidora Norte", new DateOnly(2026, 9, 28), "Confirmado", 108350, "VAL"),
        new(44, "PED-STGO-000044", "C-005", "Panadería San Camilo", new DateOnly(2026, 10, 27), "Entregado", 77800, "STGO"),
        new(45, "PED-ANT-000045", "C-002", "Minimarket Doña Rosa", new DateOnly(2026, 9, 25), "Pendiente", 47250, "ANT")
    };

    public IReadOnlyList<Pedido> ObtenerTodos() => Pedidos;

    public Pedido? ObtenerPorId(int id) => Pedidos.FirstOrDefault(p => p.Id == id);
}
