namespace DaluERP.Api.Models;

public class Usuario
{
    public long UsuarioId { get; set; }

    public long CategoriaUsuarioId { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string Correo { get; set; } = string.Empty;

    public string CorreoNormalizado { get; set; } = string.Empty;

    public string PasswordHash { get; set; } = string.Empty;

    public bool Activa { get; set; } = true;

    public DateTimeOffset? UltimoAccesoEn { get; set; }

    public DateTimeOffset CreadoEn { get; set; }

    public DateTimeOffset ActualizadoEn { get; set; }
}