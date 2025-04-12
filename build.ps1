# Setup-BackgroundProcessingSystem.ps1
# This script creates a full .NET Core 9 solution for background processing on OpenShift
# It creates the projects, references, and injects all the necessary code

# Configuration
$solutionName = "slimbgprocessor"
$netVersion = "net9.0"

# Create root directory
$rootDir = $PSScriptRoot
if (!(Test-Path $rootDir)) {
    $rootDir = New-Item -ItemType Directory -Path "./$solutionName" -Force
}
Set-Location $rootDir

Write-Host "Setting up $solutionName in $rootDir" -ForegroundColor Green

# Create solution
Write-Host "Creating solution..." -ForegroundColor Cyan
dotnet new sln -n $solutionName

# Create directories
Write-Host "Creating directory structure..." -ForegroundColor Cyan
$srcDir = New-Item -ItemType Directory -Path "./src" -Force
$testsDir = New-Item -ItemType Directory -Path "./tests" -Force
$openshiftDir = New-Item -ItemType Directory -Path "./openshift" -Force

# Create Core project
Write-Host "Creating Core project..." -ForegroundColor Cyan
$coreDir = New-Item -ItemType Directory -Path "$srcDir/BackgroundProcessing.Core" -Force
dotnet new classlib -n BackgroundProcessing.Core -o $coreDir -f $netVersion
dotnet sln add "$coreDir/BackgroundProcessing.Core.csproj"

# Create Infrastructure project
Write-Host "Creating Infrastructure project..." -ForegroundColor Cyan
$infraDir = New-Item -ItemType Directory -Path "$srcDir/BackgroundProcessing.Infrastructure" -Force
dotnet new classlib -n BackgroundProcessing.Infrastructure -o $infraDir -f $netVersion
dotnet sln add "$infraDir/BackgroundProcessing.Infrastructure.csproj"

# Create API project
Write-Host "Creating API project..." -ForegroundColor Cyan
$apiDir = New-Item -ItemType Directory -Path "$srcDir/BackgroundProcessing.API" -Force
dotnet new webapi -n BackgroundProcessing.API -o $apiDir -f $netVersion
dotnet sln add "$apiDir/BackgroundProcessing.API.csproj"

# Create StockLoader project
Write-Host "Creating StockLoader project..." -ForegroundColor Cyan
$stockDir = New-Item -ItemType Directory -Path "$srcDir/BackgroundProcessing.StockLoader" -Force
dotnet new webapi -n BackgroundProcessing.StockLoader -o $stockDir -f $netVersion
dotnet sln add "$stockDir/BackgroundProcessing.StockLoader.csproj"

# Create WeatherLoader project
Write-Host "Creating WeatherLoader project..." -ForegroundColor Cyan
$weatherDir = New-Item -ItemType Directory -Path "$srcDir/BackgroundProcessing.WeatherLoader" -Force
dotnet new webapi -n BackgroundProcessing.WeatherLoader -o $weatherDir -f $netVersion
dotnet sln add "$weatherDir/BackgroundProcessing.WeatherLoader.csproj"

# Add project references
Write-Host "Adding project references..." -ForegroundColor Cyan
dotnet add "$infraDir/BackgroundProcessing.Infrastructure.csproj" reference "$coreDir/BackgroundProcessing.Core.csproj"
dotnet add "$apiDir/BackgroundProcessing.API.csproj" reference "$coreDir/BackgroundProcessing.Core.csproj"
dotnet add "$apiDir/BackgroundProcessing.API.csproj" reference "$infraDir/BackgroundProcessing.Infrastructure.csproj"
dotnet add "$stockDir/BackgroundProcessing.StockLoader.csproj" reference "$coreDir/BackgroundProcessing.Core.csproj"
dotnet add "$stockDir/BackgroundProcessing.StockLoader.csproj" reference "$infraDir/BackgroundProcessing.Infrastructure.csproj"
dotnet add "$weatherDir/BackgroundProcessing.WeatherLoader.csproj" reference "$coreDir/BackgroundProcessing.Core.csproj"
dotnet add "$weatherDir/BackgroundProcessing.WeatherLoader.csproj" reference "$infraDir/BackgroundProcessing.Infrastructure.csproj"

# Create test projects
Write-Host "Creating test projects..." -ForegroundColor Cyan
$coreTestDir = New-Item -ItemType Directory -Path "$testsDir/BackgroundProcessing.Core.Tests" -Force
dotnet new xunit -n BackgroundProcessing.Core.Tests -o $coreTestDir -f $netVersion
dotnet sln add "$coreTestDir/BackgroundProcessing.Core.Tests.csproj"
dotnet add "$coreTestDir/BackgroundProcessing.Core.Tests.csproj" reference "$coreDir/BackgroundProcessing.Core.csproj"

$apiTestDir = New-Item -ItemType Directory -Path "$testsDir/BackgroundProcessing.API.Tests" -Force
dotnet new xunit -n BackgroundProcessing.API.Tests -o $apiTestDir -f $netVersion
dotnet sln add "$apiTestDir/BackgroundProcessing.API.Tests.csproj"
dotnet add "$apiTestDir/BackgroundProcessing.API.Tests.csproj" reference "$apiDir/BackgroundProcessing.API.csproj"

$stockTestDir = New-Item -ItemType Directory -Path "$testsDir/BackgroundProcessing.StockLoader.Tests" -Force
dotnet new xunit -n BackgroundProcessing.StockLoader.Tests -o $stockTestDir -f $netVersion
dotnet sln add "$stockTestDir/BackgroundProcessing.StockLoader.Tests.csproj"
dotnet add "$stockTestDir/BackgroundProcessing.StockLoader.Tests.csproj" reference "$stockDir/BackgroundProcessing.StockLoader.csproj"

