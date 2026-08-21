using DaluERP.Api.Data;
using Microsoft.EntityFrameworkCore;
using DaluERP.Api.DTOs;
using DaluERP.Api.Models;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("No se configuró Jwt:Key.");

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey)),

            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],

            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"],

            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();


builder.Services.AddDbContext<DaluERPDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DaluERP")));

builder.Services.AddScoped<IPasswordHasher<Usuario>, PasswordHasher<Usuario>>();
// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();



// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.UseHttpsRedirection();

app.MapGet("/api/health", () =>
{
    return Results.Ok(new
    {
        status = "ok",
        application = "DaluERP"
    });
});

app.MapGet("/api/health/database", async (DaluERPDbContext db) =>
{
    var conectado = await db.Database.CanConnectAsync();

    return Results.Ok(new
    {
        database = "daluerp",
        conectado
    });
});

app.MapPost("/api/auth/login", async (
    LoginRequest request,
    DaluERPDbContext db,
    IPasswordHasher<Usuario> passwordHasher) =>
{
    var correoNormalizado = request.Correo.Trim().ToUpperInvariant();

    var usuario = await db.Usuarios
        .FirstOrDefaultAsync(u =>
            u.CorreoNormalizado == correoNormalizado);

    if (usuario is null || !usuario.Activa)
    {
        return Results.Unauthorized();
    }

    var resultado = passwordHasher.VerifyHashedPassword(
        usuario,
        usuario.PasswordHash,
        request.Password);

    if (resultado == PasswordVerificationResult.Failed)
    {
        return Results.Unauthorized();
    }


var rolesInfo = await (
    from ur in db.UsuariosRoles
    join r in db.Roles
        on ur.RolId equals r.RolId
    where ur.UsuarioId == usuario.UsuarioId
          && ur.Activo
          && r.Activo
    select new
    {
        r.Codigo,
        r.EsGlobal
    }
)
.Distinct()
.ToListAsync();

var roles = rolesInfo
    .Select(r => r.Codigo)
    .ToList();

    var esGlobal = rolesInfo
    .Any(r => r.EsGlobal);
    
    List<EmpresaLoginDto> empresas;

        if (esGlobal)
        {
            empresas = await db.Empresas
                .Where(e => e.Activa)
                .OrderBy(e => e.Nombre)
                .Select(e => new EmpresaLoginDto
                {
                    EmpresaId = e.EmpresaId,
                    Nombre = e.Nombre
                })
                .ToListAsync();
        }
        else
        {
            empresas = await (
                from ue in db.UsuariosEmpresas
                join e in db.Empresas
                    on ue.EmpresaId equals e.EmpresaId
                where ue.UsuarioId == usuario.UsuarioId
                    && ue.Activo
                    && e.Activa
                orderby e.Nombre
                select new EmpresaLoginDto
                {
                    EmpresaId = e.EmpresaId,
                    Nombre = e.Nombre
                }
            )
            .Distinct()
            .ToListAsync();
        }

      EmpresaLoginDto? empresaActual = null;

        if (empresas.Count == 1)
        {
            empresaActual = empresas[0];
        }

    var permisos = await (
        from ur in db.UsuariosRoles
        join rp in db.RolesPermisos
            on ur.RolId equals rp.RolId
        join p in db.Permisos
            on rp.PermisoId equals p.PermisoId
        where ur.UsuarioId == usuario.UsuarioId
              && ur.Activo
              && p.Activo
        select p.Codigo
    )
    .Distinct()
    .OrderBy(p => p)
    .ToListAsync();

    var categoriaUsuario = await db.CategoriasUsuarios
    .Where(c => c.CategoriaUsuarioId == usuario.CategoriaUsuarioId)
    .Select(c => new
    {
        c.Codigo,
        c.Nombre
    })
    .FirstOrDefaultAsync();

var claims = new List<Claim>
{
    new(JwtRegisteredClaimNames.Sub, usuario.UsuarioId.ToString()),
    new(ClaimTypes.NameIdentifier, usuario.UsuarioId.ToString()),
    new(ClaimTypes.Name, usuario.Nombre),
    new(ClaimTypes.Email, usuario.Correo),
    new("es_global", esGlobal.ToString().ToLowerInvariant())
};

if (empresaActual is not null)
{
    claims.Add(
        new Claim(
            "empresa_actual_id",
            empresaActual.EmpresaId.ToString()));
}

var signingKey = new SymmetricSecurityKey(
    Encoding.UTF8.GetBytes(jwtKey));

var credentials = new SigningCredentials(
    signingKey,
    SecurityAlgorithms.HmacSha256);

var expirationMinutes =
    builder.Configuration.GetValue<int>("Jwt:ExpirationMinutes", 60);

var token = new JwtSecurityToken(
    issuer: builder.Configuration["Jwt:Issuer"],
    audience: builder.Configuration["Jwt:Audience"],
    claims: claims,
    expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
    signingCredentials: credentials);

var tokenString = new JwtSecurityTokenHandler()
    .WriteToken(token);





    var respuesta = new LoginResponse
    {
        UsuarioId = usuario.UsuarioId,
        Nombre = usuario.Nombre,
        Correo = usuario.Correo,
        CategoriaUsuario = categoriaUsuario?.Codigo ?? string.Empty,
        EsGlobal = esGlobal,
        Roles = roles,
        Permisos = permisos,
        Empresas = empresas,
        EmpresaActual = empresaActual,
        Token = tokenString
    };

    

    return Results.Ok(respuesta);
});

