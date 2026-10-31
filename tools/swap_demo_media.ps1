[CmdletBinding()]
param(
    [string]$Source = 'new_media',
    [ValidateSet('ByName', 'ByOrder')][string]$Mode = 'ByOrder',
    [switch]$DryRun,
    [switch]$NoBackup,
    [switch]$AllowPartial
)

# Замена демо-медиа на новые файлы.
# Имена целевых файлов НЕ меняются, поэтому JSON-архивы править не нужно.
# Старые файлы копируются в build\media_backup\<дата> (build/ в .gitignore,
# поэтому бэкап не попадает ни в git, ни в сборку приложения).

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$photoDir = 'assets/photos'
$backupRoot = 'build/media_backup'

# Слоты: имя файла в сборке + роль (для подсказки при генерации картинок).
$slots = @(
    @{ Name = 'b694562f-d59f-4da5-89f7-dc74cc7d6b16.jpg';               Role = 'обложка семьи (16:9)' }
    @{ Name = 'media-023_portrait.jpg';                                  Role = 'портрет человека (4:5)' }
    @{ Name = '0b377b59-c45a-4e28-aac8-b52bdcf517c6.jpg';                Role = 'портрет человека (4:5)' }
    @{ Name = 'media-028_portrait.jpg';                                  Role = 'портрет человека (4:5)' }
    @{ Name = 'dc5ef67a-1523-44d0-98d9-8aacf551dc29.jpg';                Role = 'портрет человека (4:5)' }
    @{ Name = 'media-025_geminigeneratedimage161y3k161y3k.jpg';          Role = 'обложка события «Знакомство»' }
    @{ Name = 'media-024_image.jpg';                                     Role = 'обложка события «Свадьба»' }
    @{ Name = 'Birth1.jpg';                                              Role = 'обложка события «Родилась Маша»' }
    @{ Name = 'media-031_image.jpg';                                     Role = 'обложка события «Первое море» + файл' }
    @{ Name = 'Birth2.jpg';                                              Role = 'обложка события «Родился Ваня»' }
    @{ Name = 'kvart1.jpg';                                              Role = 'обложка события «Новая квартира»' }
    @{ Name = 'media-032_image.jpg';                                     Role = 'обложка события «Поход в горы» + файл' }
    @{ Name = 'media-012_image.jpg';                                     Role = 'файл события «Поход в горы» (camp)'; Aliases = @('camp') }
)

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path $Source)) {
    Write-Host "Папка '$Source' не найдена. Создайте её и положите туда 14 изображений." -ForegroundColor Red
    exit 1
}

$candidates = Get-ChildItem -Path $Source -File |
    Where-Object { $_.Extension -match '^\.(jpg|jpeg|png|webp)$' } |
    Sort-Object Name
if ($candidates.Count -eq 0) {
    Write-Host "В '$Source' нет изображений (jpg/jpeg/png/webp)." -ForegroundColor Red
    exit 1
}

