using BackgroundProcessing.Core.Services;
using BackgroundProcessing.Infrastructure;
using BackgroundProcessing.WeatherLoader.Configuration;
using BackgroundProcessing.WeatherLoader.Endpoints;
using BackgroundProcessing.WeatherLoader.Services;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Weather Loader API",
        Version = "v1",
        Description = "API for loading weather data"
    });
});

// Add Infrastructure services
builder.Services.AddInfrastructureServices(builder.Configuration);

// Add WeatherLoader services
builder.Services.Configure<WeatherLoaderOptions>(builder.Configuration.GetSection("WeatherLoader"));
builder.Services.AddHttpClient<IWeatherDataService, WeatherDataService>();
builder.Services.AddScoped<IWeatherProcessorService, WeatherProcessorService>();
builder.Services.AddHostedService<WeatherLoaderBackgroundService>();

// Register endpoint definitions
builder.Services.AddScoped<WeatherLoaderEndpointDefinitions>();

// Add health checks
builder.Services.AddHealthChecks()
    .AddCheck<WeatherLoaderHealthCheck>("weather_loader_health_check");

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
    .MapWeatherLoaderEndpoints(app)
    .WithTags("WeatherLoader");

// Map health checks
app.MapHealthChecks("/health");

app.Run();