namespace DaluERP.Api.Models;

public class Producto
{
    public long ProductoId { get; set; }

    public long EmpresaId { get; set; }

    public long CategoriaId { get; set; }

    public long UnidadMedidaId { get; set; }

    public string Codigo { get; set; } = string.Empty;

    public string? CodigoBarras { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string? Descripcion { get; set; }

    public string TipoProducto { get; set; } = string.Empty;

    public bool EsVendible { get; set; }

    public bool EsInventariable { get; set; }

    public bool EsIngrediente { get; set; }

    public decimal CostoActual { get; set; }

    public decimal PrecioBase { get; set; }

    public decimal StockMinimo { get; set; }

    public decimal? StockMaximo { get; set; }

    public bool Activa { get; set; }

    public DateTime CreadoEn { get; set; }

    public DateTime ActualizadoEn { get; set; }
}