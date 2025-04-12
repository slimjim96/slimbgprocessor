using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Services;

public interface IWeatherLoaderService
{
    Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default);
}
