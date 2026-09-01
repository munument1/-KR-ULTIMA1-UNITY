$ErrorActionPreference = "Stop"

# This installer must be placed in the Ultima I Unity installation folder.
# Always use the folder containing this script as the game directory.
$GameDir = $PSScriptRoot

function Hash-File([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Backup-Once([string]$Path) {
    $bak = $Path + ".u1k-original"
    if (-not (Test-Path -LiteralPath $bak)) {
        Copy-Item -LiteralPath $Path -Destination $bak
    }
}

function Set-JsonValue($Root, $PathParts, $Value) {
    $node = $Root
    for ($i = 0; $i -lt $PathParts.Count - 1; $i++) {
        $part = $PathParts[$i]
        if ($part.kind -eq 'index') {
            $node = $node[[int]$part.value]
        } else {
            $prop = $node.PSObject.Properties[[string]$part.value]
            if ($null -eq $prop) { throw "JSON key not found: $($part.value)" }
            $node = $prop.Value
        }
    }
    $last = $PathParts[$PathParts.Count - 1]
    if ($last.kind -eq 'index') {
        $node[[int]$last.value] = $Value
    } else {
        $prop = $node.PSObject.Properties[[string]$last.value]
        if ($null -eq $prop) { throw "JSON key not found: $($last.value)" }
        $prop.Value = $Value
    }
}

$manifestPath = Join-Path $PSScriptRoot "patch_data.json"
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "patch_data.json 파일이 없습니다." }
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

$gameExe = Join-Path $GameDir "Ultima I Unity.exe"
$dataDir = Join-Path $GameDir "Ultima I Unity_Data"
if (-not (Test-Path -LiteralPath $gameExe) -or -not (Test-Path -LiteralPath $dataDir)) {
    throw "게임 설치 폴더가 아닙니다. 패치 파일을 'Ultima I Unity.exe'와 'Ultima I Unity_Data'가 있는 폴더에 압축 해제한 뒤 Install_Korean_Patch.bat를 실행하세요."
}

Write-Host "Ultima I Unity 한국어 패치 v$($manifest.version)" -ForegroundColor Cyan
Write-Host "게임 폴더: $GameDir"

foreach ($f in $manifest.binary_files) {
    $path = Join-Path $GameDir $f.path
    if (-not (Test-Path -LiteralPath $path)) { throw "필수 파일 없음: $($f.path)" }
    $hash = Hash-File $path
    if ($hash -eq $f.patched_sha256) {
        Write-Host "이미 패치됨: $($f.path)" -ForegroundColor DarkGray
        continue
    }
    if ($hash -ne $f.original_sha256) {
        throw "지원하지 않는 게임 버전 또는 변경된 파일입니다: $($f.path)`n현재 SHA256: $hash"
    }
    Backup-Once $path
    $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    try {
        foreach ($p in $f.patches) {
            $bytes = [Convert]::FromBase64String([string]$p.data)
            [void]$fs.Seek([int64]$p.offset, [System.IO.SeekOrigin]::Begin)
            $fs.Write($bytes, 0, $bytes.Length)
        }
    } finally {
        $fs.Dispose()
    }
    $after = Hash-File $path
    if ($after -ne $f.patched_sha256) { throw "바이너리 패치 검증 실패: $($f.path)" }
    Write-Host "완료: $($f.path)" -ForegroundColor Green
}

foreach ($f in $manifest.json_files) {
    $path = Join-Path $GameDir $f.path
    if (-not (Test-Path -LiteralPath $path)) { throw "필수 파일 없음: $($f.path)" }
    $marker = $path + ".u1k-v$($manifest.version)"
    if (Test-Path -LiteralPath $marker) {
        Write-Host "이미 패치됨: $($f.path)" -ForegroundColor DarkGray
        continue
    }
    $hash = Hash-File $path
    if ($hash -ne $f.original_sha256) {
        throw "지원하지 않는 게임 버전 또는 변경된 JSON입니다: $($f.path)`n현재 SHA256: $hash"
    }
    Backup-Once $path
    $obj = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($u in $f.updates) { Set-JsonValue $obj $u.path $u.value }
    $text = $obj | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText($path, $text + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))
    [System.IO.File]::WriteAllText($marker, "Ultima I Unity Korean Patch v$($manifest.version)", (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "완료: $($f.path)" -ForegroundColor Green
}

Write-Host ""
Write-Host "한국어 패치 적용이 완료되었습니다." -ForegroundColor Cyan
Write-Host "원본 백업은 각 파일 옆의 .u1k-original 파일로 보관했습니다."
