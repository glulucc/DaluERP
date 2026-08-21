namespace DaluERP.Api.Models;

public class UsuarioEmpresa
{
    public long UsuarioEmpresaId { get; set; }

    public long UsuarioId { get; set; }

    public long EmpresaId { get; set; }

    public bool EsPrincipal { get; set; }

    public bool Activo { get; set; }
}