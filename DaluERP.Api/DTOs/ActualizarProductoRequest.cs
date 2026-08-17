using System.ComponentModel.DataAnnotations;

namespace DaluERP.Api.DTOs;

public class ActualizarProductoRequest
{
    [Required]
    [MaxLength(50)]
    public string Codigo { get; set; } = string.Empty;

    [MaxLength(50)]
    public string? CodigoBarras { get; set; }

    [Required]
    [MaxLength(150)]
    public string Nombre { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Descripcion { get; set; }

    [Required]
    [MaxLength(30)]
    public string TipoProducto { get; set; } = "PRODUCTO";

    public long CategoriaId { get; set; }

    public long UnidadMedidaId { get; set; }

    public bool EsVendible { get; set; }

    public bool EsInventariable { get; set; }

    public bool EsIngrediente { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "El costo actual no puede ser negativo.")]
    public decimal CostoActual { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "El precio base no puede ser negativo.")]
    public decimal PrecioBase { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "El stock mínimo no puede ser negativo.")]
    public decimal StockMinimo { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "El stock máximo no puede ser negativo.")]
    public decimal? StockMaximo { get; set; }

    public bool Activa { get; set; }
}