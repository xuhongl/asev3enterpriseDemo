using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddHttpClient();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();
app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateTime.Now.AddDays(index),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.MapGet("/sessions",async (IHttpClientFactory factory) => 
{
    try
    {
        var httpClient = factory.CreateClient();
        var httpResponseMessage = await httpClient.GetAsync("https://conferenceapi.azurewebsites.net/sessions");

        if (httpResponseMessage.IsSuccessStatusCode) 
        {
            return await httpResponseMessage.Content.ReadAsStringAsync();
        }

        return $"ConferenceAPI Status Code: {httpResponseMessage.StatusCode}";
    }
    catch
    {
        return "Cannot reach API";
    }
});



app.MapHealthChecks("/healthz");

app.Run();

record WeatherForecast(DateTime Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}