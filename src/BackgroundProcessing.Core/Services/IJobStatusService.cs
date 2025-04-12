using BackgroundProcessing.Core.Models;

namespace BackgroundProcessing.Core.Services;

public interface IJobStatusService
{
    Task<JobStatusResponse?> GetJobStatusAsync(string jobId, CancellationToken cancellationToken = default);
    Task UpdateJobStatusAsync(JobStatusResponse status, CancellationToken cancellationToken = default);
}
