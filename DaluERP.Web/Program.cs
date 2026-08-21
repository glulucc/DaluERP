using DaluERP.Web.Components;
using DaluERP.Web.Services;
using Microsoft.AspNetCore.Components.Authorization;

var builder = WebApplication.CreateBuilder(args);

// Servicios de Razor/Blazor
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddScoped<EmpresaContext>();

builder.Services.AddScoped<AuthService>();

builder.Services.AddScoped<AuthState>();

builder.Services.AddAuthorizationCore();

builder.Services.AddScoped<DaluERPAuthenticationStateProvider>();

builder.Services.AddScoped<AuthenticationStateProvider>(sp =>
    sp.GetRequiredService<DaluERPAuthenticationStateProvider>());
    

// URL de nuestra API
var apiBaseUrl = builder.Configuration["ApiBaseUrl"]
    ?? throw new InvalidOperationException("No se configuró ApiBaseUrl.");

// Cliente HTTP para comunicarnos con DaluERP.Api
builder.Services.AddHttpClient("DaluERP.Api", client =>
{
    client.BaseAddress = new Uri(apiBaseUrl);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseStatusCodePagesWithReExecute(
    "/not-found",
    createScopeForStatusCodePages: true);

app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();