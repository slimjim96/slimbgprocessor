using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using StockLoader;
using StockLoader.Services;
using StockLoader.Models;

namespace BackgroundProcessing.API.Controllers;

[ApiController]
[Route("[controller]")]
public class StockController : ControllerBase
{
    private readonly ILogger<StockController> _logger;
    private readonly IStockLoaderService _stockService;
    private readonly StockLoaderSettings _settings;

    public StockController(
        ILogger<StockController> logger,
        IStockLoaderService stockService,
        IOptions<StockLoaderSettings> settings)
    {
        _logger = logger;
        _stockService = stockService;
        _settings = settings.Value;
    }

    [HttpGet]
    public async Task<ActionResult<List<StockData>>> GetAllStocks(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Request received for all stock data");
        
        var stocksData = await _stockService.GetLatestStockDataAsync(cancellationToken);
        
        if (stocksData == null || !stocksData.Any())
        {
            // If we don't have any data yet, trigger a fetch and wait for it
            _logger.LogInformation("No cached stock data, fetching now");
            await _stockService.FetchStockDataAsync(_settings.Symbols, cancellationToken);
            stocksData = await _stockService.GetLatestStockDataAsync(cancellationToken);
        }
        
        return Ok(stocksData);
    }

    [HttpGet("{symbol}")]
    public async Task<ActionResult<StockData>> GetStock(string symbol, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Stock data request received for {Symbol}", symbol);
        
        var stockData = await _stockService.GetStockDataAsync(symbol, cancellationToken);
        
        if (stockData == null)
        {
            if (_settings.Symbols.Contains(symbol))
            {
                // Symbol is configured but we don't have data yet, trigger a fetch
                var symbolList = new List<string> { symbol };
                await _stockService.FetchStockDataAsync(symbolList, cancellationToken);
                stockData = await _stockService.GetStockDataAsync(symbol, cancellationToken);
                
                if (stockData == null)
                {
                    return NotFound($"Could not fetch data for symbol {symbol}");
                }
            }
            else
            {
                return NotFound($"Symbol {symbol} is not being tracked");
            }
        }
        
        return Ok(stockData);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> RefreshAllStocks(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Manual stock refresh triggered for all symbols");
        
        await _stockService.FetchStockDataAsync(_settings.Symbols, cancellationToken);
        
        return Ok(new { message = "Stock data refresh initiated" });
    }

    [HttpPost("refresh/{symbol}")]
    public async Task<IActionResult> RefreshStock(string symbol, CancellationToken cancellationToken)
    {
        if (!_settings.Symbols.Contains(symbol))
        {
            return NotFound($"Symbol {symbol} is not being tracked");
        }
        
        _logger.LogInformation("Manual stock refresh triggered for {Symbol}", symbol);
        
        var symbolList = new List<string> { symbol };
        await _stockService.FetchStockDataAsync(symbolList, cancellationToken);
        
        return Ok(new { message = $"Stock data refresh for {symbol} initiated" });
    }
}
