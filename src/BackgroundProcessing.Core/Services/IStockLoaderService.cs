using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Services;

public interface IStockLoaderService
{
    Task<JobResponse> TriggerProcessAsync(CancellationToken cancellationToken = default);
}
