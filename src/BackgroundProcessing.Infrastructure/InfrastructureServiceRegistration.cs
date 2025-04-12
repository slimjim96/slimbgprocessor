using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.Infrastructure.Persistence;
using BackgroundProcessing.Infrastructure.Repositories;
using BackgroundProcessing.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace BackgroundProcessing.Infrastructure;

public static class InfrastructureServiceRegistration
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Register DbContexts
        services.AddDbContext<StockDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("StockDatabase"),
                b => b.MigrationsAssembly(typeof(StockDbContext).Assembly.FullName)));

        services.AddDbContext<WeatherDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("WeatherDatabase"),
                b => b.MigrationsAssembly(typeof(WeatherDbContext).Assembly.FullName)));

        // Register repositories
        services.AddScoped<IStockRepository, StockRepository>();
        services.AddScoped<IWeatherRepository, WeatherRepository>();

        // Register services
        services.AddSingleton<IJobStatusService, JobStatusService>();
        services.AddScoped<IStockLoaderService, StockLoaderService>();
        services.AddScoped<IWeatherLoaderService, WeatherLoaderService>();

        // Add Redis for distributed caching and job status tracking
        services.AddStackExchangeRedisCache(options =>
        {
            options.Configuration = configuration.GetConnectionString("Redis");
            options.InstanceName = "BackgroundProcessing:";
        });

        return services;
    }
}
