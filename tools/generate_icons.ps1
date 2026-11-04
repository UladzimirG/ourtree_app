# Генерация всех иконок приложения из одного мастер-файла.
#
# Мастер: design/app_icon_master.jpg (квадрат или близкий к нему, без alpha).
# Скрипт делает квадратные PNG нужных размеров, adaptive-слои Android, иконки
# iOS/macOS, web/PWA и multi-size .ico для Windows, а также обновляет цвет
# подложки adaptive-иконки по фону мастера.
#
# Запуск: powershell -ExecutionPolicy Bypass -File tools/generate_icons.ps1

param(
  # Мастер иконки. По умолчанию — исходный; для крафтового фона используется
  # design/app_icon_master_kraft.png (рисунок «карточкой» на фоне приложения).
  [string]$MasterFile = 'design/app_icon_master.jpg'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$masterPath = if ([System.IO.Path]::IsPathRooted($MasterFile)) { $MasterFile } else { Join-Path $root $MasterFile }
if (-not (Test-Path $masterPath)) { throw "Не найден мастер: $masterPath" }

function Get-CornerColor([System.Drawing.Image]$img) {
  $bmp = New-Object System.Drawing.Bitmap $img
  $samples = @(
    $bmp.GetPixel(2, 2),
    $bmp.GetPixel($bmp.Width - 3, 2),
    $bmp.GetPixel(2, $bmp.Height - 3),
    $bmp.GetPixel($bmp.Width - 3, $bmp.Height - 3)
  )
  $r = [int](($samples | ForEach-Object { $_.R } | Measure-Object -Average).Average)
  $g = [int](($samples | ForEach-Object { $_.G } | Measure-Object -Average).Average)
  $b = [int](($samples | ForEach-Object { $_.B } | Measure-Object -Average).Average)
  $bmp.Dispose()
  return [System.Drawing.Color]::FromArgb(255, $r, $g, $b)
}

# $ratio — какую часть холста занимает мастер (1.0 — вплотную, 0.8 — с полями).
function New-Icon([System.Drawing.Image]$img, [int]$size, [double]$ratio, [System.Drawing.Color]$color) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear($color)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

  $scale = [Math]::Min($size / $img.Width, $size / $img.Height) * $ratio
  $w = [int][Math]::Round($img.Width * $scale)
  $h = [int][Math]::Round($img.Height * $scale)
  $x = [int](($size - $w) / 2)
  $y = [int](($size - $h) / 2)
  $g.DrawImage($img, $x, $y, $w, $h)
  $g.Dispose()
  return $bmp
}

function New-RoundIcon([System.Drawing.Image]$img, [int]$size, [System.Drawing.Color]$color) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

  $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
  $clip.AddEllipse(0, 0, $size, $size)
  $g.SetClip($clip)
  $g.Clear($color)

  $scale = [Math]::Min($size / $img.Width, $size / $img.Height)
  $w = [int][Math]::Round($img.Width * $scale)
  $h = [int][Math]::Round($img.Height * $scale)
  $g.DrawImage($img, [int](($size - $w) / 2), [int](($size - $h) / 2), $w, $h)

  $g.Dispose()
  $clip.Dispose()
  return $bmp
}

function Save-Png([System.Drawing.Bitmap]$bmp, [string]$target) {
  $dir = Split-Path -Parent $target
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $bmp.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

# Обрезает белые поля мастера по границам логотипа. Без этого на иконке
# остаётся много пустого места, и дерево кажется крошечным.
function Get-CroppedMaster([System.Drawing.Image]$img) {
  $bmp = New-Object System.Drawing.Bitmap $img
  $minX = $bmp.Width
  $minY = $bmp.Height
  $maxX = -1
  $maxY = -1
  $step = 4
  for ($y = 0; $y -lt $bmp.Height; $y += $step) {
    for ($x = 0; $x -lt $bmp.Width; $x += $step) {
      $c = $bmp.GetPixel($x, $y)
      $delta = [Math]::Abs($c.R - 254) + [Math]::Abs($c.G - 255) +
        [Math]::Abs($c.B - 254)
      if ($delta -gt 24) {
        if ($x -lt $minX) { $minX = $x }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($y -gt $maxY) { $maxY = $y }
      }
    }
  }
  $bmp.Dispose()
  if ($maxX -lt 0) { return $img }

  $size = [Math]::Max($maxX - $minX, $maxY - $minY)
  $pad = [int]($size * 0.07)
  $left = [Math]::Max(0, $minX - $pad)
  $top = [Math]::Max(0, $minY - $pad)
  $right = [Math]::Min($img.Width - 1, $maxX + $pad)
  $bottom = [Math]::Min($img.Height - 1, $maxY + $pad)
  $rect = New-Object System.Drawing.Rectangle $left, $top,
    ($right - $left), ($bottom - $top)

  $cropped = New-Object System.Drawing.Bitmap ($rect.Width), ($rect.Height)
  $g = [System.Drawing.Graphics]::FromImage($cropped)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $rect.Width, $rect.Height),
    $rect, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  return $cropped
}