app.MapGet("/api/auth/prueba-seguridad", async (
    DaluERPDbContext db) =>
{
    var usuarioId = 1L;

    var roles = await (
        from ur in db.UsuariosRoles
        join r in db.Roles
            on ur.RolId equals r.RolId
        where ur.UsuarioId == usuarioId
              && ur.Activo
              && r.Activo
        select new
        {
            r.RolId,
            r.Codigo,
            r.Nombre,
            r.EsGlobal,
            r.EmpresaId
        })
        .ToListAsync();

    var permisos = await (
        from ur in db.UsuariosRoles
        join rp in db.RolesPermisos
            on ur.RolId equals rp.RolId
        join p in db.Permisos
            on rp.PermisoId equals p.PermisoId
        where ur.UsuarioId == usuarioId
              && ur.Activo
              && p.Activo
        select new
        {
            p.PermisoId,
            p.Codigo,
            p.Nombre,
            p.Modulo
        })
        .Distinct()
        .OrderBy(p => p.Modulo)
        .ThenBy(p => p.Codigo)
        .ToListAsync();

    return Results.Ok(new
    {
        usuarioId,
        roles,
        cantidadRoles = roles.Count,
        permisos,
        cantidadPermisos = permisos.Count
    });
});


/*--------------------------------------------------------------*
 *---------logica para categoria PRODUCTOS----------------------*
 *--------------------------------------------------------------*/
app.MapGet("/api/productos", async (DaluERPDbContext db) =>
{
    var productos = await db.Productos.ToListAsync();

    return Results.Ok(productos);
});

app.MapGet("/api/productos/{id}", async (
    long id,
    DaluERPDbContext db) =>
{
    var producto = await db.Productos
        .FirstOrDefaultAsync(p => p.ProductoId == id);

    if (producto is null)
    {
        return Results.NotFound(new
        {
            mensaje = $"No existe un producto con el ID {id}."
        });
    }

    return Results.Ok(producto);
});

app.MapGet("/api/empresas", async (DaluERPDbContext db) =>
{
    var empresas = await db.Empresas
        .Where(e => e.Activa)
        .OrderBy(e => e.Nombre)
        .Select(e => new
        {
            e.EmpresaId,
            e.Nombre
        })
        .ToListAsync();

    return Results.Ok(empresas);
});

app.MapGet("/api/categorias", async (
    long empresaId,
    DaluERPDbContext db) =>
{
    var categorias = await db.Categorias
        .Where(c => c.EmpresaId == empresaId && c.Activa)
        .OrderBy(c => c.Nombre)
        .ToListAsync();

    return Results.Ok(categorias);
});

/*app.MapGet("/api/categorias", async (DaluERPDbContext db) =>
{
    var categorias = await db.Categorias
        .Where(c => c.Activa)
        .OrderBy(c => c.Nombre)
        .Select(c => new
        {
            c.CategoriaId,
            c.EmpresaId,
            c.Nombre
        })
        .ToListAsync();

    return Results.Ok(categorias);
});*/

app.MapGet("/api/unidades-medida", async (DaluERPDbContext db) =>
{
    var unidades = await db.UnidadesMedida
        .Where(u => u.Activa)
        .OrderBy(u => u.Nombre)
        .Select(u => new
        {
            u.UnidadMedidaId,
            u.Nombre,
            u.Abreviatura
        })
        .ToListAsync();

    return Results.Ok(unidades);
});

