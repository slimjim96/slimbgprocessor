using BackgroundProcessing.API.Configuration;
using BackgroundProcessing.API.Endpoints;
using BackgroundProcessing.Core.Services;
using BackgroundProcessing.Infrastructure;
using BackgroundProcessing.Infrastructure.Services;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
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

// Register endpoint definitions
builder.Services.AddScoped<JobEndpointDefinitions>();

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
    .MapJobEndpoints(app)
    .RequireAuthorization()
    .WithTags("Jobs");

// Map health checks
app.MapHealthChecks("/health");

app.Run();