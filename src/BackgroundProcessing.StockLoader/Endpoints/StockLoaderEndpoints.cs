using BackgroundProcessing.Core.Models;
using BackgroundProcessing.StockLoader.Services;
using Microsoft.AspNetCore.Http.HttpResults;

namespace BackgroundProcessing.StockLoader.Endpoints;

// Non-static implementation class with proper DI
public class StockLoaderEndpointDefinitions
{
    private readonly ILogger<StockLoaderEndpointDefinitions> _logger;
    private readonly IStockProcessorService _processorService;

    public StockLoaderEndpointDefinitions(
        ILogger<StockLoaderEndpointDefinitions> logger,
        IStockProcessorService processorService)
    {
        _logger = logger;
        _processorService = processorService;
    }

    public void DefineEndpoints(RouteGroupBuilder group)
    {
        group.MapPost("/process", ProcessStocks)
            .WithName("ProcessStocks")
            .WithOpenApi(operation =>
            {
                operation.Summary = "Triggers the stock loading process";
                return operation;
            });
    }

    private async Task<IResult> ProcessStocks(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Manual trigger of stock processing received");

        try
        {
            var jobId = await _processorService.ProcessStocksAsync(cancellationToken);
            return TypedResults.Ok(new JobResponse { JobId = jobId, Status = "Started" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing stocks");
            return TypedResults.BadRequest("Failed to process stocks: " + ex.Message);
        }
    }
}

// Static extension methods for registration
public static class StockLoaderEndpointExtensions
{
    public static RouteGroupBuilder MapStockLoaderEndpoints(this RouteGroupBuilder group, WebApplication app)
    {
        var endpoints = app.Services.GetRequiredService<StockLoaderEndpointDefinitions>();
        endpoints.DefineEndpoints(group);
        return group;
    }
}