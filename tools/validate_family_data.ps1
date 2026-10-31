[CmdletBinding()]
param(
    [string]$DataDir = 'assets/data',
    [string]$PhotoDir = 'assets/photos',
    [switch]$Quiet
)

# Валидатор демо-архива: ловит опечатки до запуска приложения.
# Проверяет JSON, уникальность id, ссылки событий на людей, формат дат,
# существование файлов медиа и совпадение структуры во всех языках.

$ErrorActionPreference = 'Stop'
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$files = @('family_ru.json', 'family_be.json', 'family_uk.json', 'family_en.json')
$memberIds = @{}
$eventIds = @{}

function Resolve-PhotoPath([string]$source) {
    if ([string]::IsNullOrWhiteSpace($source)) { return $null }
    $value = $source.Trim().Replace('\', '/')
    if ($value -match '^(https?://|data:|blob:)') { return $null }
    if ($value.Contains('://')) { return $null }
    $relative = $value.TrimStart('/')
    if ($relative.StartsWith('assets/')) { return $relative }
    if ($relative.StartsWith('photos/')) { return "assets/$relative" }
    return "assets/photos/" + ($relative.Split('/')[-1])
}

foreach ($file in $files) {
    $path = Join-Path $DataDir $file
    if (-not (Test-Path $path)) {
        $errors.Add("${file}: файл не найден")
        continue
    }

    $raw = (Get-Content -Raw -Encoding UTF8 $path) -replace '^\uFEFF', ''

    try {
        $json = $raw | ConvertFrom-Json
    } catch {
        $errors.Add("${file}: невалидный JSON — $($_.Exception.Message)")
        continue
    }

    if ([string]::IsNullOrWhiteSpace($json.familyName)) {
        $errors.Add("${file}: пустой familyName")
    }

    # Ссылки на медиа ищем регуляркой по тексту: так находятся все уровни.
    $found = [regex]::Matches($raw, '"(?:source|photo|familyPhoto)"\s*:\s*"([^"]+)"')
    foreach ($m in $found) {
        $source = $m.Groups[1].Value
        $assetPath = Resolve-PhotoPath $source
        if ($null -eq $assetPath) { continue }
        if (-not (Test-Path $assetPath)) {
            $line = ($raw.Substring(0, $m.Index) -split "`n").Count
            $errors.Add("${file}:${line}: файл не найден — $source -> $assetPath")
        }
    }
    if ($found.Count -eq 0) {
        $warnings.Add("${file}: не найдено ни одной ссылки на медиа")
    }

    $ids = New-Object System.Collections.Generic.List[string]
    $index = 0
    foreach ($member in @($json.members)) {
        $id = [string]$member.id
        if ([string]::IsNullOrWhiteSpace($id)) {
            $errors.Add("${file}: members[$index] без id")
        } elseif ($ids.Contains($id)) {
            $errors.Add("${file}: повторяющийся id человека '$id'")
        } else {
            $ids.Add($id)
        }
        if ($member.birthday -and ([string]$member.birthday) -notmatch '^\d{4}-\d{2}-\d{2}$') {
            $errors.Add("${file}: members[$index].birthday = '$($member.birthday)' (нужен YYYY-MM-DD)")
        }
        $index++
    }
    $memberIds[$file] = ($ids | Sort-Object)

    $events = New-Object System.Collections.Generic.List[string]
    $index = 0
    foreach ($event in @($json.timelineEvents)) {
        $eventKey = [string]$event.id
        if ([string]::IsNullOrWhiteSpace($eventKey)) {
            $errors.Add("${file}: timelineEvents[$index] без id")
        } elseif ($events.Contains($eventKey)) {
            $errors.Add("${file}: повторяющийся id события '$eventKey'")
        } else {
            $events.Add($eventKey)
        }
        if ([string]::IsNullOrWhiteSpace([string]$event.title)) {
            $errors.Add("${file}: timelineEvents[$index] ('$eventKey') без title")
        }
        if (([string]$event.date) -notmatch '^\d{4}-\d{2}-\d{2}$') {
            $errors.Add("${file}: timelineEvents[$index].date = '$($event.date)' (нужен YYYY-MM-DD)")
        }
        $memberId = [string]$event.memberId
        if (-not [string]::IsNullOrWhiteSpace($memberId) -and -not $ids.Contains($memberId)) {
            $errors.Add("${file}: timelineEvents[$index].memberId = '$memberId' — такого человека нет")
        }
        $index++
    }
    $eventIds[$file] = ($events | Sort-Object)
}

# Структура должна совпадать во всех языках: одинаковые наборы id.
$reference = 'family_ru.json'
if ($memberIds.ContainsKey($reference)) {
    foreach ($file in $files) {
        if ($file -eq $reference -or -not $memberIds.ContainsKey($file)) { continue }
        foreach ($item in (Compare-Object $memberIds[$reference] $memberIds[$file])) {
            $side = if ($item.SideIndicator -eq '<=') { "только в $reference" } else { "только в $file" }
            $errors.Add("люди: id '$($item.InputObject)' — $side")
        }
        foreach ($item in (Compare-Object $eventIds[$reference] $eventIds[$file])) {
            $side = if ($item.SideIndicator -eq '<=') { "только в $reference" } else { "только в $file" }
            $errors.Add("события: id '$($item.InputObject)' — $side")
        }
    }
}

if (-not $Quiet) {
    Write-Host ''
    Write-Host '=== Валидация демо-архива ===' -ForegroundColor Cyan
    if ($warnings.Count -gt 0) {
        Write-Host "ПРЕДУПРЕЖДЕНИЯ ($($warnings.Count)):" -ForegroundColor Yellow
        foreach ($warning in $warnings) { Write-Host "  - $warning" -ForegroundColor Yellow }
    }
    if ($errors.Count -eq 0) {
        Write-Host 'ОШИБОК НЕТ — данные корректны.' -ForegroundColor Green
    } else {
        Write-Host "ОШИБКИ ($($errors.Count)):" -ForegroundColor Red
        foreach ($errorItem in $errors) { Write-Host "  - $errorItem" -ForegroundColor Red }
    }
    Write-Host ''
}

if ($errors.Count -gt 0) { exit 1 } else { exit 0 }
