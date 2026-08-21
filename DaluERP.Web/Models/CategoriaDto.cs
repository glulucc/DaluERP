namespace DaluERP.Web.Models;

public class CategoriaDto
{
    public long CategoriaId { get; set; }
    public long EmpresaId { get; set; }
    public string Nombre { get; set; } = string.Empty;
}