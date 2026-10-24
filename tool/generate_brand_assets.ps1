<#
.SYNOPSIS
  Generates every native brand asset from one vector mark.

.DESCRIPTION
  Source of truth for the LiterasiAI app icon is THIS SCRIPT, not a binary
  master. It draws the mark (gradient field + white shield + brand-blue check)
  at each target resolution so every PNG is anti-aliased at its native size
  instead of being downscaled from a single bitmap.

  Outputs:
    * iOS       AppIcon.appiconset (15 PNG, RGB / no alpha) + LaunchImage
    * Android   legacy launcher (rounded) + pre-API-31 launch mark
                (adaptive foreground/monochrome are VectorDrawables kept in
                android/app/src/main/res/drawable/)
    * Branding  assets/branding/app_icon_1024.png (documentation master)

  Colours mirror lib/core/constants/app_colors.dart. Generated PNGs are
  committed, so `flutter build` never needs this script. Re-run it only when
  the mark or palette changes:

      powershell -ExecutionPolicy Bypass -File tool/generate_brand_assets.ps1

  Requires Windows PowerShell 5.1+ (System.Drawing). The script is a design
  tool, not part of the app build.

.PARAMETER RepoRoot
  Repository root. Defaults to the parent of this script's folder.
#>
[CmdletBinding()]
param(
  [string]$RepoRoot
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# Windows PowerShell 5.1 does not populate $PSScriptRoot during parameter
# binding, so resolve the repo root here instead.
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $scriptDir = $PSScriptRoot
  if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  }
  $RepoRoot = Split-Path -Parent $scriptDir
}

# --- Palette (must match AppColors) -----------------------------------------
$HeroBegin = [System.Drawing.ColorTranslator]::FromHtml('#2F80ED')
$HeroEnd   = [System.Drawing.ColorTranslator]::FromHtml('#124A9B')
$Primary   = [System.Drawing.ColorTranslator]::FromHtml('#1A73E8')
$White     = [System.Drawing.Color]::White

# Mark proportions relative to the square canvas.
$IconMarkRatio   = 0.545  # full-bleed icons: shield height / canvas
$LaunchMarkRatio = 0.780  # white mark only, transparent canvas

$IosIconDir  = Join-Path $RepoRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$IosLaunch   = Join-Path $RepoRoot 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
$AndroidRes  = Join-Path $RepoRoot 'android/app/src/main/res'
$BrandingDir = Join-Path $RepoRoot 'assets/branding'

function New-Canvas {
  param(
    [int]$Size,
    [System.Drawing.Imaging.PixelFormat]$Format
  )
  $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, $Format)
  $bitmap.SetResolution(96, 96)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.Clear([System.Drawing.Color]::Transparent)
  return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Add-BrandField {
  param([System.Drawing.Graphics]$Graphics, [int]$Size)

  $rect = [System.Drawing.RectangleF]::new(0, 0, $Size, $Size)
  # 45 degrees: HeroBegin top-left -> HeroEnd bottom-right, the same direction
  # as the in-app hero gradient.
  $brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $rect, $HeroBegin, $HeroEnd, [float]45
  )
  $Graphics.FillRectangle($brush, $rect)
  $brush.Dispose()
}

function New-ShieldPath {
  param(
    [double]$CenterX,
    [double]$CenterY,
    [double]$Width,
    [double]$Height
  )

  $hw = $Width / 2.0
  $hh = $Height / 2.0

  # Flat shoulders, near-vertical sides, then two bezier segments converging
  # into a single point. Classic verified-shield silhouette that still reads
  # at 40 px because the outline stays thick.
  $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $path.StartFigure()
  $path.AddLine(
    [float]($CenterX - $hw), [float]($CenterY - $hh),
    [float]($CenterX + $hw), [float]($CenterY - $hh)
  )
  $path.AddLine(
    [float]($CenterX + $hw), [float]($CenterY - $hh),
    [float]($CenterX + $hw), [float]($CenterY + $hh * 0.06)
  )
  # The second control point stays close to the centre line so the two
  # mirrors meet at a real point (~68 degrees) instead of a rounded U.
  $path.AddBezier(
    [float]($CenterX + $hw), [float]($CenterY + $hh * 0.06),
    [float]($CenterX + $hw), [float]($CenterY + $hh * 0.52),
    [float]($CenterX + $hw * 0.42), [float]($CenterY + $hh * 0.74),
    [float]$CenterX, [float]($CenterY + $hh)
  )
  $path.AddBezier(
    [float]$CenterX, [float]($CenterY + $hh),
    [float]($CenterX - $hw * 0.42), [float]($CenterY + $hh * 0.74),
    [float]($CenterX - $hw), [float]($CenterY + $hh * 0.52),
    [float]($CenterX - $hw), [float]($CenterY + $hh * 0.06)
  )
  $path.AddLine(
    [float]($CenterX - $hw), [float]($CenterY + $hh * 0.06),
    [float]($CenterX - $hw), [float]($CenterY - $hh)
  )
  $path.CloseFigure()
  return $path
}

