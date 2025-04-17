using System;

namespace BackgroundProcessing.Tests;

/// <summary>
/// Extension methods for testing
/// </summary>
public static class TestExtensions
{
    /// <summary>
    /// Checks if a DateTime is close to another DateTime within a specified tolerance
    /// </summary>
    public static bool IsCloseTo(this DateTime source, DateTime target, TimeSpan tolerance)
    {
        return Math.Abs((source - target).TotalMilliseconds) <= tolerance.TotalMilliseconds;
    }
}
