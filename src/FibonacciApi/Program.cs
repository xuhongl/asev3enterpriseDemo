using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<ISequenceRepository,SequenceRepository>();


var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("getsequence", async ([FromServices] ISequenceRepository repository, long len) =>
{
    Sequence sequence;
    sequence = await repository.GetSequenceAsync(len);

    if (sequence == null)
    {
        sequence = new Sequence();
        long a = 0, b = 1, c = 0;
    
        for (long i = 2; i < len; i++)  
        {  
            c= a + b;  
            sequence.Values.Add(c);
            a= b;  
            b= c;  
        }  

        await repository.SetSequenceValue(len,sequence);
    }
    else 
    {
        sequence.ValueFromCache = true;
    }
    return sequence;
})
.WithName("GetSequence");

app.MapDelete("cache", async ([FromServices] ISequenceRepository repository) => 
{
    try
    {
        await repository.ClearCacheAsync();
    }
    catch
    {

    }
});

app.MapHealthChecks("/healthz");

app.Run();