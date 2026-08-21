namespace DaluERP.Api.Models;

public class CategoriaUsuario
{
    public long CategoriaUsuarioId { get; set; }

    public string Codigo { get; set; } = string.Empty;

    public string Nombre { get; set; } = string.Empty;

    public string? Descripcion { get; set; }

    public bool Activa { get; set; }
}