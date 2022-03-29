using StackExchange.Redis;

namespace FibonacciApi.Repository;

public class SequenceRepository : ISequenceRepository
{
    private IDatabase _database;
    private readonly ILogger<SequenceRepository> _logger;

    private readonly ConnectionMultiplexer _connection;

    private bool _cacheAvailable = false;

    public SequenceRepository(IConfiguration configuration, ILogger<SequenceRepository> logger)
    {

        _logger = logger;

        try
        {
#if DEBUG        
            _connection = ConnectionMultiplexer.Connect("localhost:6379");
#else         
            _connection = ConnectionMultiplexer.Connect(configuration["RedisCnxString"]);
#endif        
            _database = _connection.GetDatabase();   

            _cacheAvailable = true;         

        }
        catch (System.Exception ex)
        {
            _logger.LogError("Cannot create connection",ex.Message);      
        }

    }

    public async Task<Sequence> GetSequenceAsync(long len)
    {
        try
        {
            if (!_cacheAvailable)
              return null;

            _logger.LogDebug($"Get value len {len} from cache");

            var value = await _database.StringGetAsync(new RedisKey(len.ToString()));

            if (value.HasValue)
                return JsonConvert.DeserializeObject<Sequence>(value.ToString());

            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError("Cannot get value from cache",ex.Message);
            return null;
        }
    }

    public async Task SetSequenceValue(long len, Sequence values)
    {
        try
        {

            if (!_cacheAvailable)
              return;

            _logger.LogDebug($"Set value len {len} in cache");
            await _database.StringSetAsync(new RedisKey(len.ToString()),
                                           new RedisValue(JsonConvert.SerializeObject(values)));
        }
        catch (System.Exception ex)
        {
            _logger.LogError("Cannot set value in cache",ex.Message);
        }
    }

    public async Task ClearCacheAsync()
    {
        try
        {
            var endpoints = _connection.GetEndPoints();
            var server = _connection.GetServer(endpoints.First());

            var keys = server.Keys();

            foreach (var key in keys)
            {
                await _database.KeyDeleteAsync(key);
            }
        }
        catch (System.Exception ex)
        {            
            _logger.LogError("Cannot set value in cache",ex.Message);
        }
    }
}

