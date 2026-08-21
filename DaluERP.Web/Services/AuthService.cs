using System.Net.Http.Json;
using DaluERP.Web.DTOs;

namespace DaluERP.Web.Services;

public class AuthService
{
    private readonly IHttpClientFactory _httpClientFactory;

    public AuthService(IHttpClientFactory httpClientFactory)
    {
        _httpClientFactory = httpClientFactory;
    }

    public async Task<LoginResponse?> LoginAsync(
        string correo,
        string password)
    {
        var client = _httpClientFactory
            .CreateClient("DaluERP.Api");

        var request = new LoginRequest
        {
            Correo = correo,
            Password = password
        };

        var response = await client.PostAsJsonAsync(
            "/api/auth/login",
            request);

        if (!response.IsSuccessStatusCode)
        {
            return null;
        }

        return await response.Content
            .ReadFromJsonAsync<LoginResponse>();
    }
}