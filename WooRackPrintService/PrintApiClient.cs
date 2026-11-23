using System.Net.Http;
using System.Net.Http.Json;
using WooRackPrintAgent.Shared;

namespace WooRackPrintService;

public class PrintApiClient
{
    private readonly HttpClient _http;

    public PrintApiClient()
{
    _http = new HttpClient
    {
        Timeout = TimeSpan.FromSeconds(15)
    };
    _http.DefaultRequestHeaders.UserAgent.ParseAdd("WooRackPrintAgent/1.0");
}

    private static string BuildUrl(string storeUrl, string route, string token)
{
    var baseUrl = storeUrl.Trim().TrimEnd('/');
    if (!baseUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
        !baseUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
    {
        baseUrl = "https://" + baseUrl;
    }

    var cleanRoute = route.Trim().TrimStart('/');
    var sep = cleanRoute.Contains('?') ? "&" : "?";
    return $"{baseUrl}/wp-json/woorack/v2/{cleanRoute}{sep}token={Uri.EscapeDataString(token.Trim())}";
}

    public async Task RegisterAgentAsync(AgentConfig config, List<string> printers, CancellationToken ct)
    {
        var url = BuildUrl(config.StoreUrl, "/print/register", config.ApiToken);
        var payload = new RegisterAgentRequest
        {
            MachineId = config.MachineId,
            AgentName = config.AgentName,
            Printers = printers
        };

        using var response = await _http.PostAsJsonAsync(url, payload, ct);
        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(ct);
            throw new HttpRequestException($"HTTP {(int)response.StatusCode} ({url}): {body}");
        }
    }

    public async Task<PrintJobDto?> PollNextJobAsync(AgentConfig config, CancellationToken ct)
    {
        var route = $"/print/poll?machine_id={Uri.EscapeDataString(config.MachineId)}";
        var url = BuildUrl(config.StoreUrl, route, config.ApiToken);

        using var response = await _http.GetAsync(url, ct);
        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(ct);
            throw new HttpRequestException($"HTTP {(int)response.StatusCode}: {body}");
        }

        var data = await response.Content.ReadFromJsonAsync<PollResponse>(cancellationToken: ct);
        return data?.Job;
    }

    public async Task AcknowledgeJobAsync(AgentConfig config, int jobId, bool success, string? error, CancellationToken ct)
    {
        var url = BuildUrl(config.StoreUrl, $"/print/jobs/{jobId}/ack", config.ApiToken);
        var payload = new AckJobRequest
        {
            Status = success ? "printed" : "failed",
            Error = error
        };

        using var response = await _http.PostAsJsonAsync(url, payload, ct);
        response.EnsureSuccessStatusCode();
    }
}