$weatherTestDir = New-Item -ItemType Directory -Path "$testsDir/BackgroundProcessing.WeatherLoader.Tests" -Force
dotnet new xunit -n BackgroundProcessing.WeatherLoader.Tests -o $weatherTestDir -f $netVersion
dotnet sln add "$weatherTestDir/BackgroundProcessing.WeatherLoader.Tests.csproj"
dotnet add "$weatherTestDir/BackgroundProcessing.WeatherLoader.Tests.csproj" reference "$weatherDir/BackgroundProcessing.WeatherLoader.csproj"

# Add NuGet packages
Write-Host "Adding NuGet packages..." -ForegroundColor Cyan
# Core packages
dotnet add "$coreDir/BackgroundProcessing.Core.csproj" package Microsoft.Extensions.Logging.Abstractions

# Infrastructure packages
dotnet add "$infraDir/BackgroundProcessing.Infrastructure.csproj" package Microsoft.EntityFrameworkCore.SqlServer
dotnet add "$infraDir/BackgroundProcessing.Infrastructure.csproj" package Microsoft.Extensions.Caching.StackExchangeRedis
dotnet add "$infraDir/BackgroundProcessing.Infrastructure.csproj" package Microsoft.Extensions.Http
dotnet add "$infraDir/BackgroundProcessing.Infrastructure.csproj" package Microsoft.Extensions.Options.ConfigurationExtensions

# API packages
dotnet add "$apiDir/BackgroundProcessing.API.csproj" package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add "$apiDir/BackgroundProcessing.API.csproj" package Swashbuckle.AspNetCore

# StockLoader packages
dotnet add "$stockDir/BackgroundProcessing.StockLoader.csproj" package Microsoft.Extensions.Http
dotnet add "$stockDir/BackgroundProcessing.StockLoader.csproj" package Swashbuckle.AspNetCore

# WeatherLoader packages
dotnet add "$weatherDir/BackgroundProcessing.WeatherLoader.csproj" package Microsoft.Extensions.Http
dotnet add "$weatherDir/BackgroundProcessing.WeatherLoader.csproj" package Swashbuckle.AspNetCore

# Create directories for each project
Write-Host "Creating project directories..." -ForegroundColor Cyan

# API project directories
New-Item -ItemType Directory -Path "$apiDir/Configuration" -Force
New-Item -ItemType Directory -Path "$apiDir/Endpoints" -Force
New-Item -ItemType Directory -Path "$apiDir/Models" -Force

# Core project directories
New-Item -ItemType Directory -Path "$coreDir/Models" -Force
New-Item -ItemType Directory -Path "$coreDir/Services" -Force
New-Item -ItemType Directory -Path "$coreDir/Repositories" -Force
New-Item -ItemType Directory -Path "$coreDir/Exceptions" -Force

# Infrastructure project directories
New-Item -ItemType Directory -Path "$infraDir/Persistence" -Force
New-Item -ItemType Directory -Path "$infraDir/Repositories" -Force
New-Item -ItemType Directory -Path "$infraDir/Services" -Force

# StockLoader project directories
New-Item -ItemType Directory -Path "$stockDir/Configuration" -Force
New-Item -ItemType Directory -Path "$stockDir/Endpoints" -Force
New-Item -ItemType Directory -Path "$stockDir/Services" -Force

# WeatherLoader project directories
New-Item -ItemType Directory -Path "$weatherDir/Configuration" -Force
New-Item -ItemType Directory -Path "$weatherDir/Endpoints" -Force
New-Item -ItemType Directory -Path "$weatherDir/Services" -Force

# Now let's create each file with its content
Write-Host "Creating source files..." -ForegroundColor Cyan

# CORE FILES

# JobResponse.cs
@'
namespace BackgroundProcessing.Core.Models;

public class JobResponse
{
    public string JobId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}
'@ | Out-File -FilePath "$coreDir/Models/JobResponse.cs" -Encoding utf8

# JobStatusResponse.cs
@'
namespace BackgroundProcessing.Core.Models;

public class JobStatusResponse
{
    public string JobId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public string? ErrorMessage { get; set; }
    public Dictionary<string, string> Metadata { get; set; } = new();
}
'@ | Out-File -FilePath "$coreDir/Models/JobStatusResponse.cs" -Encoding utf8

# StockData.cs
@'
namespace BackgroundProcessing.Core.Models;

