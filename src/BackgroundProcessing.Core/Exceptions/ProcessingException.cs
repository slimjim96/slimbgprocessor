namespace BackgroundProcessing.Core.Exceptions;

public class ProcessingException : Exception
{
    public ProcessingException(string message) : base(message)
    {
    }

    public ProcessingException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
