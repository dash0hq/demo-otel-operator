var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://localhost:3000");

var app = builder.Build();

app.MapGet("/", () => new { 
    message = "Hello, KubeCon!", 
    language = "dotnet" 
});
app.Run();