public class StockData
{
    public string Symbol { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public decimal Change { get; set; }
    public decimal PercentChange { get; set; }
    public long Volume { get; set; }
    public DateTime Timestamp { get; set; }
}
'@ | Out-File -FilePath "$coreDir/Models/StockData.cs" -Encoding utf8

# WeatherData.cs
@'
namespace BackgroundProcessing.Core.Models;

public class WeatherData
{
    public string Location { get; set; } = string.Empty;
    public string Condition { get; set; } = string.Empty;
    public double Temperature { get; set; }
    public double FeelsLike { get; set; }
    public int Humidity { get; set; }
    public double WindSpeed { get; set; }
    public DateTime Timestamp { get; set; }
}
'@ | Out-File -FilePath "$coreDir/Models/WeatherData.cs" -Encoding utf8

# IStockLoaderService.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Services;

public interface IStockLoaderService
{
    Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$coreDir/Services/IStockLoaderService.cs" -Encoding utf8

# IWeatherLoaderService.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Services;

public interface IWeatherLoaderService
{
    Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$coreDir/Services/IWeatherLoaderService.cs" -Encoding utf8

# IJobStatusService.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Services;

public interface IJobStatusService
{
    Task<JobStatusResponse?> GetJobStatusAsync(string jobId, CancellationToken cancellationToken = default);
    Task UpdateJobStatusAsync(JobStatusResponse status, CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$coreDir/Services/IJobStatusService.cs" -Encoding utf8

# IStockRepository.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Repositories;

public interface IStockRepository
{
    Task SaveStockDataAsync(IEnumerable<StockData> stockData, CancellationToken cancellationToken = default);
    Task<IEnumerable<StockData>> GetLatestStockDataAsync(string symbol, CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$coreDir/Repositories/IStockRepository.cs" -Encoding utf8

# IWeatherRepository.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Repositories;

public interface IWeatherRepository
{
    Task SaveWeatherDataAsync(IEnumerable<WeatherData> weatherData, CancellationToken cancellationToken = default);
    Task<IEnumerable<WeatherData>> GetLatestWeatherDataAsync(string location, CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$coreDir/Repositories/IWeatherRepository.cs" -Encoding utf8

# ProcessingException.cs
@'
namespace BackgroundProcessing.Core.Exceptions;

public class ProcessingException : Exception
{
    public ProcessingException(string message) : base(message)
    {
    }

    public ProcessingException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
'@ | Out-File -FilePath "$coreDir/Exceptions/ProcessingException.cs" -Encoding utf8

# INFRASTRUCTURE FILES

# InfrastructureServiceRegistration.cs
@'
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
'@ | Out-File -FilePath "$infraDir/InfrastructureServiceRegistration.cs" -Encoding utf8

# StockDbContext.cs
@'
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
'@ | Out-File -FilePath "$infraDir/Persistence/StockDbContext.cs" -Encoding utf8

# WeatherDbContext.cs
@'
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
'@ | Out-File -FilePath "$infraDir/Persistence/WeatherDbContext.cs" -Encoding utf8

# StockRepository.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BackgroundProcessing.Infrastructure.Repositories;

public class StockRepository : IStockRepository
{
    private readonly StockDbContext _dbContext;
    private readonly ILogger<StockRepository> _logger;

    public StockRepository(StockDbContext dbContext, ILogger<StockRepository> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task SaveStockDataAsync(IEnumerable<StockData> stockData, CancellationToken cancellationToken = default)
    {
        try
        {
            await _dbContext.StockData.AddRangeAsync(stockData, cancellationToken);
            await _dbContext.SaveChangesAsync(cancellationToken);
            _logger.LogInformation("Successfully saved {Count} stock data records", stockData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving stock data");
            throw;
        }
    }

    public async Task<IEnumerable<StockData>> GetLatestStockDataAsync(string symbol, CancellationToken cancellationToken = default)
    {
        return await _dbContext.StockData
            .Where(s => s.Symbol == symbol)
            .OrderByDescending(s => s.Timestamp)
            .Take(100)
            .ToListAsync(cancellationToken);
    }
}
'@ | Out-File -FilePath "$infraDir/Repositories/StockRepository.cs" -Encoding utf8

# WeatherRepository.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BackgroundProcessing.Infrastructure.Repositories;

public class WeatherRepository : IWeatherRepository
{
    private readonly WeatherDbContext _dbContext;
    private readonly ILogger<WeatherRepository> _logger;

    public WeatherRepository(WeatherDbContext dbContext, ILogger<WeatherRepository> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task SaveWeatherDataAsync(IEnumerable<WeatherData> weatherData, CancellationToken cancellationToken = default)
    {
        try
        {
            await _dbContext.WeatherData.AddRangeAsync(weatherData, cancellationToken);
            await _dbContext.SaveChangesAsync(cancellationToken);
            _logger.LogInformation("Successfully saved {Count} weather data records", weatherData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving weather data");
            throw;
        }
    }

    public async Task<IEnumerable<WeatherData>> GetLatestWeatherDataAsync(string location, CancellationToken cancellationToken = default)
    {
        return await _dbContext.WeatherData
            .Where(w => w.Location == location)
            .OrderByDescending(w => w.Timestamp)
            .Take(100)
            .ToListAsync(cancellationToken);
    }
}
'@ | Out-File -FilePath "$infraDir/Repositories/WeatherRepository.cs" -Encoding utf8

# JobStatusService.cs
@'
using System.Text.Json;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Logging;

namespace BackgroundProcessing.Infrastructure.Services;

public class JobStatusService : IJobStatusService
{
    private readonly IDistributedCache _cache;
    private readonly ILogger<JobStatusService> _logger;
    private readonly JsonSerializerOptions _jsonOptions = new() 
    { 
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase 
    };

    public JobStatusService(IDistributedCache cache, ILogger<JobStatusService> logger)
    {
        _cache = cache;
        _logger = logger;
    }

    public async Task<JobStatusResponse?> GetJobStatusAsync(string jobId, CancellationToken cancellationToken = default)
    {
        try
        {
            var cacheKey = $"job:{jobId}";
            var cachedStatus = await _cache.GetStringAsync(cacheKey, cancellationToken);
            
            if (string.IsNullOrEmpty(cachedStatus))
            {
                return null;
            }
            
            return JsonSerializer.Deserialize<JobStatusResponse>(cachedStatus, _jsonOptions);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving job status for job {JobId}", jobId);
            return null;
        }
    }

    public async Task UpdateJobStatusAsync(JobStatusResponse status, CancellationToken cancellationToken = default)
    {
        try
        {
            var cacheKey = $"job:{status.JobId}";
            var serializedStatus = JsonSerializer.Serialize(status, _jsonOptions);
            
            // Set cache options - keep job status for 24 hours
            var cacheOptions = new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            };
            
            await _cache.SetStringAsync(cacheKey, serializedStatus, cacheOptions, cancellationToken);
            
            _logger.LogInformation("Updated status for job {JobId} to {Status}", status.JobId, status.Status);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating job status for job {JobId}", status.JobId);
            throw;
        }
    }
}
'@ | Out-File -FilePath "$infraDir/Services/JobStatusService.cs" -Encoding utf8

# StockLoaderService.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.Extensions.Logging;
using System.Net.Http.Json;

namespace BackgroundProcessing.Infrastructure.Services;

public class StockLoaderService : IStockLoaderService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<StockLoaderService> _logger;

    public StockLoaderService(HttpClient httpClient, ILogger<StockLoaderService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await _httpClient.PostAsync("/api/process", null, cancellationToken);
            response.EnsureSuccessStatusCode();
            
            var result = await response.Content.ReadFromJsonAsync<JobResponse>(cancellationToken: cancellationToken);
            
            if (result == null)
            {
                throw new InvalidOperationException("Failed to deserialize job response");
            }
            
            _logger.LogInformation("Successfully triggered stock loader job: {JobId}", result.JobId);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error triggering stock loader process");
            throw;
        }
    }
}
'@ | Out-File -FilePath "$infraDir/Services/StockLoaderService.cs" -Encoding utf8

# WeatherLoaderService.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.Extensions.Logging;
using System.Net.Http.Json;

namespace BackgroundProcessing.Infrastructure.Services;

public class WeatherLoaderService : IWeatherLoaderService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<WeatherLoaderService> _logger;

    public WeatherLoaderService(HttpClient httpClient, ILogger<WeatherLoaderService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await _httpClient.PostAsync("/api/process", null, cancellationToken);
            response.EnsureSuccessStatusCode();
            
            var result = await response.Content.ReadFromJsonAsync<JobResponse>(cancellationToken: cancellationToken);
            
            if (result == null)
            {
                throw new InvalidOperationException("Failed to deserialize job response");
            }
            
            _logger.LogInformation("Successfully triggered weather loader job: {JobId}", result.JobId);
            
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error triggering weather loader process");
            throw;
        }
    }
}
'@ | Out-File -FilePath "$infraDir/Services/WeatherLoaderService.cs" -Encoding utf8

# API FILES

# JobTriggerRequest.cs
@'
namespace BackgroundProcessing.API.Models;

public class JobTriggerRequest
{
    /// <summary>
    /// The job key GUID used to authorize the trigger request
    /// </summary>
    public Guid JobKey { get; set; }
    
    /// <summary>
    /// Optional parameters for the job
    /// </summary>
    public Dictionary<string, string>? Parameters { get; set; }
}
'@ | Out-File -FilePath "$apiDir/Models/JobTriggerRequest.cs" -Encoding utf8

# JobKeyOptions.cs
@'
namespace BackgroundProcessing.API.Configuration;

public class JobKeyOptions
{
    public const string SectionName = "JobKeys";
    
    /// <summary>
    /// The unique key to authorize Stock Loader job triggers
    /// </summary>
    public Guid StockLoaderKey { get; set; }
    
    /// <summary>
    /// The unique key to authorize Weather Loader job triggers
    /// </summary>
    public Guid WeatherLoaderKey { get; set; }
}
'@ | Out-File -FilePath "$apiDir/Configuration/JobKeyOptions.cs" -Encoding utf8

# ApiHealthCheck.cs
@'
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace BackgroundProcessing.API.Configuration;

public class ApiHealthCheck : IHealthCheck
{
    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // Add more sophisticated health checks as needed
        return Task.FromResult(HealthCheckResult.Healthy("API is healthy"));
    }
}
'@ | Out-File -FilePath "$apiDir/Configuration/ApiHealthCheck.cs" -Encoding utf8

# Program.cs
@'
using BackgroundProcessing.API.Configuration;
using BackgroundProcessing.API.Endpoints;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.Infrastructure;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { 
        Title = "Background Processing API", 
        Version = "v1",
        Description = "API for triggering background processes"
    });
});

// Add Infrastructure services
builder.Services.AddInfrastructureServices(builder.Configuration);

// Add configuration
builder.Services.Configure<JobKeyOptions>(
    builder.Configuration.GetSection(JobKeyOptions.SectionName));

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Add health checks
builder.Services.AddHealthChecks()
    .AddCheck<ApiHealthCheck>("api_health_check");

// Add authentication
builder.Services.AddAuthentication()
    .AddJwtBearer();
builder.Services.AddAuthorization();

// Add background services client
builder.Services.AddHttpClient<IStockLoaderService, StockLoaderService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Services:StockLoader:BaseUrl"]);
});

builder.Services.AddHttpClient<IWeatherLoaderService, WeatherLoaderService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["Services:WeatherLoader:BaseUrl"]);
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

// Register endpoint groups
app.MapGroup("/api/v1/jobs")
    .MapJobEndpoints()
    .RequireAuthorization()
    .WithTags("Jobs");

// Map health checks
app.MapHealthChecks("/health");

app.Run();
'@ | Out-File -FilePath "$apiDir/Program.cs" -Encoding utf8

# JobEndpoints.cs
@'
using BackgroundProcessing.API.Models;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Services;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.API.Endpoints;

public static class JobEndpoints
{
    public static RouteGroupBuilder MapJobEndpoints(this RouteGroupBuilder group)
    {
        group.MapPost("/stock/trigger", TriggerStockLoader)
            .WithName("TriggerStockLoader")
            .WithOpenApi(operation => 
            {
                operation.Summary = "Triggers the stock loader process";
                operation.Description = "Requires a valid job key GUID in the request body to authorize the trigger";
                return operation;
            });

        group.MapPost("/weather/trigger", TriggerWeatherLoader)
            .WithName("TriggerWeatherLoader")
            .WithOpenApi(operation => 
            {
                operation.Summary = "Triggers the weather loader process";
                operation.Description = "Requires a valid job key GUID in the request body to authorize the trigger";
                return operation;
            });

        group.MapGet("/status/{jobId}", GetJobStatus)
            .WithName("GetJobStatus")
            .WithOpenApi(operation => 
            {
                operation.Summary = "Gets the status of a job by ID";
                return operation;
            });

        return group;
    }

