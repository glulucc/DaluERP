namespace DaluERP.Api.DTOs;

public class CrearProductoRequest
{
    public long EmpresaId { get; set; }

    public long CategoriaId { get; set; }

    public long UnidadMedidaId { get; set; }

    public string Codigo { get; set; } = string.Empty;

    public string? CodigoBarras { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public string? Descripcion { get; set; }

    public string TipoProducto { get; set; } = "PRODUCTO";

    public bool EsVendible { get; set; } = true;

    public bool EsInventariable { get; set; } = true;

    public bool EsIngrediente { get; set; } = false;

    public decimal CostoActual { get; set; }

    public decimal PrecioBase { get; set; }

    public decimal StockMinimo { get; set; }

    public decimal? StockMaximo { get; set; }

    public bool Activa { get; set; } = true;
}