app.MapPost("/api/productos", async (
    CrearProductoRequest request,
    DaluERPDbContext db) =>
{
    // 1. Validar los datos recibidos
    var validationContext = new ValidationContext(request);
    var validationResults = new List<ValidationResult>();

    var esValido = Validator.TryValidateObject(
        request,
        validationContext,
        validationResults,
        validateAllProperties: true);

    if (!esValido)
    {
        return Results.BadRequest(validationResults);
    }

    // 2. Verificar si ya existe el código para la empresa
    var codigoExiste = await db.Productos
        .AnyAsync(p =>
            p.EmpresaId == request.EmpresaId &&
            p.Codigo == request.Codigo);

    if (codigoExiste)
    {
        return Results.Conflict(new
        {
            mensaje = $"Ya existe un producto con el código '{request.Codigo}' para esta empresa."
        });
    }

    // 3. Crear la entidad
    var producto = new Producto
    {
        EmpresaId = request.EmpresaId,
        CategoriaId = request.CategoriaId,
        UnidadMedidaId = request.UnidadMedidaId,
        Codigo = request.Codigo,
        CodigoBarras = request.CodigoBarras,
        Nombre = request.Nombre,
        Descripcion = request.Descripcion,
        TipoProducto = request.TipoProducto,
        EsVendible = request.EsVendible,
        EsInventariable = request.EsInventariable,
        EsIngrediente = request.EsIngrediente,
        CostoActual = request.CostoActual,
        PrecioBase = request.PrecioBase,
        StockMinimo = request.StockMinimo,
        StockMaximo = request.StockMaximo,
        Activa = request.Activa
    };

    // 4. Guardar
    db.Productos.Add(producto);

    await db.SaveChangesAsync();

    // 5. Responder
    return Results.Created(
        $"/api/productos/{producto.ProductoId}",
        producto);
});

app.MapPut("/api/productos/{id}", async (
    long id,
    ActualizarProductoRequest request,
    DaluERPDbContext db) =>
{
    // 1. Validar datos
    var validationContext = new ValidationContext(request);
    var validationResults = new List<ValidationResult>();

    var esValido = Validator.TryValidateObject(
        request,
        validationContext,
        validationResults,
        validateAllProperties: true);

    if (!esValido)
    {
        return Results.BadRequest(validationResults);
    }

    // 2. Buscar producto
    var producto = await db.Productos
        .FirstOrDefaultAsync(p => p.ProductoId == id);

    if (producto is null)
    {
        return Results.NotFound(new
        {
            mensaje = $"No existe un producto con el ID {id}."
        });
    }

    // 3. Verificar código duplicado
    var codigoExiste = await db.Productos
        .AnyAsync(p =>
            p.ProductoId != id &&
            p.EmpresaId == producto.EmpresaId &&
            p.Codigo == request.Codigo);

    if (codigoExiste)
    {
        return Results.Conflict(new
        {
            mensaje = $"Ya existe otro producto con el código '{request.Codigo}' para esta empresa."
        });
    }

    // 4. Verificar código de barras duplicado
    var codigoBarrasExiste =
        !string.IsNullOrWhiteSpace(request.CodigoBarras) &&
        await db.Productos.AnyAsync(p =>
            p.ProductoId != id &&
            p.EmpresaId == producto.EmpresaId &&
            p.CodigoBarras == request.CodigoBarras);

    if (codigoBarrasExiste)
    {
        return Results.Conflict(new
        {
            mensaje = $"Ya existe otro producto con el código de barras '{request.CodigoBarras}' para esta empresa."
        });
    }

    // 5. Actualizar propiedades
    producto.CategoriaId = request.CategoriaId;
    producto.UnidadMedidaId = request.UnidadMedidaId;
    producto.Codigo = request.Codigo;
    producto.CodigoBarras = request.CodigoBarras;
    producto.Nombre = request.Nombre;
    producto.Descripcion = request.Descripcion;
    producto.TipoProducto = request.TipoProducto;
    producto.EsVendible = request.EsVendible;
    producto.EsInventariable = request.EsInventariable;
    producto.EsIngrediente = request.EsIngrediente;
    producto.CostoActual = request.CostoActual;
    producto.PrecioBase = request.PrecioBase;
    producto.StockMinimo = request.StockMinimo;
    producto.StockMaximo = request.StockMaximo;
    producto.Activa = request.Activa;

    producto.ActualizadoEn = DateTime.UtcNow;

    // 6. Guardar
    await db.SaveChangesAsync();

    // 7. Responder
    return Results.Ok(producto);
});



app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