    private static async Task<Results<Ok<JobResponse>, BadRequest<string>, UnauthorizedHttpResult>> TriggerStockLoader(
        JobTriggerRequest request,
        IStockLoaderService stockLoaderService,
        IOptions<JobKeyOptions> jobKeyOptions,
        ILogger<JobEndpoints> logger,
        CancellationToken cancellationToken)
    {
        // Validate the job key GUID
        if (!IsValidJobKey(request.JobKey, "StockLoader", jobKeyOptions.Value))
        {
            logger.LogWarning("Unauthorized attempt to trigger stock loader job with invalid key: {JobKey}", request.JobKey);
            return TypedResults.Unauthorized();
        }
        
        logger.LogInformation("Triggering stock loader job with authorized key");
        
        try
        {
            var result = await stockLoaderService.TriggerProcessAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = result.JobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error triggering stock loader job");
            return TypedResults.BadRequest("Failed to trigger stock loader job");
        }
    }

    private static async Task<Results<Ok<JobResponse>, BadRequest<string>, UnauthorizedHttpResult>> TriggerWeatherLoader(
        JobTriggerRequest request,
        IWeatherLoaderService weatherLoaderService,
        IOptions<JobKeyOptions> jobKeyOptions,
        ILogger<JobEndpoints> logger,
        CancellationToken cancellationToken)
    {
        // Validate the job key GUID
        if (!IsValidJobKey(request.JobKey, "WeatherLoader", jobKeyOptions.Value))
        {
            logger.LogWarning("Unauthorized attempt to trigger weather loader job with invalid key: {JobKey}", request.JobKey);
            return TypedResults.Unauthorized();
        }
        
        logger.LogInformation("Triggering weather loader job with authorized key");
        
        try
        {
            var result = await weatherLoaderService.TriggerProcessAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = result.JobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error triggering weather loader job");
            return TypedResults.BadRequest("Failed to trigger weather loader job");
        }
    }

