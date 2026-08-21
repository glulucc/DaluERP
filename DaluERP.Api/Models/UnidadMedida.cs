namespace DaluERP.Api.Models;

public class UnidadMedida
{
    public long UnidadMedidaId { get; set; }

    public string Codigo { get; set; } = string.Empty;

    public string Nombre { get; set; } = string.Empty;

    public string? Abreviatura { get; set; }

    public bool PermiteDecimales { get; set; }

    public bool Activa { get; set; }
}