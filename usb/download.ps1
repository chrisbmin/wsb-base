Set-ExecutionPolicy remotesigned
function downloadbuilder {
Invoke-WebRequest -Uri "https://github.com/chrisrbmn/wsb-v2/archive/refs/heads/main.zip" -OutFile "C:\build\main.zip"
Expand-Archive C:\build\main.zip -DestinationPath C:\build\
}
downloadbuilder