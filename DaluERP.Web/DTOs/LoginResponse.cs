namespace DaluERP.Web.DTOs;

public class LoginResponse
{
    public long UsuarioId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string CategoriaUsuario { get; set; } = string.Empty;

    public bool EsGlobal { get; set; }

    public List<string> Roles { get; set; } = new();

    public List<string> Permisos { get; set; } = new();

    public List<EmpresaLoginDto> Empresas { get; set; } = new();

    public EmpresaLoginDto? EmpresaActual { get; set; }

    public string Token { get; set; } = string.Empty;
}