param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$SearchPattern,
    
    [Parameter(Mandatory=$true)]
    [string]$ReplaceText
)

# Kiểm tra xem file có tồn tại không
if (-not (Test-Path $FilePath)) {
    Write-Error "Không tìm thấy file: $FilePath"
    exit 1
}

# Đọc nội dung file
$content = Get-Content -Path $FilePath -Raw

# Thực hiện thay thế
$newContent = $content -replace $SearchPattern, $ReplaceText

# Ghi nội dung mới vào file
$newContent | Set-Content -Path $FilePath -NoNewline

Write-Host "Đã thay thế thành công trong file: $FilePath" 