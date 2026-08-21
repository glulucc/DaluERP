namespace DaluERP.Api.Models;

public class UsuarioRol
{
    public long UsuarioRolId { get; set; }

    public long UsuarioId { get; set; }

    public long RolId { get; set; }

    public bool Activo { get; set; }
}