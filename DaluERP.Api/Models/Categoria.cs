namespace DaluERP.Api.Models;

public class Categoria
{
    public long CategoriaId { get; set; }

    public long EmpresaId { get; set; }

    public string Codigo { get; set; } = string.Empty;

    public string Nombre { get; set; } = string.Empty;

    public string? Descripcion { get; set; }

    public bool Activa { get; set; }
}