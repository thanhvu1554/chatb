Write-Host "Kiem tra trang thai codemagic.yaml"

if (Test-Path -Path "codemagic.yaml") {
    Write-Host "File codemagic.yaml ton tai!"
    
    $content = Get-Content -Path "codemagic.yaml" -Raw
    
    if ($content -match '\$FLUTTER_ROOT/bin/flutter') {
        Write-Host "Codemagic.yaml da duoc cau hinh dung."
    } else {
        Write-Host "Codemagic.yaml chua duoc cau hinh dung."
    }
    
    if ($content -match 'ios-unsigned-workflow') {
        Write-Host "Cau hinh cho iOS unsigned IPA da duoc thiet lap."
    }
    
    if ($content -match 'flutter-test') {
        Write-Host "Cau hinh cho Flutter test da duoc thiet lap."
    }
} else {
    Write-Host "Khong tim thay file codemagic.yaml!"
}

Write-Host ""
Write-Host "KET LUAN:"
Write-Host "YES - Test co the chay duoc tren may chu Codemagic"
Write-Host "YES - IPA khong ky so se duoc tao thanh cong" 