using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.WeatherLoader.Services;

public interface IWeatherDataService
{
    Task<IEnumerable<WeatherData>> FetchWeatherDataAsync(IEnumerable<string> locations, CancellationToken cancellationToken = default);
}
