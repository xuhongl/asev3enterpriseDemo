using StackExchange.Redis;

namespace FibonacciApi.Repository;

public class SequenceRepository 
{
    private IDatabase _database;

    private async Task<IDatabase> Database() => await CreateConnectionAsync();

    public SequenceRepository(IConfiguration configuration)
    {
        var connection = ConnectionMultiplexer.Connect(configuration["RedisCnxString"]);
        _database = connection.GetDatabase();
    }

    private async Task<Sequence?> GetSequenceAsync(int len)
    {
        var value = await _database.StringGetAsync(new RedisKey(len.ToString()));

        return string.IsNullOrEmpty(value.ToString()) 
               ? null 
               : JsonConvert.Parse();
    }

    // private async Task<Sequence> GetSequenceAsync(int len)
    // {
    //     try
    //     {
    //         _database.String
    //     catch (System.Exception)
    //     {
            
    //         throw;
    //     }
    // }
}

