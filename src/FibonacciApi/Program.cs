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

app.MapGet("/api/fibonacci/getsequence", async ([FromServices] ISequenceRepository repository, long len) =>
{
    List<long> sequences;
    sequences = await repository.GetSequenceAsync(len);

    if (sequences == null)
    {
        sequences = new List<long>();
        long a = 0, b = 1, c = 0;
    
        for (long i = 2; i < len; i++)  
        {  
            c= a + b;  
            sequences.Add(c);
            a= b;  
            b= c;  
        }  

        await repository.SetSequenceValue(len,sequences);
    }
    return sequences;
})
.WithName("GetSequence");

app.MapHealthChecks("/healthz");

app.Run();