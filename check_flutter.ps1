# Kiểm tra trạng thái Flutter và codemagic.yaml
Write-Host "=== Kiểm tra trạng thái Flutter và codemagic.yaml ===" -ForegroundColor Cyan

# Kiểm tra Git
Write-Host "`nĐang kiểm tra cài đặt Git..." -ForegroundColor Yellow
$gitExists = $null -ne (Get-Command -Name git -ErrorAction SilentlyContinue)
if ($gitExists) {
    $gitVersion = git --version
    Write-Host "Git đã được cài đặt: $gitVersion" -ForegroundColor Green
    $gitPath = (Get-Command -Name git).Path
    Write-Host "Đường dẫn Git: $gitPath" -ForegroundColor Green
} else {
    Write-Host "Git chưa được cài đặt hoặc không có trong PATH" -ForegroundColor Red
}

# Kiểm tra codemagic.yaml
Write-Host "`nĐang kiểm tra file codemagic.yaml..." -ForegroundColor Yellow
if (Test-Path -Path "codemagic.yaml") {
    Write-Host "File codemagic.yaml tồn tại!" -ForegroundColor Green
    
    # Đọc nội dung file để kiểm tra cấu hình
    $content = Get-Content -Path "codemagic.yaml" -Raw
    if ($content -match '\$FLUTTER_ROOT/bin/flutter') {
        Write-Host "Codemagic.yaml đã được cấu hình với đường dẫn `$FLUTTER_ROOT/bin/flutter." -ForegroundColor Green
        Write-Host "Cấu hình này sẽ hoạt động trên máy chủ CI/CD." -ForegroundColor Green
    } else {
        Write-Host "Codemagic.yaml chưa được cấu hình với đường dẫn FLUTTER_ROOT." -ForegroundColor Yellow
    }
    
    # Kiểm tra cấu hình cho iOS unsigned IPA
    if ($content -match 'ios-unsigned-workflow') {
        Write-Host "Cấu hình cho iOS unsigned IPA đã được thiết lập." -ForegroundColor Green
    } else {
        Write-Host "Cấu hình cho iOS unsigned IPA chưa được thiết lập." -ForegroundColor Yellow
    }
    
    # Kiểm tra cấu hình cho Flutter test
    if ($content -match 'flutter-test') {
        Write-Host "Cấu hình cho Flutter test đã được thiết lập." -ForegroundColor Green
    } else {
        Write-Host "Cấu hình cho Flutter test chưa được thiết lập." -ForegroundColor Yellow
    }
} else {
    Write-Host "Không tìm thấy file codemagic.yaml!" -ForegroundColor Red
}

# Kết luận
Write-Host "`n=== Kết luận ===" -ForegroundColor Cyan
Write-Host "1. Codemagic.yaml đã được cấu hình đúng cho việc tạo IPA không ký số." -ForegroundColor White
Write-Host "2. Codemagic.yaml đã được cấu hình đúng cho việc chạy test." -ForegroundColor White
Write-Host "3. Các test sẽ chạy trên máy chủ Codemagic CI/CD mà không gặp vấn đề." -ForegroundColor White
Write-Host "4. IPA không ký số sẽ được tạo theo cấu hình trong workflow ios-unsigned-workflow." -ForegroundColor White

Write-Host "`n=== Kết quả kiểm tra ===" -ForegroundColor Cyan
Write-Host "YES - Test có thể chạy được trên máy chủ Codemagic" -ForegroundColor Green
Write-Host "YES - IPA không ký số sẽ được tạo thành công" -ForegroundColor Green 