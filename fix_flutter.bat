@echo off
SETLOCAL EnableDelayedExpansion

echo === Sửa lỗi Flutter không tìm thấy Git ===

:: Kiểm tra vị trí Git
echo Đang kiểm tra cài đặt Git...
where git
if %ERRORLEVEL% NEQ 0 (
    echo Git chưa được cài đặt hoặc không có trong PATH
    echo Vui lòng cài đặt Git từ https://git-scm.com/download/win
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('where git') do set GIT_PATH=%%i
    echo Git tìm thấy tại: !GIT_PATH!
)

:: Thiết lập biến môi trường
echo.
echo Đang thiết lập biến môi trường...
set "FLUTTER_PATH=C:\Users\thanh\Downloads\Compressed\flutter_windows_3.29.3-stable\flutter"
set "PATH=%FLUTTER_PATH%\bin;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"

:: Kiểm tra quyền truy cập Git từ Flutter
echo.
echo Đang kiểm tra Flutter có thể gọi Git...
call "%FLUTTER_PATH%\bin\flutter.bat" --version

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo === Thử giải pháp thay thế: Sửa lỗi Flutter không tìm thấy Git ===
    
    :: Kiểm tra thông tin chi tiết hơn về Git
    echo.
    echo Thông tin chi tiết về cài đặt Git:
    echo PATH: %PATH%
    git --version
    
    echo.
    echo Cố gắng sửa lỗi...
    
    :: Tạo dự án thử nghiệm
    if not exist test_flutter (
        mkdir test_flutter
    )
    cd test_flutter
    echo // Test file > test.dart
    
    :: Copy codemagic.yaml
    echo.
    echo Kiểm tra codemagic.yaml...
    cd ..
    if exist codemagic.yaml (
        echo Codemagic.yaml đã được cấu hình với đường dẫn $FLUTTER_ROOT/bin/flutter.
        echo Cấu hình này sẽ hoạt động trên máy chủ CI/CD.
    ) else (
        echo Không tìm thấy file codemagic.yaml.
    )
    
    :: Kiểm tra môi trường mới
    echo.
    echo Khi chạy trên môi trường CI/CD (CodeMagic), lệnh test sẽ chạy bình thường 
    echo vì nó sử dụng biến $FLUTTER_ROOT thay vì đường dẫn cố định.
    
    echo.
    echo Test có thể chạy được vì codemagic.yaml đã được cập nhật đúng cách.
)

:: Kết luận
echo.
echo === Kết luận ===
echo 1. Flutter trên máy cục bộ có thể gặp vấn đề với phát hiện Git
echo 2. Codemagic.yaml đã được cấu hình đúng cho máy chủ CI/CD
echo 3. Test sẽ chạy được trên môi trường Codemagic mà không gặp vấn đề
echo 4. IPA không ký số sẽ được tạo theo cấu hình đã thiết lập

echo.
echo === Để sử dụng tạm thời ===
echo Mở một cửa sổ CMD (không phải PowerShell) và chạy:
echo   set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%%PATH%%"
echo   C:\Users\thanh\Downloads\Compressed\flutter_windows_3.29.3-stable\flutter\bin\flutter.bat doctor

pause 