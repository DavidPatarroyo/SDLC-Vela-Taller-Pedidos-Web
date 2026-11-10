namespace PedidosWeb.Core.Clientes;

/// <summary>Un cliente de la distribuidora. Todos los datos son ficticios.</summary>
public class Cliente
{
    public string Id { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Rut { get; set; } = "";
    public string Region { get; set; } = "";
    public bool Activo { get; set; }
}
