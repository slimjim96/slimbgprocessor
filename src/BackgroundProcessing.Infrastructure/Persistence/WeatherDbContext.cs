using BackgroundProcessing.Core.Models;
using Microsoft.EntityFrameworkCore;

namespace BackgroundProcessing.Infrastructure.Persistence;

public class WeatherDbContext : DbContext
{
    public WeatherDbContext(DbContextOptions<WeatherDbContext> options) : base(options)
    {
    }

    public DbSet<WeatherData> WeatherData { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<WeatherData>(entity =>
        {
            entity.HasKey(e => new { e.Location, e.Timestamp });
            entity.Property(e => e.Temperature).HasPrecision(10, 2);
            entity.Property(e => e.FeelsLike).HasPrecision(10, 2);
            entity.Property(e => e.WindSpeed).HasPrecision(10, 2);
            entity.ToTable("WeatherData");
        });
    }
}