# Логотип на splash-экране: не квадрат, а холст нужного размера.
function New-Splash([System.Drawing.Image]$img, [int]$width, [int]$height,
  [System.Drawing.Color]$color) {
  $bmp = New-Object System.Drawing.Bitmap $width, $height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear($color)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

  $scale = [Math]::Min($width / $img.Width, $height / $img.Height) * 0.78
  $w = [int][Math]::Round($img.Width * $scale)
  $h = [int][Math]::Round($img.Height * $scale)
  $x = [int](($width - $w) / 2)
  $y = [int](($height - $h) / 2)
  $g.DrawImage($img, $x, $y, $w, $h)
  $g.Dispose()
  return $bmp
}

$master = [System.Drawing.Image]::FromFile($masterPath)
# Фон иконки берём из угла мастера: для крафтового мастера это цвет фона
# приложения, поэтому иконка, splash и подложка adaptive-иконки совпадают с UI.
$cornerBmp = New-Object System.Drawing.Bitmap($masterPath)
$corner = $cornerBmp.GetPixel(2, 2)
$cornerBmp.Dispose()

# Исходный мастер почти белый: обрезаем поля, чтобы рисунок был крупнее.
# Крафтовый мастер уже скомпонован — его не трогаем.
$isWhiteMaster = $corner.R -gt 240 -and $corner.G -gt 240 -and $corner.B -gt 235
if ($isWhiteMaster) {
  $master = Get-CroppedMaster $master
}

$bg = if ($isWhiteMaster) {
  # Тёплый бумажный фон вместо почти белого: дерево видно на белом лаунчере.
  [System.Drawing.Color]::FromArgb(255, 255, 244, 222)
} else {
  [System.Drawing.Color]::FromArgb(255, $corner.R, $corner.G, $corner.B)
}
Write-Host ("Фон иконки: #{0:X2}{1:X2}{2:X2}" -f $bg.R, $bg.G, $bg.B)

# --- Android: legacy + adaptive ---------------------------------------------
$legacy = @{ 'mdpi' = 48; 'hdpi' = 72; 'xhdpi' = 96; 'xxhdpi' = 144; 'xxxhdpi' = 192 }
foreach ($density in $legacy.Keys) {
  $size = $legacy[$density]
  $base = "android/app/src/main/res/mipmap-$density"
  Save-Png (New-Icon $master $size 1.0 $bg) (Join-Path $root "$base/ic_launcher.png")
  Save-Png (New-RoundIcon $master $size $bg) (Join-Path $root "$base/ic_launcher_round.png")
}

# Foreground: холст 108dp, контент в безопасной зоне (66% от 108dp = 72dp).
$foregrounds = @{ 'mdpi' = 108; 'hdpi' = 162; 'xhdpi' = 216; 'xxhdpi' = 324; 'xxxhdpi' = 432 }
foreach ($density in $foregrounds.Keys) {
  $size = $foregrounds[$density]
  $base = "android/app/src/main/res/mipmap-$density"
  Save-Png (New-Icon $master $size 0.80 $bg) (Join-Path $root "$base/ic_launcher_foreground.png")
}