    private static async Task<Results<Ok<JobStatusResponse>, NotFound>> GetJobStatus(
        string jobId,
        IJobStatusService jobStatusService,
        CancellationToken cancellationToken)
    {
        var status = await jobStatusService.GetJobStatusAsync(jobId, cancellationToken);
        
        if (status == null)
        {
            return TypedResults.NotFound();
        }
        
        return TypedResults.Ok(status);
    }
    
    private static bool IsValidJobKey(Guid jobKey, string jobType, JobKeyOptions options)
    {
        return jobType switch
        {
            "StockLoader" => jobKey == options.StockLoaderKey,
            "WeatherLoader" => jobKey == options.WeatherLoaderKey,
            _ => false
        };
    }
}
'@ | Out-File -FilePath "$apiDir/Endpoints/JobEndpoints.cs" -Encoding utf8

# appsettings.json
@'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Services": {
    "StockLoader": {
      "BaseUrl": "http://stockloader-service:8080"
    },
    "WeatherLoader": {
      "BaseUrl": "http://weatherloader-service:8080"
    }
  },
  "Authentication": {
    "Schemes": {
      "Bearer": {
        "ValidAudiences": ["background-processing-api"],
        "ValidIssuer": "background-processing-authority"
      }
    }
  },
  "JobKeys": {
    "StockLoaderKey": "11111111-1111-1111-1111-111111111111",
    "WeatherLoaderKey": "22222222-2222-2222-2222-222222222222"
  }
}
'@ | Out-File -FilePath "$apiDir/appsettings.json" -Encoding utf8

# STOCK LOADER FILES

# StockLoaderOptions.cs
@'
namespace BackgroundProcessing.StockLoader.Configuration;

public class StockLoaderOptions
{
    public string[] Symbols { get; set; } = Array.Empty<string>();
    public string ApiKey { get; set; } = string.Empty;
    public string ApiBaseUrl { get; set; } = string.Empty;
    public int PollingIntervalSeconds { get; set; } = 60;
}
'@ | Out-File -FilePath "$stockDir/Configuration/StockLoaderOptions.cs" -Encoding utf8

# StockLoaderHealthCheck.cs
@'
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Configuration;

public class StockLoaderHealthCheck : IHealthCheck
{
    private readonly IOptions<StockLoaderOptions> _options;

    public StockLoaderHealthCheck(IOptions<StockLoaderOptions> options)
    {
        _options = options;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // Check if configuration is valid
        if (string.IsNullOrEmpty(_options.Value.ApiKey) || string.IsNullOrEmpty(_options.Value.ApiBaseUrl))
        {
            return Task.FromResult(HealthCheckResult.Degraded("Stock Loader API configuration is incomplete"));
        }

        if (_options.Value.Symbols.Length == 0)
        {
            return Task.FromResult(HealthCheckResult.Degraded("No stock symbols configured"));
        }

        return Task.FromResult(HealthCheckResult.Healthy("Stock Loader is healthy"));
    }
}
'@ | Out-File -FilePath "$stockDir/Configuration/StockLoaderHealthCheck.cs" -Encoding utf8

# StockLoaderEndpoints.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.StockLoader.Services;
using Microsoft.AspNetCore.Http.HttpResults;

namespace BackgroundProcessing.StockLoader.Endpoints;

public static class StockLoaderEndpoints
{
    public static RouteGroupBuilder MapStockLoaderEndpoints(this RouteGroupBuilder group)
    {
        group.MapPost("/process", ProcessStocks)
            .WithName("ProcessStocks")
            .WithOpenApi(operation => 
            {
                operation.Summary = "Triggers the stock loading process";
                return operation;
            });

        return group;
    }