function Add-CheckStroke {
  param(
    [System.Drawing.Graphics]$Graphics,
    [double]$CenterX,
    [double]$CenterY,
    [double]$Width,
    [double]$Height,
    [System.Drawing.Color]$Color,
    [double]$Thickness
  )

  $pen = [System.Drawing.Pen]::new($Color, [float]$Thickness)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $points = [System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new([float]($CenterX - $Width * 0.205), [float]($CenterY + $Height * 0.010)),
    [System.Drawing.PointF]::new([float]($CenterX - $Width * 0.045), [float]($CenterY + $Height * 0.175)),
    [System.Drawing.PointF]::new([float]($CenterX + $Width * 0.240), [float]($CenterY - $Height * 0.200))
  )
  $Graphics.DrawLines($pen, $points)
  $pen.Dispose()
}

function Add-BrandMark {
  param(
    [System.Drawing.Graphics]$Graphics,
    [int]$Size,
    [double]$MarkRatio,
    [ValidateSet('Filled', 'Outline')]
    [string]$Style,
    [System.Drawing.Color]$MarkColor
  )

  $height = $Size * $MarkRatio
  $width = $height * 0.84
  $cx = $Size / 2.0
  $cy = $Size / 2.0

  $path = New-ShieldPath -CenterX $cx -CenterY $cy -Width $width -Height $height

  if ($Style -eq 'Filled') {
    $brush = [System.Drawing.SolidBrush]::new($MarkColor)
    $Graphics.FillPath($brush, $path)
    $brush.Dispose()
    Add-CheckStroke -Graphics $Graphics -CenterX $cx -CenterY $cy `
      -Width $width -Height $height -Color $Primary -Thickness ($height * 0.112)
  }
  else {
    # Monochrome (Android 13 themed icons): outline + check in one ink so the
    # silhouette survives platform tinting.
    $pen = [System.Drawing.Pen]::new($MarkColor, [float]($height * 0.070))
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $Graphics.DrawPath($pen, $path)
    $pen.Dispose()
    Add-CheckStroke -Graphics $Graphics -CenterX $cx -CenterY $cy `
      -Width $width -Height $height -Color $MarkColor -Thickness ($height * 0.088)
  }

  $path.Dispose()
}

function Save-BrandIcon {
  param(
    [string]$Path,
    [int]$Size,
    [switch]$Rounded
  )

  $canvas = New-Canvas -Size $Size -Format ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $graphics = $canvas.Graphics

  if ($Rounded) {
    # Android < API 26 has no mask of its own; bake a squircle-ish radius.
    $radius = [float]($Size * 0.225)
    $diameter = $radius * 2
    $clip = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $clip.AddArc([float]0, [float]0, $diameter, $diameter, 180, 90)
    $clip.AddArc([float]($Size - $diameter), [float]0, $diameter, $diameter, 270, 90)
    $clip.AddArc([float]($Size - $diameter), [float]($Size - $diameter), $diameter, $diameter, 0, 90)
    $clip.AddArc([float]0, [float]($Size - $diameter), $diameter, $diameter, 90, 90)
    $clip.CloseFigure()
    $graphics.SetClip($clip)
    $clip.Dispose()
  }

  Add-BrandField -Graphics $graphics -Size $Size
  Add-BrandMark -Graphics $graphics -Size $Size -MarkRatio $IconMarkRatio `
    -Style Filled -MarkColor $White

  $graphics.Dispose()
  $canvas.Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas.Bitmap.Dispose()
}

function Save-BrandMarkPng {
  param(
    [string]$Path,
    [int]$Size,
    [double]$MarkRatio,
    [ValidateSet('Filled', 'Outline')]
    [string]$Style = 'Filled',
    [System.Drawing.Color]$MarkColor = $White
  )

  $canvas = New-Canvas -Size $Size -Format ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  Add-BrandMark -Graphics $canvas.Graphics -Size $Size -MarkRatio $MarkRatio `
    -Style $Style -MarkColor $MarkColor
  $canvas.Graphics.Dispose()
  $canvas.Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas.Bitmap.Dispose()
}

