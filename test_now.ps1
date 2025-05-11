# Script chay test Flutter

# Dat duong dan truc tiep den Git va Flutter
$gitBinPath = "C:\Program Files\Git\bin" 
$gitExePath = "C:\Program Files\Git\bin\git.exe"
$flutterPath = "C:\Users\thanh\Downloads\Compressed\flutter_windows_3.29.3-stable\flutter\bin"
$flutterExePath = "$flutterPath\flutter.bat"

# Mo cua so cmd moi su dung ProcessStartInfo
$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$processStartInfo.FileName = "C:\Windows\System32\cmd.exe"
$processStartInfo.WorkingDirectory = "C:\Users\thanh\OneDrive\Documents\xntt"
$processStartInfo.Arguments = "/k set FLUTTER_GIT_EXECUTABLE=$gitExePath && set PATH=$gitBinPath;%PATH% && $flutterExePath test"
$processStartInfo.UseShellExecute = $true

# Bat dau process
Write-Host "Dang mo cua so cmd de chay test..."
Write-Host "Su dung duong dan Git: $gitExePath"
Write-Host "Su dung duong dan Flutter: $flutterExePath"
Write-Host "--------------------------------------------"
Write-Host "Khi cua so CMD mo, hay cho ket qua test hien thi."

# Chay process
[System.Diagnostics.Process]::Start($processStartInfo) 