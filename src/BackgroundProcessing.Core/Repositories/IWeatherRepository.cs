using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Repositories;

public interface IWeatherRepository
{
    Task SaveWeatherDataAsync(IEnumerable<WeatherData> weatherData, CancellationToken cancellationToken = default);
    Task<IEnumerable<WeatherData>> GetLatestWeatherDataAsync(string location, CancellationToken cancellationToken = default);
}