    private static async Task<Results<Ok<JobResponse>, BadRequest<string>>> ProcessStocks(
        IStockProcessorService processorService,
        ILogger<StockLoaderEndpoints> logger,
        CancellationToken cancellationToken)
    {
        logger.LogInformation("Manual trigger of stock processing received");
        
        try
        {
            var jobId = await processorService.ProcessStocksAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = jobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error processing stocks");
            return TypedResults.BadRequest("Failed to process stocks: " + ex.Message);
        }
    }
}
'@ | Out-File -FilePath "$stockDir/Endpoints/StockLoaderEndpoints.cs" -Encoding utf8

# IStockDataService.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.StockLoader.Services;

public interface IStockDataService
{
    Task<IEnumerable<StockData>> FetchStockDataAsync(IEnumerable<string> symbols, CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$stockDir/Services/IStockDataService.cs" -Encoding utf8

# IStockProcessorService.cs
@'
namespace BackgroundProcessing.StockLoader.Services;

public interface IStockProcessorService
{
    Task<string> ProcessStocksAsync(CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$stockDir/Services/IStockProcessorService.cs" -Encoding utf8

# StockDataService.cs
@'
using System.Net.Http.Json;
using BackgroundProcessing.Core.Exceptions;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.StockLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Services;

public class StockDataService : IStockDataService
{
    private readonly HttpClient _httpClient;
    private readonly IOptions<StockLoaderOptions> _options;
    private readonly ILogger<StockDataService> _logger;

    public StockDataService(
        HttpClient httpClient,
        IOptions<StockLoaderOptions> options,
        ILogger<StockDataService> logger)
    {
        _httpClient = httpClient;
        _options = options;
        _logger = logger;
        
        // Configure the base URL from options
        _httpClient.BaseAddress = new Uri(_options.Value.ApiBaseUrl);
    }

    public async Task<IEnumerable<StockData>> FetchStockDataAsync(IEnumerable<string> symbols, CancellationToken cancellationToken = default)
    {
        try
        {
            var result = new List<StockData>();
            var symbolList = string.Join(",", symbols);
            
            // Construct API request URL with API key
            var requestUrl = $"/api/v1/stocks?symbols={symbolList}&apiKey={_options.Value.ApiKey}";
            
            _logger.LogInformation("Fetching stock data for symbols: {Symbols}", symbolList);
            
            // Make the API request
            var response = await _httpClient.GetAsync(requestUrl, cancellationToken);
            
            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogError("Stock API returned error status code {StatusCode}: {ErrorContent}", 
                    response.StatusCode, errorContent);
                
                throw new ProcessingException($"Stock API returned error: {response.StatusCode}");
            }
            
            // Parse the response
            var apiResponse = await response.Content.ReadFromJsonAsync<StockApiResponse>(cancellationToken: cancellationToken);
            
            if (apiResponse == null || apiResponse.Data == null)
            {
                throw new ProcessingException("Invalid response from stock API");
            }
            
            return apiResponse.Data;
        }
        catch (Exception ex) when (ex is not ProcessingException)
        {
            _logger.LogError(ex, "Error fetching stock data");
            throw new ProcessingException("Failed to fetch stock data", ex);
        }
    }
    
    // Helper class for API response deserialization
    private class StockApiResponse
    {
        public List<StockData>? Data { get; set; }
    }
}
'@ | Out-File -FilePath "$stockDir/Services/StockDataService.cs" -Encoding utf8

# StockProcessorService.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.StockLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Services;

public class StockProcessorService : IStockProcessorService
{
    private readonly IStockDataService _stockDataService;
    private readonly IStockRepository _stockRepository;
    private readonly IJobStatusService _jobStatusService;
    private readonly IOptions<StockLoaderOptions> _options;
    private readonly ILogger<StockProcessorService> _logger;

    public StockProcessorService(
        IStockDataService stockDataService,
        IStockRepository stockRepository,
        IJobStatusService jobStatusService,
        IOptions<StockLoaderOptions> options,
        ILogger<StockProcessorService> logger)
    {
        _stockDataService = stockDataService;
        _stockRepository = stockRepository;
        _jobStatusService = jobStatusService;
        _options = options;
        _logger = logger;
    }

    public async Task<string> ProcessStocksAsync(CancellationToken cancellationToken = default)
    {
        // Generate a unique job ID
        var jobId = Guid.NewGuid().ToString();
        
        // Create initial job status
        var jobStatus = new JobStatusResponse
        {
            JobId = jobId,
            Status = "Running",
            StartTime = DateTime.UtcNow,
            Metadata = new Dictionary<string, string>
            {
                { "Type", "StockLoader" },
                { "Symbols", string.Join(",", _options.Value.Symbols) }
            }
        };
        
        // Update job status to running
        await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        
        _logger.LogInformation("Starting stock processing job {JobId}", jobId);
        
        try
        {
            // Fetch stock data
            var stockData = await _stockDataService.FetchStockDataAsync(_options.Value.Symbols, cancellationToken);
            
            // Save to database
            await _stockRepository.SaveStockDataAsync(stockData, cancellationToken);
            
            // Update job status to completed
            jobStatus.Status = "Completed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.Metadata.Add("RecordsProcessed", stockData.Count().ToString());
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
            
            _logger.LogInformation("Completed stock processing job {JobId}, processed {Count} records", 
                jobId, stockData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in stock processing job {JobId}", jobId);
            
            // Update job status to failed
            jobStatus.Status = "Failed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.ErrorMessage = ex.Message;
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        }
        
        return jobId;
    }
}
'@ | Out-File -FilePath "$stockDir/Services/StockProcessorService.cs" -Encoding utf8

# StockLoaderBackgroundService.cs
@'
using BackgroundProcessing.StockLoader.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.StockLoader.Services;

public class StockLoaderBackgroundService : BackgroundService
{
    private readonly IStockProcessorService _processorService;
    private readonly IOptions<StockLoaderOptions> _options;
    private readonly ILogger<StockLoaderBackgroundService> _logger;

    public StockLoaderBackgroundService(
        IStockProcessorService processorService,
        IOptions<StockLoaderOptions> options,
        ILogger<StockLoaderBackgroundService> logger)
    {
        _processorService = processorService;
        _options = options;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Stock Loader Background Service is starting");
        
        // Determine polling interval from configuration
        var pollingInterval = TimeSpan.FromSeconds(_options.Value.PollingIntervalSeconds);
        
        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Stock Loader running at: {Time}", DateTimeOffset.Now);
            
            try
            {
                var jobId = await _processorService.ProcessStocksAsync(stoppingToken);
                _logger.LogInformation("Scheduled stock loader job completed: {JobId}", jobId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred during scheduled stock loading");
            }
            
            // Wait for the next polling interval
            await Task.Delay(pollingInterval, stoppingToken);
        }
        
        _logger.LogInformation("Stock Loader Background Service is stopping");
    }
}
'@ | Out-File -FilePath "$stockDir/Services/StockLoaderBackgroundService.cs" -Encoding utf8

# Stock Loader Program.cs
@'
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.Infrastructure;
using BackgroundProcessing.StockLoader.Configuration;
using BackgroundProcessing.StockLoader.Endpoints;
using BackgroundProcessing.StockLoader.Services;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { 
        Title = "Stock Loader API", 
        Version = "v1",
        Description = "API for loading stock data"
    });
});

// Add Infrastructure services
builder.Services.AddInfrastructureServices(builder.Configuration);

// Add StockLoader services
builder.Services.Configure<StockLoaderOptions>(builder.Configuration.GetSection("StockLoader"));
builder.Services.AddHttpClient<IStockDataService, StockDataService>();
builder.Services.AddScoped<IStockProcessorService, StockProcessorService>();
builder.Services.AddHostedService<StockLoaderBackgroundService>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddCheck<StockLoaderHealthCheck>("stock_loader_health_check");

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Register endpoint groups
app.MapGroup("/api")
    .MapStockLoaderEndpoints()
    .WithTags("StockLoader");

// Map health checks
app.MapHealthChecks("/health");

app.Run();
'@ | Out-File -FilePath "$stockDir/Program.cs" -Encoding utf8

# Stock Loader appsettings.json
@'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "StockDatabase": "Server=localhost;Database=StockDb;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True",
    "Redis": "localhost:6379"
  },
  "StockLoader": {
    "Symbols": ["MSFT", "AAPL", "GOOGL", "AMZN", "META"],
    "ApiKey": "your-api-key-here",
    "ApiBaseUrl": "https://api.example.com",
    "PollingIntervalSeconds": 3600
  }
}
'@ | Out-File -FilePath "$stockDir/appsettings.json" -Encoding utf8