# --- Android splash ----------------------------------------------------------
Save-Png (New-Icon $master 512 1.0 $bg) `
  (Join-Path $root 'android/app/src/main/res/drawable-nodpi/launch_logo.png')

# --- iOS --------------------------------------------------------------------
$ios = @{
  'Icon-App-20x20@1x.png' = 20; 'Icon-App-20x20@2x.png' = 40; 'Icon-App-20x20@3x.png' = 60
  'Icon-App-29x29@1x.png' = 29; 'Icon-App-29x29@2x.png' = 58; 'Icon-App-29x29@3x.png' = 87
  'Icon-App-40x40@1x.png' = 40; 'Icon-App-40x40@2x.png' = 80; 'Icon-App-40x40@3x.png' = 120
  'Icon-App-60x60@2x.png' = 120; 'Icon-App-60x60@3x.png' = 180
  'Icon-App-76x76@1x.png' = 76; 'Icon-App-76x76@2x.png' = 152
  'Icon-App-83.5x83.5@2x.png' = 167
  'Icon-App-1024x1024@1x.png' = 1024
}
foreach ($name in $ios.Keys) {
  $size = $ios[$name]
  $target = "ios/Runner/Assets.xcassets/AppIcon.appiconset/$name"
  Save-Png (New-Icon $master $size 1.0 $bg) (Join-Path $root $target)
}

# --- iOS launch image -------------------------------------------------------
$launchDir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
Save-Png (New-Splash $master 168 185 $bg) `
  (Join-Path $root "$launchDir/LaunchImage.png")
Save-Png (New-Splash $master 336 370 $bg) `
  (Join-Path $root "$launchDir/LaunchImage@2x.png")
Save-Png (New-Splash $master 504 555 $bg) `
  (Join-Path $root "$launchDir/LaunchImage@3x.png")

# --- macOS ------------------------------------------------------------------
foreach ($size in @(16, 32, 64, 128, 256, 512, 1024)) {
  $target = "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png"
  Save-Png (New-Icon $master $size 0.92 $bg) (Join-Path $root $target)
}

# --- Web / PWA --------------------------------------------------------------
Save-Png (New-Icon $master 192 1.0 $bg) (Join-Path $root 'web/icons/Icon-192.png')
Save-Png (New-Icon $master 512 1.0 $bg) (Join-Path $root 'web/icons/Icon-512.png')
Save-Png (New-Icon $master 192 0.80 $bg) (Join-Path $root 'web/icons/Icon-maskable-192.png')
Save-Png (New-Icon $master 512 0.80 $bg) (Join-Path $root 'web/icons/Icon-maskable-512.png')
Save-Png (New-Icon $master 180 1.0 $bg) (Join-Path $root 'web/icons/Icon-180.png')
Save-Png (New-Icon $master 32 1.0 $bg) (Join-Path $root 'web/favicon.png')

# --- Windows .ico -----------------------------------------------------------
function Write-Ico([string]$target, [int[]]$sizes) {
  $frames = @()
  foreach ($s in $sizes) {
    $bmp = New-Icon $master $s 1.0 $bg
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $frames += ,@($s, $ms.ToArray())
    $bmp.Dispose(); $ms.Dispose()
  }

  $fs = [System.IO.File]::Create($target)
  $bw = New-Object System.IO.BinaryWriter $fs
  $bw.Write([UInt16]0); $bw.Write([UInt16]1); $bw.Write([UInt16]$frames.Count)
  $offset = 6 + 16 * $frames.Count
  foreach ($f in $frames) {
    $s = [int]$f[0]; $bytes = [byte[]]$f[1]
    $dim = if ($s -ge 256) { 0 } else { $s }
    $bw.Write([byte]$dim); $bw.Write([byte]$dim)
    $bw.Write([byte]0); $bw.Write([byte]0)
    $bw.Write([UInt16]1); $bw.Write([UInt16]32)
    $bw.Write([UInt32]$bytes.Length); $bw.Write([UInt32]$offset)
    $offset += $bytes.Length
  }
  foreach ($f in $frames) { $bw.Write([byte[]]$f[1]) }
  $bw.Flush(); $bw.Close(); $fs.Close()
}
Write-Ico (Join-Path $root 'windows/runner/resources/app_icon.ico') @(16, 24, 32, 48, 64, 128, 256)

# --- Store master -----------------------------------------------------------
Save-Png (New-Icon $master 1024 1.0 $bg) (Join-Path $root 'design/app_icon_1024.png')

# --- Android background color ----------------------------------------------
$colorsXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Фон adaptive-иконки: совпадает с фоном мастера. -->
    <color name="ic_launcher_background">#{0:X2}{1:X2}{2:X2}</color>
</resources>
"@ -f $bg.R, $bg.G, $bg.B
[System.IO.File]::WriteAllText((Join-Path $root 'android/app/src/main/res/values/colors.xml'), $colorsXml, (New-Object System.Text.UTF8Encoding($false)))

$master.Dispose()
Write-Host 'Готово: иконки перегенерированы.'