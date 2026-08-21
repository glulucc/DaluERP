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

    public DbSet<Usuario> Usuarios => Set<Usuario>();

    public DbSet<Rol> Roles => Set<Rol>();

    public DbSet<Permiso> Permisos => Set<Permiso>();

    public DbSet<UsuarioRol> UsuariosRoles => Set<UsuarioRol>();

    public DbSet<RolPermiso> RolesPermisos => Set<RolPermiso>();
    
    public DbSet<Empresa> Empresas => Set<Empresa>();

    public DbSet<Categoria> Categorias => Set<Categoria>();

    public DbSet<UnidadMedida> UnidadesMedida => Set<UnidadMedida>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Producto>(entity =>
        {
            entity.ToTable("producto", "catalogo");

            entity.HasKey(e => e.ProductoId);

            entity.Property(e => e.ProductoId)
                .HasColumnName("producto_id")
                .ValueGeneratedOnAdd();

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

            entity.Property(e => e.CreadoEn)
               .HasColumnName("creado_en")
               .HasDefaultValueSql("CURRENT_TIMESTAMP")
               .ValueGeneratedOnAdd();

            entity.Property(e => e.ActualizadoEn)
               .HasColumnName("actualizado_en")
               .HasDefaultValueSql("CURRENT_TIMESTAMP")
               .ValueGeneratedOnAdd();
        });

        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.ToTable("usuario", "seguridad");

            entity.HasKey(e => e.UsuarioId);

            entity.Property(e => e.UsuarioId)
                .HasColumnName("usuario_id");

            entity.Property(e => e.CategoriaUsuarioId)
                .HasColumnName("categoria_usuario_id");

            entity.Property(e => e.Nombre)
                .HasColumnName("nombre");

            entity.Property(e => e.Correo)
                .HasColumnName("correo");

            entity.Property(e => e.CorreoNormalizado)
                .HasColumnName("correo_normalizado");

            entity.Property(e => e.PasswordHash)
                .HasColumnName("password_hash");

            entity.Property(e => e.Activa)
                .HasColumnName("activa");

            entity.Property(e => e.UltimoAccesoEn)
                .HasColumnName("ultimo_acceso_en");

            entity.Property(e => e.CreadoEn)
                .HasColumnName("creado_en");

            entity.Property(e => e.ActualizadoEn)
                .HasColumnName("actualizado_en");
        });

        modelBuilder.Entity<Empresa>(entity =>
        {
            entity.ToTable("empresa", "configuracion");

            entity.HasKey(e => e.EmpresaId);

            entity.Property(e => e.EmpresaId)
                .HasColumnName("empresa_id");

            entity.Property(e => e.Nombre)
                .HasColumnName("nombre");

            entity.Property(e => e.NombreComercial)
                .HasColumnName("nombre_comercial");

            entity.Property(e => e.Activa)
                .HasColumnName("activa");
        });

        modelBuilder.Entity<Categoria>(entity =>
        {
            entity.ToTable("categoria", "catalogo");

            entity.HasKey(e => e.CategoriaId);

            entity.Property(e => e.CategoriaId)
                .HasColumnName("categoria_id");

            entity.Property(e => e.EmpresaId)
                .HasColumnName("empresa_id");

            entity.Property(e => e.Codigo)
                .HasColumnName("codigo");

            entity.Property(e => e.Nombre)
                .HasColumnName("nombre");

            entity.Property(e => e.Descripcion)
                .HasColumnName("descripcion");

            entity.Property(e => e.Activa)
                .HasColumnName("activa");
        });

        modelBuilder.Entity<UnidadMedida>(entity =>
        {
            entity.ToTable("unidad_medida", "catalogo");

            entity.HasKey(e => e.UnidadMedidaId);

            entity.Property(e => e.UnidadMedidaId)
                .HasColumnName("unidad_medida_id");

            entity.Property(e => e.Codigo)
                .HasColumnName("codigo");

            entity.Property(e => e.Nombre)
                .HasColumnName("nombre");

            entity.Property(e => e.Abreviatura)
                .HasColumnName("abreviatura");

            entity.Property(e => e.PermiteDecimales)
                .HasColumnName("permite_decimales");

            entity.Property(e => e.Activa)
                .HasColumnName("activa");
        });
    }
}