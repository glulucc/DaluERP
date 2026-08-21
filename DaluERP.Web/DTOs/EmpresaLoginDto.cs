namespace DaluERP.Web.DTOs;

public class EmpresaLoginDto
{
    public long EmpresaId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string? NombreComercial { get; set; }
}