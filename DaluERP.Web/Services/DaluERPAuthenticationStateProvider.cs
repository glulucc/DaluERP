using System.Security.Claims;
using Microsoft.AspNetCore.Components.Authorization;

namespace DaluERP.Web.Services;

public class DaluERPAuthenticationStateProvider
    : AuthenticationStateProvider
{
    private static readonly ClaimsPrincipal UsuarioAnonimo =
        new(new ClaimsIdentity());

    private ClaimsPrincipal usuarioActual = UsuarioAnonimo;

    public override Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        return Task.FromResult(
            new AuthenticationState(usuarioActual));
    }

    public void IniciarSesion(
        long usuarioId,
        string nombre,
        string correo,
        bool esGlobal)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, usuarioId.ToString()),
            new(ClaimTypes.Name, nombre),
            new(ClaimTypes.Email, correo),
            new("es_global", esGlobal.ToString().ToLowerInvariant())
        };

        var identity = new ClaimsIdentity(
            claims,
            authenticationType: "DaluERP");

        usuarioActual = new ClaimsPrincipal(identity);

        NotifyAuthenticationStateChanged(
            GetAuthenticationStateAsync());
    }

    public void CerrarSesion()
    {
        usuarioActual = UsuarioAnonimo;

        NotifyAuthenticationStateChanged(
            GetAuthenticationStateAsync());
    }
}