# WEATHER LOADER FILES

# WeatherLoaderOptions.cs
@'
namespace BackgroundProcessing.WeatherLoader.Configuration;

public class WeatherLoaderOptions
{
    public string[] Locations { get; set; } = Array.Empty<string>();
    public string ApiKey { get; set; } = string.Empty;
    public string ApiBaseUrl { get; set; } = string.Empty;
    public int PollingIntervalSeconds { get; set; } = 900; // 15 minutes
}
'@ | Out-File -FilePath "$weatherDir/Configuration/WeatherLoaderOptions.cs" -Encoding utf8

# WeatherLoaderHealthCheck.cs
@'
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Configuration;

public class WeatherLoaderHealthCheck : IHealthCheck
{
    private readonly IOptions<WeatherLoaderOptions> _options;

    public WeatherLoaderHealthCheck(IOptions<WeatherLoaderOptions> options)
    {
        _options = options;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        // Check if configuration is valid
        if (string.IsNullOrEmpty(_options.Value.ApiKey) || string.IsNullOrEmpty(_options.Value.ApiBaseUrl))
        {
            return Task.FromResult(HealthCheckResult.Degraded("Weather Loader API configuration is incomplete"));
        }

        if (_options.Value.Locations.Length == 0)
        {
            return Task.FromResult(HealthCheckResult.Degraded("No weather locations configured"));
        }

        return Task.FromResult(HealthCheckResult.Healthy("Weather Loader is healthy"));
    }
}
'@ | Out-File -FilePath "$weatherDir/Configuration/WeatherLoaderHealthCheck.cs" -Encoding utf8

# WeatherLoaderEndpoints.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.WeatherLoader.Services;
using Microsoft.AspNetCore.Http.HttpResults;

namespace BackgroundProcessing.WeatherLoader.Endpoints;

public static class WeatherLoaderEndpoints
{
    public static RouteGroupBuilder MapWeatherLoaderEndpoints(this RouteGroupBuilder group)
    {
        group.MapPost("/process", ProcessWeather)
            .WithName("ProcessWeather")
            .WithOpenApi(operation => 
            {
                operation.Summary = "Triggers the weather loading process";
                return operation;
            });

        return group;
    }

    private static async Task<Results<Ok<JobResponse>, BadRequest<string>>> ProcessWeather(
        IWeatherProcessorService processorService,
        ILogger<WeatherLoaderEndpoints> logger,
        CancellationToken cancellationToken)
    {
        logger.LogInformation("Manual trigger of weather processing received");
        
        try
        {
            var jobId = await processorService.ProcessWeatherAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = jobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error processing weather");
            return TypedResults.BadRequest("Failed to process weather: " + ex.Message);
        }
    }
}
'@ | Out-File -FilePath "$weatherDir/Endpoints/WeatherLoaderEndpoints.cs" -Encoding utf8

