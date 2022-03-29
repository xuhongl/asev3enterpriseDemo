namespace FibonacciApi.Repository
{
    public interface ISequenceRepository
    {
        Task<List<long>?> GetSequenceAsync(long len);

        Task SetSequenceValue(long len, List<long> values);
    }
}