var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.MapGet("/api/fibonacci/getsequence", (int len) =>
{
    int a = 0, b = 1, c = 0;
    var sequences = new List<int>();
    for (int i = 2; i < len; i++)  
    {  
        c= a + b;  
        sequences.Add(c);
        a= b;  
        b= c;  
    }  
    return sequences;
})
.WithName("GetSequence");

app.Run();