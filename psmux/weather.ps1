# Prints a short weather string for the psmux status bar, cached for 15 minutes.
# Output must be a single line with no trailing newline, or the status bar grows a second row.
param([string]$Location = "Bouskoura,MA")

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$cache = Join-Path $env:TEMP "psmux-weather.txt"
$maxAgeMinutes = 15

function Write-Weather([string]$text) {
  $text = ($text -replace "[\r\n]+", " ").Trim()
  [Console]::Out.Write($text)
}

if ((Test-Path $cache) -and ((Get-Date) - (Get-Item $cache).LastWriteTime).TotalMinutes -lt $maxAgeMinutes) {
  Write-Weather (Get-Content $cache -Raw)
  return
}

$out = curl.exe -s -m 5 "https://wttr.in/${Location}?format=%c+%t"
if ($LASTEXITCODE -eq 0 -and $out -and $out -notmatch "Unknown|Sorry|<") {
  $out = ($out -join " ").Trim()
  Set-Content $cache $out -NoNewline -Encoding utf8
  Write-Weather $out
}
elseif (Test-Path $cache) {
  Write-Weather (Get-Content $cache -Raw) # offline: show the stale value
}
