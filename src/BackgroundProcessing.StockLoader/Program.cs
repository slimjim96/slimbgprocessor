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
    c.SwaggerDoc("v1", new OpenApiInfo
    {
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

// Register endpoint definitions
builder.Services.AddScoped<StockLoaderEndpointDefinitions>();

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
    .MapStockLoaderEndpoints(app)
    .WithTags("StockLoader");

// Map health checks
app.MapHealthChecks("/health");

app.Run();