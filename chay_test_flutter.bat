@echo off
SETLOCAL EnableDelayedExpansion

:: Thiết lập môi trường
echo === Dang chuan bi moi truong Flutter ===
SET "FLUTTER_PATH=C:\Users\thanh\Downloads\Compressed\flutter_windows_3.29.3-stable\flutter\bin"
SET "GIT_PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
SET "PATH=%FLUTTER_PATH%;%GIT_PATH%;%PATH%"

:: Kiểm tra Git
echo.
echo === Kiem tra Git ===
git --version
IF %ERRORLEVEL% NEQ 0 (
  echo Git khong tim thay, dang them vao PATH...
  SET "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"
)

:: Chuyển đến thư mục dự án
cd /d "%~dp0"

:: Chạy test
echo.
echo === Dang chay Flutter test ===
"%FLUTTER_PATH%\flutter.bat" test

:: Nếu test thất bại thì chạy lại với Flutter verbose
IF %ERRORLEVEL% NEQ 0 (
  echo.
  echo === Thu lai voi che do verbose ===
  "%FLUTTER_PATH%\flutter.bat" test -v
)

echo.
echo === Ket thuc ===
echo.
echo Neu bao loi, hay chay cac lenh sau trong Command Prompt moi:
echo - cd C:\Users\thanh\OneDrive\Documents\xntt
echo - set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%%PATH%%"
echo - C:\Users\thanh\Downloads\Compressed\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat test

echo.
pause 