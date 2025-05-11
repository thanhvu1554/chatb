@echo off
echo === Sửa lỗi PATH cho Flutter ===

:: Thêm System32 và các đường dẫn cần thiết vào PATH
set "SYSTEM_PATH=C:\Windows;C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\v1.0"
set "FLUTTER_PATH=C:\flutter\bin"
set "GIT_PATH=C:\Users\thanh\Downloads\Programs\PortableGit\bin"

:: Thiết lập FLUTTER_GIT_EXECUTABLE
set "FLUTTER_GIT_EXECUTABLE=%GIT_PATH%\git.exe"

:: Cập nhật PATH
set "PATH=%SYSTEM_PATH%;%FLUTTER_PATH%;%GIT_PATH%;%PATH%"

echo.
echo === Thông tin cấu hình ===
echo FLUTTER_PATH: %FLUTTER_PATH%
echo GIT_PATH: %GIT_PATH%
echo FLUTTER_GIT_EXECUTABLE: %FLUTTER_GIT_EXECUTABLE%
echo.

:: Kiểm tra git tồn tại không
if exist "%GIT_PATH%\git.exe" (
    echo Tìm thấy Git tại: %GIT_PATH%\git.exe
    "%GIT_PATH%\git.exe" --version
) else (
    echo Không tìm thấy Git tại: %GIT_PATH%\git.exe
    echo Vui lòng cập nhật đường dẫn Git đúng trong file này.
    pause
    exit /b 1
)

echo.
echo === Chạy Flutter Doctor ===
call "%FLUTTER_PATH%\flutter.bat" doctor -v

echo.
echo === Hoàn thành ===
echo Nếu vẫn gặp lỗi, hãy khởi động lại CMD mới và thử lại.

pause 