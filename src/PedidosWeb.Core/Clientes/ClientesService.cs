namespace PedidosWeb.Core.Clientes;

// Servicio heredado: lo escribió un ex integrante del equipo, con apuro.
// Funciona y tiene 4 tests. Nadie se ha atrevido a tocarlo.
public class ClientesService
{
    private readonly List<Cliente> _l;

    public ClientesService() : this(ClientesDeEjemplo.Crear()) { }

    public ClientesService(List<Cliente> l)
    {
        _l = l;
    }

    // ficha del cliente para la pantalla
    public string proc2(string id)
    {
        Cliente? c = null;
        for (int i = 0; i < _l.Count; i++)
        {
            if (_l[i].Id == id) { c = _l[i]; break; }
        }
        if (c == null) return "";
        string r = c.Rut.Replace(".", "").Replace(" ", "").ToUpper();
        string t = "";
        if (c.Region == "RM") t = "Zona centro";
        else if (c.Region == "V") t = "Zona centro";
        else if (c.Region == "VIII") t = "Zona sur";
        else if (c.Region == "II") t = "Zona norte";
        else t = "Sin zona";
        string e = "";
        if (c.Activo == true) e = "Activo"; else e = "Inactivo";
        return c.Nombre + " | " + r + " | " + t + " | " + e;
    }

    // si existe y está activo
    public bool proc3(string id)
    {
        Cliente? c = null;
        for (int i = 0; i < _l.Count; i++)
        {
            if (_l[i].Id == id) { c = _l[i]; break; }
        }
        if (c == null) return false;
        if (c.Activo == true) return true; else return false;
    }
}
