using BackgroundProcessing.Core.Models;
using BackgroundProcessing.WeatherLoader.Services;
using Microsoft.AspNetCore.Http.HttpResults;

namespace BackgroundProcessing.WeatherLoader.Endpoints;

// Non-static implementation class with proper DI
public class WeatherLoaderEndpointDefinitions
{
    private readonly ILogger<WeatherLoaderEndpointDefinitions> _logger;
    private readonly IWeatherProcessorService _processorService;

    public WeatherLoaderEndpointDefinitions(
        ILogger<WeatherLoaderEndpointDefinitions> logger,
        IWeatherProcessorService processorService)
    {
        _logger = logger;
        _processorService = processorService;
    }

    public void DefineEndpoints(RouteGroupBuilder group)
    {
        group.MapPost("/process", ProcessWeather)
            .WithName("ProcessWeather")
            .WithOpenApi(operation =>
            {
                operation.Summary = "Triggers the weather loading process";
                return operation;
            });
    }

    private async Task<IResult> ProcessWeather(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Manual trigger of weather processing received");

        try
        {
            var jobId = await _processorService.ProcessWeatherAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = jobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing weather");
            return TypedResults.BadRequest("Failed to process weather: " + ex.Message);
        }
    }
}

// Static extension methods for registration
public static class WeatherLoaderEndpointExtensions
{
    public static RouteGroupBuilder MapWeatherLoaderEndpoints(this RouteGroupBuilder group, WebApplication app)
    {
        var endpoints = app.Services.GetRequiredService<WeatherLoaderEndpointDefinitions>();
        endpoints.DefineEndpoints(group);
        return group;
    }
}