# IWeatherDataService.cs
@'
using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.WeatherLoader.Services;

public interface IWeatherDataService
{
    Task<IEnumerable<WeatherData>> FetchWeatherDataAsync(IEnumerable<string> locations, CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$weatherDir/Services/IWeatherDataService.cs" -Encoding utf8

# IWeatherProcessorService.cs
@'
namespace BackgroundProcessing.WeatherLoader.Services;

public interface IWeatherProcessorService
{
    Task<string> ProcessWeatherAsync(CancellationToken cancellationToken = default);
}
'@ | Out-File -FilePath "$weatherDir/Services/IWeatherProcessorService.cs" -Encoding utf8

# WeatherDataService.cs
@'
using System.Net.Http.Json;
using BackgroundProcessing.Core.Exceptions;
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.WeatherLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Services;

public class WeatherDataService : IWeatherDataService
{
    private readonly HttpClient _httpClient;
    private readonly IOptions<WeatherLoaderOptions> _options;
    private readonly ILogger<WeatherDataService> _logger;

    public WeatherDataService(
        HttpClient httpClient,
        IOptions<WeatherLoaderOptions> options,
        ILogger<WeatherDataService> logger)
    {
        _httpClient = httpClient;
        _options = options;
        _logger = logger;
        
        // Configure the base URL from options
        _httpClient.BaseAddress = new Uri(_options.Value.ApiBaseUrl);
    }

    public async Task<IEnumerable<WeatherData>> FetchWeatherDataAsync(IEnumerable<string> locations, CancellationToken cancellationToken = default)
    {
        try
        {
            var result = new List<WeatherData>();
            
            foreach (var location in locations)
            {
                // Construct API request URL with API key
                var requestUrl = $"/api/v1/weather?location={Uri.EscapeDataString(location)}&apiKey={_options.Value.ApiKey}";
                
                _logger.LogInformation("Fetching weather data for location: {Location}", location);
                
                // Make the API request
                var response = await _httpClient.GetAsync(requestUrl, cancellationToken);
                
                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
                    _logger.LogError("Weather API returned error status code {StatusCode} for location {Location}: {ErrorContent}", 
                        response.StatusCode, location, errorContent);
                    
                    continue; // Skip this location but continue with others
                }
                
                // Parse the response
                var weatherData = await response.Content.ReadFromJsonAsync<WeatherData>(cancellationToken: cancellationToken);
                
                if (weatherData != null)
                {
                    result.Add(weatherData);
                }
                else
                {
                    _logger.LogWarning("Received null weather data for location {Location}", location);
                }
            }
            
            if (!result.Any())
            {
                throw new ProcessingException("Failed to retrieve weather data for any location");
            }
            
            return result;
        }
        catch (Exception ex) when (ex is not ProcessingException)
        {
            _logger.LogError(ex, "Error fetching weather data");
            throw new ProcessingException("Failed to fetch weather data", ex);
        }
    }
}
'@ | Out-File -FilePath "$weatherDir/Services/WeatherDataService.cs" -Encoding utf8

# WeatherProcessorService.cs
@'
using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.WeatherLoader.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BackgroundProcessing.WeatherLoader.Services;

public class WeatherProcessorService : IWeatherProcessorService
{
    private readonly IWeatherDataService _weatherDataService;
    private readonly IWeatherRepository _weatherRepository;
    private readonly IJobStatusService _jobStatusService;
    private readonly IOptions<WeatherLoaderOptions> _options;
    private readonly ILogger<WeatherProcessorService> _logger;

    public WeatherProcessorService(
        IWeatherDataService weatherDataService,
        IWeatherRepository weatherRepository,
        IJobStatusService jobStatusService,
        IOptions<WeatherLoaderOptions> options,
        ILogger<WeatherProcessorService> logger)
    {
        _weatherDataService = weatherDataService;
        _weatherRepository = weatherRepository;
        _jobStatusService = jobStatusService;
        _options = options;
        _logger = logger;
    }

    public async Task<string> ProcessWeatherAsync(CancellationToken cancellationToken = default)
    {
        // Generate a unique job ID
        var jobId = Guid.NewGuid().ToString();
        
        // Create initial job status
        var jobStatus = new JobStatusResponse
        {
            JobId = jobId,
            Status = "Running",
            StartTime = DateTime.UtcNow,
            Metadata = new Dictionary<string, string>
            {
                { "Type", "WeatherLoader" },
                { "Locations", string.Join(",", _options.Value.Locations) }
            }
        };
        
        // Update job status to running
        await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        
        _logger.LogInformation("Starting weather processing job {JobId}", jobId);
        
        try
        {
            // Fetch weather data
            var weatherData = await _weatherDataService.FetchWeatherDataAsync(_options.Value.Locations, cancellationToken);
            
            // Save to database
            await _weatherRepository.SaveWeatherDataAsync(weatherData, cancellationToken);
            
            // Update job status to completed
            jobStatus.Status = "Completed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.Metadata.Add("RecordsProcessed", weatherData.Count().ToString());
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
            
            _logger.LogInformation("Completed weather processing job {JobId}, processed {Count} records", 
                jobId, weatherData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in weather processing job {JobId}", jobId);
            
            // Update job status to failed
            jobStatus.Status = "Failed";
            jobStatus.EndTime = DateTime.UtcNow;
            jobStatus.ErrorMessage = ex.Message;
            
            await _jobStatusService.UpdateJobStatusAsync(jobStatus, cancellationToken);
        }
        
        return jobId;
    }
}
'@ | Out-File -FilePath "$weatherDir/Services/WeatherProcessorService.cs" -Encoding utf8
