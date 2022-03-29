namespace FibonacciApi.Models;

public class Sequence 
{
    public long Len { get; set; }

    public bool ValueFromCache { get; set; }

    public List<long> Values { get; set; }

    public Sequence()
    {
        Values = new List<long>();
    }
}

