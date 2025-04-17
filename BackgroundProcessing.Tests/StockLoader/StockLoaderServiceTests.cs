using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NSubstitute;
using StockLoader.Models;
using StockLoader.Services;
using Xunit;

namespace BackgroundProcessing.Tests.StockLoader;

public class StockLoaderServiceTests
{
    private readonly ILogger<StockLoaderService> _logger;
    private readonly IOptions<StockLoaderSettings> _settings;
    private readonly StockLoaderService _service;
    private readonly List<string> _testSymbols = new() { "TEST", "MOCK" };

    public StockLoaderServiceTests()
    {
        // Setup mocks with NSubstitute
        _logger = Substitute.For<ILogger<StockLoaderService>>();
        
        // Create test settings
        var stockSettings = new StockLoaderSettings
        {
            ApiKey = "test-api-key",
            UpdateIntervalMinutes = 5,
            Symbols = new List<string> { "DEFAULT" }
        };
        
        _settings = Substitute.For<IOptions<StockLoaderSettings>>();
        _settings.Value.Returns(stockSettings);
        
        // Create the service with mocked dependencies
        _service = new StockLoaderService(_logger, _settings);
    }

    [Fact]
    public async Task GetLatestStockDataAsync_WhenNoDataExists_ReturnsEmptyList()
    {
        // Act
        var result = await _service.GetLatestStockDataAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetStockDataAsync_WhenNoDataExists_ReturnsNull()
    {
        // Act
        var result = await _service.GetStockDataAsync("TEST");

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task FetchStockDataAsync_ShouldCreateData()
    {
        // Act
        await _service.FetchStockDataAsync(_testSymbols);
        var result = await _service.GetLatestStockDataAsync();

        // Assert
        result.Should().NotBeNull();
        result.Should().HaveCount(_testSymbols.Count);
        result.Select(s => s.Symbol).Should().BeEquivalentTo(_testSymbols);
        result.All(s => s.Timestamp.IsCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(10))).Should().BeTrue();
    }

    [Fact]
    public async Task GetStockDataAsync_AfterFetch_ReturnsCachedData()
    {
        // Arrange
        var symbol = _testSymbols.First();
        await _service.FetchStockDataAsync(_testSymbols);

        // Act
        var result = await _service.GetStockDataAsync(symbol);

        // Assert
        result.Should().NotBeNull();
        result!.Symbol.Should().Be(symbol);
    }

    [Fact]
    public async Task FetchStockDataAsync_WithCancellation_ShouldCancel()
    {
        // Arrange
        var cts = new CancellationTokenSource();
        cts.Cancel(); // Cancel immediately

        // Act & Assert
        await Assert.ThrowsAsync<OperationCanceledException>(() => 
            _service.FetchStockDataAsync(_testSymbols, cts.Token));
    }
}
