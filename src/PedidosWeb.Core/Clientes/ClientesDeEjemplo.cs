namespace PedidosWeb.Core.Clientes;

/// <summary>
/// Los 8 clientes de los pedidos de ejemplo. Los RUT vienen escritos como en el
/// sistema legado: a veces con puntos, con espacios o con la «k» en minúscula.
/// </summary>
public static class ClientesDeEjemplo
{
    public static List<Cliente> Crear() => new()
    {
        new Cliente { Id = "C-001", Nombre = "Ferretería El Clavo", Rut = "76.123.456-0", Region = "RM", Activo = true },
        new Cliente { Id = "C-002", Nombre = "Minimarket Doña Rosa", Rut = "77654321-7", Region = "II", Activo = true },
        new Cliente { Id = "C-003", Nombre = "Botillería Los Andes", Rut = "78.345.612-5", Region = "VIII", Activo = true },
        new Cliente { Id = "C-004", Nombre = "Almacén La Esquina", Rut = "76.990.011-k", Region = "V", Activo = true },
        new Cliente { Id = "C-005", Nombre = "Panadería San Camilo", Rut = "77.888.999-4", Region = "RM", Activo = true },
        new Cliente { Id = "C-006", Nombre = "Supermercado del Valle", Rut = "76.555.444-6", Region = "II", Activo = true },
        new Cliente { Id = "C-007", Nombre = "Kiosco Central", Rut = "77.321.654-1", Region = "VIII", Activo = false },
        new Cliente { Id = "C-008", Nombre = "Distribuidora Norte", Rut = "76 432 198-7", Region = "V", Activo = true },
    };
}
