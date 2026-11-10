$ErrorActionPreference = "Stop"

$root = "C:\n8n-content"
$scriptPath = Join-Path $root "audio\script.txt"
$hookPath = Join-Path $root "audio\hook.txt"

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Narration file not found."
}

$text = (Get-Content -LiteralPath $scriptPath -Raw).Trim()
$text = $text -replace '\s+', ' '

if ([string]::IsNullOrWhiteSpace($text)) {
    throw "Narration is empty."
}

# Extract the opening sentence.
$match = [regex]::Match($text, '^.{1,160}?[.!?](?=\s|$)')

if ($match.Success) {
    $hook = $match.Value.Trim()
} else {
    $hook = $text.Substring(0, [Math]::Min(70, $text.Length))
}

# Wrap into lines of at most 28 characters.
$words = $hook -split '\s+'
$lines = @()
$line = ""

foreach ($word in $words) {
    if ($line.Length -eq 0) {
        $line = $word
    } elseif (($line.Length + 1 + $word.Length) -le 28) {
        $line += " " + $word
    } else {
        $lines += $line
        $line = $word
    }
}

if ($line.Length -gt 0) {
    $lines += $line
}

# Keep the hook compact.
if ($lines.Count -gt 3) {
    $lines = $lines[0..2]
    $lines[2] = $lines[2].TrimEnd() + "..."
}

$hookText = $lines -join "\`r\`n"
$utf8 = New-Object System.Text.UTF8Encoding($false)

[System.IO.File]::WriteAllText($hookPath, $hookText, $utf8)

Write-Output "Hook created:"
Write-Output $hookText
