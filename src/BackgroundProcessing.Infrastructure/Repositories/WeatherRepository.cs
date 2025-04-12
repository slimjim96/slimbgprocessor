using BackgroundProcessing.Core.Models;
using BackgroundProcessing.Core.Repositories;
using BackgroundProcessing.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BackgroundProcessing.Infrastructure.Repositories;

public class WeatherRepository : IWeatherRepository
{
    private readonly WeatherDbContext _dbContext;
    private readonly ILogger<WeatherRepository> _logger;

    public WeatherRepository(WeatherDbContext dbContext, ILogger<WeatherRepository> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task SaveWeatherDataAsync(IEnumerable<WeatherData> weatherData, CancellationToken cancellationToken = default)
    {
        try
        {
            await _dbContext.WeatherData.AddRangeAsync(weatherData, cancellationToken);
            await _dbContext.SaveChangesAsync(cancellationToken);
            _logger.LogInformation("Successfully saved {Count} weather data records", weatherData.Count());
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error saving weather data");
            throw;
        }
    }

    public async Task<IEnumerable<WeatherData>> GetLatestWeatherDataAsync(string location, CancellationToken cancellationToken = default)
    {
        return await _dbContext.WeatherData
            .Where(w => w.Location == location)
            .OrderByDescending(w => w.Timestamp)
            .Take(100)
            .ToListAsync(cancellationToken);
    }
}
