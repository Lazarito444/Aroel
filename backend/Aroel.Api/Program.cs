using Aroel.Api.Composition;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
builder.Host.UseDefaultServiceProvider(options => options.ValidateOnBuild = true);
builder.Services.AddAroelServices(builder.Configuration.GetConnectionString("Aroel")
    ?? throw new InvalidOperationException("The 'Aroel' connection string is not configured."));

WebApplication app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.Run();