function Set-OutputFolder {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

# --- iOS app icons (RGB, no alpha — App Store requirement) ------------------
$iosIcons = [ordered]@{
  'Icon-App-20x20@1x.png'     = 20
  'Icon-App-20x20@2x.png'     = 40
  'Icon-App-20x20@3x.png'     = 60
  'Icon-App-29x29@1x.png'     = 29
  'Icon-App-29x29@2x.png'     = 58
  'Icon-App-29x29@3x.png'     = 87
  'Icon-App-40x40@1x.png'     = 40
  'Icon-App-40x40@2x.png'     = 80
  'Icon-App-40x40@3x.png'     = 120
  'Icon-App-60x60@2x.png'     = 120
  'Icon-App-60x60@3x.png'     = 180
  'Icon-App-76x76@1x.png'     = 76
  'Icon-App-76x76@2x.png'     = 152
  'Icon-App-83.5x83.5@2x.png' = 167
  'Icon-App-1024x1024@1x.png' = 1024
}

Write-Host 'iOS app icons' -ForegroundColor Cyan
Set-OutputFolder $IosIconDir
foreach ($entry in $iosIcons.GetEnumerator()) {
  Save-BrandIcon -Path (Join-Path $IosIconDir $entry.Key) -Size $entry.Value
  Write-Host ("  {0,-28} {1,5}px" -f $entry.Key, $entry.Value)
}

# --- iOS launch mark (white shield on the storyboard's brand background) ----
Write-Host 'iOS launch mark' -ForegroundColor Cyan
Set-OutputFolder $IosLaunch
$iosLaunchScales = @{ 'LaunchImage.png' = 120; 'LaunchImage@2x.png' = 240; 'LaunchImage@3x.png' = 360 }
foreach ($entry in $iosLaunchScales.GetEnumerator()) {
  Save-BrandMarkPng -Path (Join-Path $IosLaunch $entry.Key) -Size $entry.Value -MarkRatio $LaunchMarkRatio
  Write-Host ("  {0,-28} {1,5}px" -f $entry.Key, $entry.Value)
}

# --- Android legacy launcher + round variant --------------------------------
Write-Host 'Android legacy launcher icons' -ForegroundColor Cyan
$androidDensities = [ordered]@{ 'mdpi' = 48; 'hdpi' = 72; 'xhdpi' = 96; 'xxhdpi' = 144; 'xxxhdpi' = 192 }
foreach ($density in $androidDensities.GetEnumerator()) {
  $folder = Join-Path $AndroidRes ("mipmap-" + $density.Key)
  Set-OutputFolder $folder
  Save-BrandIcon -Path (Join-Path $folder 'ic_launcher.png') -Size $density.Value -Rounded
  Save-BrandIcon -Path (Join-Path $folder 'ic_launcher_round.png') -Size $density.Value -Rounded
  Write-Host ("  mipmap-{0,-9} {1,4}px  ic_launcher + ic_launcher_round" -f $density.Key, $density.Value)
}

# --- Android launch mark (pre-API-31 window background) ---------------------
# Adaptive layers (foreground/monochrome) are hand-authored VectorDrawables in
# android/app/src/main/res/drawable/ so the Android 12 splash and the launcher
# stay crisp at every density; only this transparent launch mark is a bitmap.
Write-Host 'Android launch marks' -ForegroundColor Cyan
$adaptiveSizes = [ordered]@{ 'mdpi' = 108; 'hdpi' = 162; 'xhdpi' = 216; 'xxhdpi' = 324; 'xxxhdpi' = 432 }
foreach ($density in $adaptiveSizes.GetEnumerator()) {
  $folder = Join-Path $AndroidRes ("mipmap-" + $density.Key)
  Set-OutputFolder $folder
  Save-BrandMarkPng -Path (Join-Path $folder 'launch_mark.png') -Size ([int]($density.Value * 0.78)) -MarkRatio 0.86
  Write-Host ("  mipmap-{0,-9} launch_mark" -f $density.Key)
}

# --- Documentation master + Flutter splash mark -----------------------------
Write-Host 'Branding assets' -ForegroundColor Cyan
Set-OutputFolder $BrandingDir
Save-BrandIcon -Path (Join-Path $BrandingDir 'app_icon_1024.png') -Size 1024
Save-BrandMarkPng -Path (Join-Path $BrandingDir 'app_mark.png') -Size 384 -MarkRatio 0.90
Write-Host '  assets/branding/app_icon_1024.png  1024px'
Write-Host '  assets/branding/app_mark.png        384px (dipakai SplashScreen)'

Write-Host ''
Write-Host 'Done. Generated assets are deterministic: re-running rewrites identical PNGs.' -ForegroundColor Green
