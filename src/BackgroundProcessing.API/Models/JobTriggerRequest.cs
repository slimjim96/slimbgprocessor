namespace BackgroundProcessing.API.Models;

public class JobTriggerRequest
{
    /// <summary>
    /// The job key GUID used to authorize the trigger request
    /// </summary>
    public Guid JobKey { get; set; }
    
    /// <summary>
    /// Optional parameters for the job
    /// </summary>
    public Dictionary<string, string>? Parameters { get; set; }
}
