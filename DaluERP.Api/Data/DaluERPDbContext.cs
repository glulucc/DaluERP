using Microsoft.EntityFrameworkCore;

namespace DaluERP.Api.Data;

public class DaluERPDbContext : DbContext
{
    public DaluERPDbContext(
        DbContextOptions<DaluERPDbContext> options)
        : base(options)
    {
    }
}