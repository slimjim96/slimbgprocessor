using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BackgroundProcessing.API.Controllers;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NSubstitute;
using StockLoader.Models;
using StockLoader.Services;
using Xunit;

namespace BackgroundProcessing.Tests.API;

public class StockControllerTests
{
    private readonly ILogger<StockController> _logger;
    private readonly IStockLoaderService _stockService;
    private readonly IOptions<StockLoaderSettings> _settings;
    private readonly StockController _controller;
    private readonly string _testSymbol = "TEST";
    private readonly List<StockData> _testData;

    public StockControllerTests()
    {
        // Setup mocks
        _logger = Substitute.For<ILogger<StockController>>();
        _stockService = Substitute.For<IStockLoaderService>();
        
        // Create test settings
        var stockSettings = new StockLoaderSettings
        {
            ApiKey = "test-api-key",
            UpdateIntervalMinutes = 5,
            Symbols = new List<string> { _testSymbol, "MOCK" }
        };
        
        _settings = Substitute.For<IOptions<StockLoaderSettings>>();
        _settings.Value.Returns(stockSettings);
        
        // Create test stock data
        _testData = new List<StockData>
        {
            new() { Symbol = _testSymbol, Price = 123.45m, Volume = 1000 },
            new() { Symbol = "MOCK", Price = 67.89m, Volume = 2000 }
        };
        
        // Create controller with mocked dependencies
        _controller = new StockController(_logger, _stockService, _settings);
    }

    [Fact]
    public async Task GetAllStocks_WhenDataExists_ReturnsOkWithData()
    {
        // Arrange
        _stockService.GetLatestStockDataAsync(Arg.Any<CancellationToken>())
            .Returns(_testData);

        // Act
        var result = await _controller.GetAllStocks(CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var stockData = okResult.Value.Should().BeOfType<List<StockData>>().Subject;
        stockData.Should().BeEquivalentTo(_testData);
        
        // Verify service was called
        await _stockService.Received(1).GetLatestStockDataAsync(Arg.Any<CancellationToken>());
        await _stockService.DidNotReceive().FetchStockDataAsync(Arg.Any<List<string>>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetAllStocks_WhenNoDataExists_FetchesData()
    {
        // Arrange
        _stockService.GetLatestStockDataAsync(Arg.Any<CancellationToken>())
            .Returns(new List<StockData>(), _testData);

        // Act
        var result = await _controller.GetAllStocks(CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var stockData = okResult.Value.Should().BeOfType<List<StockData>>().Subject;
        stockData.Should().BeEquivalentTo(_testData);
        
        // Verify service calls
        await _stockService.Received(2).GetLatestStockDataAsync(Arg.Any<CancellationToken>());
        await _stockService.Received(1).FetchStockDataAsync(
            Arg.Is<List<string>>(list => list.SequenceEqual(_settings.Value.Symbols)), 
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetStock_WhenDataExists_ReturnsOkWithData()
    {
        // Arrange
        var stockData = _testData.First(s => s.Symbol == _testSymbol);
        _stockService.GetStockDataAsync(_testSymbol, Arg.Any<CancellationToken>())
            .Returns(stockData);

        // Act
        var result = await _controller.GetStock(_testSymbol, CancellationToken.None);

        // Assert
        var okResult = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var returnedData = okResult.Value.Should().BeOfType<StockData>().Subject;
        returnedData.Should().Be(stockData);
        
        // Verify service was called
        await _stockService.Received(1).GetStockDataAsync(_testSymbol, Arg.Any<CancellationToken>());
        await _stockService.DidNotReceive().FetchStockDataAsync(Arg.Any<List<string>>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetStock_WhenSymbolNotTracked_ReturnsNotFound()
    {
        // Arrange
        var unknownSymbol = "UNKNOWN";
        
        // Act
        var result = await _controller.GetStock(unknownSymbol, CancellationToken.None);

        // Assert
        result.Result.Should().BeOfType<NotFoundObjectResult>();
    }

    [Fact]
    public async Task RefreshAllStocks_CallsService_ReturnsOk()
    {
        // Act
        var result = await _controller.RefreshAllStocks(CancellationToken.None);

        // Assert
        result.Should().BeOfType<OkObjectResult>();
        
        // Verify service was called with all configured symbols
        await _stockService.Received(1).FetchStockDataAsync(
            Arg.Is<List<string>>(list => list.SequenceEqual(_settings.Value.Symbols)), 
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task RefreshStock_WithValidSymbol_CallsService_ReturnsOk()
    {
        // Act
        var result = await _controller.RefreshStock(_testSymbol, CancellationToken.None);

        // Assert
        result.Should().BeOfType<OkObjectResult>();
        
        // Verify service was called with just the one symbol
        await _stockService.Received(1).FetchStockDataAsync(
            Arg.Is<List<string>>(list => list.Count == 1 && list[0] == _testSymbol), 
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task RefreshStock_WithInvalidSymbol_ReturnsNotFound()
    {
        // Arrange
        var unknownSymbol = "UNKNOWN";
        
        // Act
        var result = await _controller.RefreshStock(unknownSymbol, CancellationToken.None);

        // Assert
        result.Should().BeOfType<NotFoundObjectResult>();
        
        // Verify service was not called
        await _stockService.DidNotReceive().FetchStockDataAsync(Arg.Any<List<string>>(), Arg.Any<CancellationToken>());
    }
}
