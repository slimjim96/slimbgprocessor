using BackgroundProcessing.Core.Models;
using Microsoft.EntityFrameworkCore;

namespace BackgroundProcessing.Infrastructure.Persistence;

public class StockDbContext : DbContext
{
    public StockDbContext(DbContextOptions<StockDbContext> options) : base(options)
    {
    }

    public DbSet<StockData> StockData { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<StockData>(entity =>
        {
            entity.HasKey(e => new { e.Symbol, e.Timestamp });
            entity.Property(e => e.Price).HasPrecision(18, 4);
            entity.Property(e => e.Change).HasPrecision(18, 4);
            entity.Property(e => e.PercentChange).HasPrecision(18, 4);
            entity.ToTable("StockData");
        });
    }
}