$map = @()
if ($Mode -eq 'ByName') {
    # Нормализуем имена: `photo.jpg.jpg` должно совпасть со слотом `photo.jpg`.
    $byName = @{}
    foreach ($file in $candidates) {
        $normalized = $file.Name
        while ($normalized -match '^(?i)(.+\.(jpg|jpeg|png|webp))\.(jpg|jpeg|png|webp)$') {
            $normalized = $matches[1]
        }
        $key = [IO.Path]::GetFileNameWithoutExtension($normalized).ToLowerInvariant()
        if (-not $byName.ContainsKey($key)) { $byName[$key] = $file }
    }

    foreach ($slot in $slots) {
        $base = [IO.Path]::GetFileNameWithoutExtension($slot.Name)
        $key = $base.ToLowerInvariant()
        $resolved = $null
        if ($byName.ContainsKey($key)) {
            $resolved = $byName[$key]
        } elseif ($slot.ContainsKey('Aliases')) {
            foreach ($alias in $slot.Aliases) {
                $aliasKey = ([string]$alias).ToLowerInvariant()
                if ($byName.ContainsKey($aliasKey)) {
                    $resolved = $byName[$aliasKey]
                    break
                }
            }
        }

        if ($null -ne $resolved) {
            $map += [pscustomobject]@{ Slot = $slot; File = $resolved }
        } elseif ($AllowPartial) {
            $warnings.Add("слот '$base' пропущен: файла нет в '$Source' (остаётся старый)")
        } else {
            $errors.Add("нет файла для слота '$base' (режим ByName)")
        }
    }
} else {
    if ($candidates.Count -lt $slots.Count) {
        $errors.Add("в '$Source' $($candidates.Count) файлов, а нужно $($slots.Count) (режим ByOrder)")
    } else {
        for ($i = 0; $i -lt $slots.Count; $i++) {
            $map += [pscustomobject]@{ Slot = $slots[$i]; File = $candidates[$i] }
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Host 'ОШИБКИ:' -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "  - $e" -ForegroundColor Red }
    exit 1
}

# Проверка размеров и пропорций.
$rows = @()
foreach ($item in $map) {
    $file = $item.File
    $slot = $item.Slot
    $sizeMb = [math]::Round($file.Length / 1MB, 2)
    $width = 0
    $height = 0
    try {
        $image = [System.Drawing.Image]::FromFile($file.FullName)
        $width = $image.Width
        $height = $image.Height
        $image.Dispose()
    } catch {
        $warnings.Add("$($file.Name): не удалось прочитать размеры изображения")
    }

    if ($file.Length -gt 8MB) {
        $errors.Add("$($file.Name): $sizeMb МБ — слишком большой файл (лимит 8 МБ на демо-ассет)")
    } elseif ($file.Length -gt 3MB) {
        $warnings.Add("$($file.Name): $sizeMb МБ — тяжеловато для встроенного ассета")
    }

    $aspect = ''
    if ($width -gt 0 -and $height -gt 0) {
        $isPortrait = $slot.Role -like '*портрет*'
        if ($isPortrait -and $height -le $width) {
            $aspect = 'ожидается вертикальное изображение'
        }
        if (-not $isPortrait -and $width -lt $height) {
            $aspect = 'ожидается горизонтальное изображение'
        }
    }
    if ($aspect) { $warnings.Add("$($file.Name): $aspect ($width x $height), слот: $($slot.Role)") }
    if ($file.Extension -notmatch '^\.jpe?g$') {
        $warnings.Add("$($file.Name): не JPEG — оставляю байты как есть, но имя целевого файла .jpg")
    }

    $rows += [pscustomobject]@{
        Target = $slot.Name
        Role = $slot.Role
        Source = $file.Name
        SizeMb = $sizeMb
        Pixels = if ($width -gt 0) { "$width x $height" } else { '?' }
    }
}

$rows | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

if ($warnings.Count -gt 0) {
    Write-Host "ПРЕДУПРЕЖДЕНИЯ ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host "  - $w" -ForegroundColor Yellow }
}

if ($errors.Count -gt 0) {
    Write-Host "ОШИБКИ ($($errors.Count)):" -ForegroundColor Red
    foreach ($e in $errors) { Write-Host "  - $e" -ForegroundColor Red }
    exit 1
}

if ($DryRun) {
    Write-Host 'DryRun: файлы не изменены.' -ForegroundColor Cyan
    exit 0
}

# Бэкап старых файлов — вне assets, чтобы не попасть в сборку.
if (-not $NoBackup) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupDir = Join-Path $backupRoot $stamp
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    foreach ($item in $map) {
        $target = Join-Path $photoDir $item.Slot.Name
        if (Test-Path $target) {
            Copy-Item -LiteralPath $target -Destination (Join-Path $backupDir $item.Slot.Name) -Force
        }
    }
    Write-Host "Бэкап старых файлов: $backupDir" -ForegroundColor DarkGray
}

foreach ($item in $map) {
    $target = Join-Path $photoDir $item.Slot.Name
    Copy-Item -LiteralPath $item.File.FullName -Destination $target -Force
}

Write-Host "Заменено файлов: $($map.Count)." -ForegroundColor Green
Write-Host 'Дальше: flutter run (полный перезапуск) и Настройки → «Перезагрузить данные».' -ForegroundColor Cyan
exit 0
