using Aroel.Api.Composition;
using Aroel.Api.Endpoints;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();
builder.Host.UseDefaultServiceProvider(options =>
{
    options.ValidateOnBuild = true;
    options.ValidateScopes = true;
});
builder.Services.AddAroelServices(builder.Configuration);

WebApplication app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseRateLimiter();

// The API speaks JSON to native clients; nothing else belongs on the wire.
app.Use(async (context, next) =>
{
    context.Response.Headers.XContentTypeOptions = "nosniff";
    context.Response.Headers.XFrameOptions = "DENY";
    context.Response.Headers.Append("Referrer-Policy", "no-referrer");
    context.Response.Headers.ContentSecurityPolicy = "default-src 'none'";
    await next();
});

app.UseAuthentication();
app.UseAuthorization();

// There is deliberately no CORS policy: the API answers native clients and its
// own health checks, nobody else.
IEndpointRouteBuilder v1 = app.MapGroup("/v1");
v1.MapAuthEndpoints();
v1.MapMeEndpoints();
v1.MapSyncEndpoints();
v1.MapDayEndpoints();

app.Run();
