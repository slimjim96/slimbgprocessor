namespace BackgroundProcessing.API.Configuration;

public class JobKeyOptions
{
    public const string SectionName = "JobKeys";
    
    /// <summary>
    /// The unique key to authorize Stock Loader job triggers
    /// </summary>
    public Guid StockLoaderKey { get; set; }
    
    /// <summary>
    /// The unique key to authorize Weather Loader job triggers
    /// </summary>
    public Guid WeatherLoaderKey { get; set; }
}
