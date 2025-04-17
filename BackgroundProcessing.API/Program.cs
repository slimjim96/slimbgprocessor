using StockLoader.Models;
using StockLoader.Services;
using Weather.Models;
using Weather.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register Weather Service
builder.Services.Configure<WeatherSettings>(
    builder.Configuration.GetSection("Weather"));
builder.Services.AddHostedService<WeatherBackgroundService>();
builder.Services.AddSingleton<IWeatherService, WeatherService>();

// Register StockLoader Service
builder.Services.Configure<StockLoaderSettings>(
    builder.Configuration.GetSection("StockLoader"));
builder.Services.AddHostedService<StockLoaderBackgroundService>();
builder.Services.AddSingleton<IStockLoaderService, StockLoaderService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
