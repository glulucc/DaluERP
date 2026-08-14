using DaluERP.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace DaluERP.Api.Data;

public class DaluERPDbContext : DbContext
{
    public DaluERPDbContext(
        DbContextOptions<DaluERPDbContext> options)
        : base(options)
    {
    }

    public DbSet<Producto> Productos => Set<Producto>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Producto>(entity =>
        {
            entity.ToTable("producto", "catalogo");

            entity.HasKey(e => e.ProductoId);

            entity.Property(e => e.ProductoId)
                .HasColumnName("producto_id");

            entity.Property(e => e.EmpresaId)
                .HasColumnName("empresa_id");

            entity.Property(e => e.CategoriaId)
                .HasColumnName("categoria_id");

            entity.Property(e => e.UnidadMedidaId)
                .HasColumnName("unidad_medida_id");

            entity.Property(e => e.Codigo)
                .HasColumnName("codigo");

            entity.Property(e => e.CodigoBarras)
                .HasColumnName("codigo_barras");

            entity.Property(e => e.Nombre)
                .HasColumnName("nombre");

            entity.Property(e => e.Descripcion)
                .HasColumnName("descripcion");

            entity.Property(e => e.TipoProducto)
                .HasColumnName("tipo_producto");

            entity.Property(e => e.EsVendible)
                .HasColumnName("es_vendible");

            entity.Property(e => e.EsInventariable)
                .HasColumnName("es_inventariable");

            entity.Property(e => e.EsIngrediente)
                .HasColumnName("es_ingrediente");

            entity.Property(e => e.CostoActual)
                .HasColumnName("costo_actual");

            entity.Property(e => e.PrecioBase)
                .HasColumnName("precio_base");

            entity.Property(e => e.StockMinimo)
                .HasColumnName("stock_minimo");

            entity.Property(e => e.StockMaximo)
                .HasColumnName("stock_maximo");

            entity.Property(e => e.Activa)
                .HasColumnName("activa");

            entity.Property(e => e.CreadoEn)
                .HasColumnName("creado_en");

            entity.Property(e => e.ActualizadoEn)
                .HasColumnName("actualizado_en");
        });
    }
}