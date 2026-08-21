namespace DaluERP.Api.Models;

public class Empresa
{
    public long EmpresaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string? NombreComercial { get; set; }

    public bool Activa { get; set; }
}