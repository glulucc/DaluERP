using DaluERP.Api.Data;
using Microsoft.EntityFrameworkCore;
using DaluERP.Api.DTOs;
using DaluERP.Api.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<DaluERPDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DaluERP")));

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

/*--------------------------------------------------------------*
 *---------logica para categoria PRODUCTOS----------------------*
 *--------------------------------------------------------------*/
app.MapGet("/api/productos", async (DaluERPDbContext db) =>
{
    var productos = await db.Productos.ToListAsync();

    return Results.Ok(productos);
});

app.MapGet("/api/productos/{id:long}", async (
    long id,
    DaluERPDbContext db) =>
{
    var producto = await db.Productos
        .FirstOrDefaultAsync(p => p.ProductoId == id);

    if (producto is null)
    {
        return Results.NotFound();
    }

    return Results.Ok(producto);
});


app.MapPost("/api/productos", async (
    CrearProductoRequest request,
    DaluERPDbContext db) =>
{
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

    db.Productos.Add(producto);

    await db.SaveChangesAsync();

    return Results.Created(
        $"/api/productos/{producto.ProductoId}",
        producto);
});

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
