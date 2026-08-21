namespace DaluERP.Api.Models;

public class Rol
{
    public long RolId { get; set; }

    public long? EmpresaId { get; set; }

    public string Codigo { get; set; } = string.Empty;

    public string Nombre { get; set; } = string.Empty;

    public string? Descripcion { get; set; }

    public bool EsGlobal { get; set; }

    public bool Activo { get; set; }
}