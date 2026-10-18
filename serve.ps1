# Local development server (not part of the app).
# Serves the project folder at http://localhost:8080/ with correct MIME types,
# so ES modules load in the browser. Usage:
#   powershell -ExecutionPolicy Bypass -File serve.ps1

$ErrorActionPreference = 'Stop'

$port = 8080
$root = [System.IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\') + '\'

$mimeTypes = @{
    '.html'  = 'text/html; charset=utf-8'
    '.js'    = 'text/javascript; charset=utf-8'
    '.css'   = 'text/css; charset=utf-8'
    '.json'  = 'application/json; charset=utf-8'
    '.svg'   = 'image/svg+xml'
    '.png'   = 'image/png'
    '.ico'   = 'image/x-icon'
    '.woff2' = 'font/woff2'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/ (Ctrl+C to stop)"

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $status = 200

        try {
            $relativePath = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath).TrimStart('/')
            if ($relativePath -eq '' -or $relativePath.EndsWith('/')) {
                $relativePath += 'index.html'
            }
            $fullPath = [System.IO.Path]::GetFullPath((Join-Path $root $relativePath))

            if (-not $fullPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
                # Block path traversal outside the project folder
                $status = 403
            } elseif (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
                $status = 404
            } else {
                $extension = [System.IO.Path]::GetExtension($fullPath).ToLowerInvariant()
                $contentType = $mimeTypes[$extension]
                if (-not $contentType) { $contentType = 'application/octet-stream' }

                $bytes = [System.IO.File]::ReadAllBytes($fullPath)
                $response.ContentType = $contentType
                $response.Headers.Add('Cache-Control', 'no-store')
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }

            if ($status -ne 200) {
                $response.StatusCode = $status
                $message = [System.Text.Encoding]::UTF8.GetBytes("$status")
                $response.ContentType = 'text/plain; charset=utf-8'
                $response.OutputStream.Write($message, 0, $message.Length)
            }
        } catch {
            $status = 500
            $response.StatusCode = 500
        } finally {
            Write-Host "$status $($request.HttpMethod) $($request.Url.AbsolutePath)"
            $response.OutputStream.Close()
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
