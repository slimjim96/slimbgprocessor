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
