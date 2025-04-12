namespace BackgroundProcessing.WeatherLoader.Services;

public interface IWeatherProcessorService
{
    Task<string> ProcessWeatherAsync(CancellationToken cancellationToken = default);
}
