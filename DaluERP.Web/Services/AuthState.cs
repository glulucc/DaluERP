using DaluERP.Web.DTOs;

namespace DaluERP.Web.Services;

public class AuthState
{
    public bool EstaAutenticado { get; private set; }

    public LoginResponse? Usuario { get; private set; }

    public void IniciarSesion(LoginResponse usuario)
    {
        Usuario = usuario;
        EstaAutenticado = true;
    }

    public void CerrarSesion()
    {
        Usuario = null;
        EstaAutenticado = false;
    }
}