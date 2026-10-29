<#
.SYNOPSIS
  Generates every native brand asset from the LiterasiAI logo.

.DESCRIPTION
  Source of truth for the app identity is `assets/image/logo_literasiAI.png`
  (open book + circuit tree on an azure squircle). This script:

    1. extracts the glyph from that PNG (flood-fills the white frame, models
       the field gradient, removes the field colour from the glyph edges),
    2. fits the field gradient with least squares so native icons reproduce
       the original colours instead of approximating them,
    3. rebuilds each asset at its native resolution (no single master that
       gets downscaled and blurred).

  Outputs:
    * iOS       AppIcon.appiconset (15 PNG, RGB / no alpha) + LaunchImage
    * Android   legacy launcher (rounded, transparent corners),
                launch mark, adaptive foreground + monochrome bitmaps
                (layers referenced by the VectorDrawable wrappers in
                android/app/src/main/res/drawable/)
    * Branding  assets/branding/app_icon_1024.png (documentation master)
                assets/branding/app_mark.png (white mark for the splash)

  Regenerated PNGs are committed, so `flutter build` never needs this script.
  Re-run it when the logo or the field gradient changes:

      powershell -ExecutionPolicy Bypass -File tool/generate_brand_assets.ps1

  Requires Windows PowerShell 5.1+ (System.Drawing). Design tool only.

.PARAMETER RepoRoot
  Repository root. Defaults to the parent of this script's folder.
#>
[CmdletBinding()]
param(
  [string]$RepoRoot
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $scriptDir = $PSScriptRoot
  if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
  }
  $RepoRoot = Split-Path -Parent $scriptDir
}

$brandCode = @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Text;

public static class BrandAssets
{
    // The glyph occupies this share of the square canvas. The source logo has
    // it at ~83% of its squircle; 80% keeps the same visual weight with a
    // little breathing room for launcher masks.
    private const double IconGlyphRatio = 0.80;

    // Android launcher icons need extra breathing room under launcher masks.
    private const double AndroidGlyphRatio = 0.68;

    // Adaptive icons show roughly 72dp of the 108dp layer, so 55% of the layer
    // reproduces the logo's glyph-to-field proportion inside the mask.
    private const double AdaptiveGlyphRatio = 0.46;

    public static string[] Generate(string repoRoot, string sourceLogo)
    {
        if (!File.Exists(sourceLogo))
        {
            throw new FileNotFoundException("Logo sumber tidak ditemukan: " + sourceLogo);
        }

        Color top, bottom;
        Bitmap glyph = ExtractGlyph(sourceLogo, out top, out bottom);

        StringBuilder log = new StringBuilder();
        log.AppendLine("glyph " + glyph.Width + "x" + glyph.Height + " px");
        log.AppendLine("field " + Hex(top) + " -> " + Hex(bottom));

        string iosIcons = Path.Combine(repoRoot, "ios/Runner/Assets.xcassets/AppIcon.appiconset");
        string iosLaunch = Path.Combine(repoRoot, "ios/Runner/Assets.xcassets/LaunchImage.imageset");
        string androidRes = Path.Combine(repoRoot, "android/app/src/main/res");
        string branding = Path.Combine(repoRoot, "assets/branding");
        Ensure(iosIcons); Ensure(iosLaunch); Ensure(branding);

        int[] iosSizes = { 20, 40, 60, 29, 58, 87, 40, 80, 120, 120, 180, 76, 152, 167, 1024 };
        string[] iosNames = {
            "Icon-App-20x20@1x.png", "Icon-App-20x20@2x.png", "Icon-App-20x20@3x.png",
            "Icon-App-29x29@1x.png", "Icon-App-29x29@2x.png", "Icon-App-29x29@3x.png",
            "Icon-App-40x40@1x.png", "Icon-App-40x40@2x.png", "Icon-App-40x40@3x.png",
            "Icon-App-60x60@2x.png", "Icon-App-60x60@3x.png", "Icon-App-76x76@1x.png",
            "Icon-App-76x76@2x.png", "Icon-App-83.5x83.5@2x.png", "Icon-App-1024x1024@1x.png"
        };
        for (int i = 0; i < iosSizes.Length; i++)
        {
            SaveIcon(Path.Combine(iosIcons, iosNames[i]), iosSizes[i], glyph, top, bottom,
                IconGlyphRatio, false, false);
        }
        log.AppendLine("ios           15 app icons + 3 launch images");

        string[] launchNames = { "LaunchImage.png", "LaunchImage@2x.png", "LaunchImage@3x.png" };
        int[] launchSizes = { 120, 240, 360 };
        for (int i = 0; i < launchNames.Length; i++)
        {
            SaveGlyphOnly(Path.Combine(iosLaunch, launchNames[i]), launchSizes[i], glyph, 0.92, true);
        }

        string[] densities = { "mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi" };
        int[] densityPx = { 48, 72, 96, 144, 192 };
        int[] adaptivePx = { 108, 162, 216, 324, 432 };
        for (int i = 0; i < densities.Length; i++)
        {
            string folder = Path.Combine(androidRes, "mipmap-" + densities[i]);
            Ensure(folder);
            // Legacy launchers (API < 26) get a rounded icon with transparent
            // corners: a baked square used to leave black wedges behind.
            SaveIcon(Path.Combine(folder, "ic_launcher.png"), densityPx[i], glyph, top, bottom,
                AndroidGlyphRatio, true, true);
            SaveIcon(Path.Combine(folder, "ic_launcher_round.png"), densityPx[i], glyph, top, bottom,
                AndroidGlyphRatio, true, true);
            SaveGlyphOnly(Path.Combine(folder, "launch_mark.png"),
                (int)Math.Round(densityPx[i] * 1.75), glyph, 0.92, true);

            string drawableFolder = Path.Combine(androidRes, "drawable-" + densities[i]);
            Ensure(drawableFolder);
            SaveGlyphOnly(Path.Combine(drawableFolder, "ic_launcher_foreground_glyph.png"),
                adaptivePx[i], glyph, AdaptiveGlyphRatio, false);
            SaveGlyphOnly(Path.Combine(drawableFolder, "ic_launcher_monochrome_glyph.png"),
                adaptivePx[i], glyph, AdaptiveGlyphRatio, true);
        }
        log.AppendLine("android       legacy + round + launch mark + adaptive layers");

        SaveIcon(Path.Combine(branding, "app_icon_1024.png"), 1024, glyph, top, bottom,
            IconGlyphRatio, false, false);
        SaveGlyphOnly(Path.Combine(branding, "app_mark.png"), 384, glyph, 0.92, true);
        log.AppendLine("branding      app_icon_1024.png + app_mark.png");

        glyph.Dispose();
        return log.ToString().Split(new string[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
    }

    private static string Hex(Color c)
    {
        return String.Format("#{0:X2}{1:X2}{2:X2}", c.R, c.G, c.B);
    }

    private static void Ensure(string path)
    {
        if (!Directory.Exists(path)) Directory.CreateDirectory(path);
    }

    // --- glyph extraction ---------------------------------------------------

    private static Bitmap ExtractGlyph(string sourcePath, out Color top, out Color bottom)
    {
        Bitmap src = new Bitmap(sourcePath);
        int w = src.Width, h = src.Height;
        Bitmap bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.CompositingMode = CompositingMode.SourceCopy;
            g.DrawImageUnscaled(src, 0, 0);
        }
        src.Dispose();

        BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadWrite,
            PixelFormat.Format32bppArgb);
        int stride = bd.Stride;
        byte[] buf = new byte[stride * h];
        System.Runtime.InteropServices.Marshal.Copy(bd.Scan0, buf, 0, buf.Length);

        int n = w * h;
        bool[] white = new bool[n];
        for (int i = 0; i < n; i++)
        {
            int o = i * 4;
            white[i] = buf[o + 2] >= 232 && buf[o + 1] >= 232 && buf[o] >= 232;
        }

        // Flood fill the white frame that touches the canvas border. The book
        // pages are white too, but they are enclosed by the blue field.
        bool[] outside = new bool[n];
        int[] queue = new int[n];
        int head = 0, tail = 0;
        for (int x = 0; x < w; x++)
        {
            tail = Seed(x, white, outside, queue, tail);
            tail = Seed(x + (h - 1) * w, white, outside, queue, tail);
        }
        for (int y = 0; y < h; y++)
        {
            tail = Seed(y * w, white, outside, queue, tail);
            tail = Seed(w - 1 + y * w, white, outside, queue, tail);
        }
        while (head < tail)
        {
            int idx = queue[head++];
            int cx = idx % w, cy = idx / w;
            if (cx > 0) tail = Seed(idx - 1, white, outside, queue, tail);
            if (cx < w - 1) tail = Seed(idx + 1, white, outside, queue, tail);
            if (cy > 0) tail = Seed(idx - w, white, outside, queue, tail);
            if (cy < h - 1) tail = Seed(idx + w, white, outside, queue, tail);
        }

        // Shrink the inside mask so the anti-aliased squircle rim (a white/blue
        // blend, far from the field colour) never leaks into the glyph.
        bool[] inside = new bool[n];
        for (int i = 0; i < n; i++) inside[i] = !outside[i];
        for (int pass = 0; pass < 10; pass++)
        {
            bool[] next = new bool[n];
            for (int y = 1; y < h - 1; y++)
            {
                for (int x = 1; x < w - 1; x++)
                {
                    int i = x + y * w;
                    if (!inside[i]) continue;
                    if (inside[i - 1] && inside[i + 1] && inside[i - w] && inside[i + w])
                    {
                        next[i] = true;
                    }
                }
            }
            inside = next;
        }

        // Bilinear field model from four patches that never touch the glyph:
        // the local field colour is what the alpha threshold compares against.
        double[] patchX = { 0.09, 0.91, 0.09, 0.91 };
        double[] patchY = { 0.18, 0.18, 0.82, 0.82 };
        double[] fieldR = new double[4], fieldG = new double[4], fieldB = new double[4];
        for (int k = 0; k < 4; k++)
        {
            double sumR = 0, sumG = 0, sumB = 0;
            int hits = 0;
            int px = (int)(patchX[k] * w), py = (int)(patchY[k] * h);
            for (int yy = py - 10; yy <= py + 10; yy++)
            {
                for (int xx = px - 10; xx <= px + 10; xx++)
                {
                    int i = xx + yy * w, o = i * 4;
                    if (!inside[i]) continue;
                    byte b = buf[o], gg = buf[o + 1], r = buf[o + 2];
                    // Field pixels are blue-dominant and never near-white.
                    if (r > 90 && gg > 170) continue;
                    if (b < 200) continue;
                    sumR += r; sumG += gg; sumB += b; hits++;
                }
            }
            if (hits == 0) { sumR = 0; sumG = 120; sumB = 255; hits = 1; }
            fieldR[k] = sumR / hits; fieldG[k] = sumG / hits; fieldB[k] = sumB / hits;
        }

        // Least-squares fit of the field colour over (x, y): the native icons
        // rebuild the same gradient instead of guessing two stops.
        double count = 0, fx = 0, fy = 0, fxx = 0, fxy = 0, fyy = 0;
        double[] sz = new double[3], sxz = new double[3], syz = new double[3];

        int minX = w, minY = h, maxX = -1, maxY = -1;
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                int i = x + y * w, o = i * 4;
                if (!inside[i]) { buf[o + 3] = 0; continue; }

                double u = (double)x / (w - 1), v = (double)y / (h - 1);
                double rr = fieldR[0] * (1 - u) * (1 - v) + fieldR[1] * u * (1 - v)
                          + fieldR[2] * (1 - u) * v + fieldR[3] * u * v;
                double gg = fieldG[0] * (1 - u) * (1 - v) + fieldG[1] * u * (1 - v)
                          + fieldG[2] * (1 - u) * v + fieldG[3] * u * v;
                double bb = fieldB[0] * (1 - u) * (1 - v) + fieldB[1] * u * (1 - v)
                          + fieldB[2] * (1 - u) * v + fieldB[3] * u * v;

                double dr = buf[o + 2] - rr, dg = buf[o + 1] - gg, db = buf[o] - bb;
                double dist = Math.Sqrt(dr * dr + dg * dg + db * db);
                double a = (dist - 26.0) / 42.0;
                if (a < 0) a = 0;
                if (a > 1) a = 1;
                byte alpha = (byte)Math.Round(a * 255);

                if (alpha == 0)
                {
                    count += 1; fx += x; fy += y; fxx += x * x; fxy += x * y; fyy += y * y;
                    sz[0] += buf[o + 2]; sz[1] += buf[o + 1]; sz[2] += buf[o];
                    sxz[0] += x * buf[o + 2]; sxz[1] += x * buf[o + 1]; sxz[2] += x * buf[o];
                    syz[0] += y * buf[o + 2]; syz[1] += y * buf[o + 1]; syz[2] += y * buf[o];
                }
                else if (a > 0.12)
                {
                    // Straight alpha: remove the field colour the source pixel
                    // already blended in, otherwise the glyph carries a blue
                    // halo when composed on a different field.
                    buf[o + 2] = Unblend(buf[o + 2], rr, a);
                    buf[o + 1] = Unblend(buf[o + 1], gg, a);
                    buf[o] = Unblend(buf[o], bb, a);
                }
                buf[o + 3] = alpha;

                if (alpha > 40)
                {
                    if (x < minX) minX = x;
                    if (x > maxX) maxX = x;
                    if (y < minY) minY = y;
                    if (y > maxY) maxY = y;
                }
            }
        }
        System.Runtime.InteropServices.Marshal.Copy(buf, 0, bd.Scan0, buf.Length);
        bmp.UnlockBits(bd);

        double[] solR = Solve3(
            new double[,] { { count, fx, fy }, { fx, fxx, fxy }, { fy, fxy, fyy } },
            new double[] { sz[0], sxz[0], syz[0] });
        double[] solG = Solve3(
            new double[,] { { count, fx, fy }, { fx, fxx, fxy }, { fy, fxy, fyy } },
            new double[] { sz[1], sxz[1], syz[1] });
        double[] solB = Solve3(
            new double[,] { { count, fx, fy }, { fx, fxx, fxy }, { fy, fxy, fyy } },
            new double[] { sz[2], sxz[2], syz[2] });

        top = Color.FromArgb(
            Clamp255(solR[0]), Clamp255(solG[0]), Clamp255(solB[0]));
        bottom = Color.FromArgb(
            Clamp255(solR[0] + solR[1] * w + solR[2] * h),
            Clamp255(solG[0] + solG[1] * w + solG[2] * h),
            Clamp255(solB[0] + solB[1] * w + solB[2] * h));

        int pad = 6;
        int x0 = Math.Max(0, minX - pad), y0 = Math.Max(0, minY - pad);
        int x1 = Math.Min(w - 1, maxX + pad), y1 = Math.Min(h - 1, maxY + pad);
        Rectangle rect = new Rectangle(x0, y0, x1 - x0 + 1, y1 - y0 + 1);
        Bitmap cropped = new Bitmap(rect.Width, rect.Height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(cropped))
        {
            g.CompositingMode = CompositingMode.SourceCopy;
            g.DrawImage(bmp, new Rectangle(0, 0, rect.Width, rect.Height), rect,
                GraphicsUnit.Pixel);
        }
        cropped.SetResolution(96, 96);
        bmp.Dispose();
        return cropped;
    }

    private static int Seed(int idx, bool[] white, bool[] outside, int[] queue, int tail)
    {
        if (!white[idx] || outside[idx]) return tail;
        outside[idx] = true;
        queue[tail] = idx;
        return tail + 1;
    }

    private static byte Unblend(byte observed, double background, double alpha)
    {
        double value = (observed - (1.0 - alpha) * background) / alpha;
        if (value < 0) value = 0;
        if (value > 255) value = 255;
        return (byte)Math.Round(value);
    }

    private static int Clamp255(double value)
    {
        if (value < 0) return 0;
        if (value > 255) return 255;
        return (int)Math.Round(value);
    }

    private static double[] Solve3(double[,] m, double[] rhs)
    {
        double[,] a = new double[3, 4];
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++) a[i, j] = m[i, j];
            a[i, 3] = rhs[i];
        }
        for (int col = 0; col < 3; col++)
        {
            int pivot = col;
            for (int row = col + 1; row < 3; row++)
            {
                if (Math.Abs(a[row, col]) > Math.Abs(a[pivot, col])) pivot = row;
            }
            if (Math.Abs(a[pivot, col]) < 1e-9) continue;
            for (int j = 0; j < 4; j++)
            {
                double t = a[col, j]; a[col, j] = a[pivot, j]; a[pivot, j] = t;
            }
            for (int row = 0; row < 3; row++)
            {
                if (row == col) continue;
                double f = a[row, col] / a[col, col];
                for (int j = 0; j < 4; j++) a[row, j] -= f * a[col, j];
            }
        }
        double[] sol = new double[3];
        for (int i = 0; i < 3; i++)
        {
            sol[i] = Math.Abs(a[i, i]) < 1e-9 ? 0 : a[i, 3] / a[i, i];
        }
        return sol;
    }

    // --- composition --------------------------------------------------------

    private static void FillField(Graphics g, int size, Color top, Color bottom)
    {
        RectangleF rect = new RectangleF(0, 0, size, size);
        using (LinearGradientBrush brush = new LinearGradientBrush(rect, top, bottom, 45f))
        {
            g.FillRectangle(brush, rect);
        }
    }

    private static Bitmap Monochrome(Bitmap glyph)
    {
        Bitmap copy = new Bitmap(glyph.Width, glyph.Height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(copy))
        {
            g.CompositingMode = CompositingMode.SourceCopy;
            g.DrawImageUnscaled(glyph, 0, 0);
        }
        Rectangle area = new Rectangle(0, 0, copy.Width, copy.Height);
        BitmapData bd = copy.LockBits(area, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        byte[] buf = new byte[bd.Stride * copy.Height];
        System.Runtime.InteropServices.Marshal.Copy(bd.Scan0, buf, 0, buf.Length);
        for (int i = 0; i < buf.Length; i += 4)
        {
            byte b = buf[i], g = buf[i + 1], r = buf[i + 2], a = buf[i + 3];
            // White pages and cyan circuitry stay; the soft field shadow around
            // the book is dropped so a single-colour mark does not render as a
            // grey haze on a flat splash background.
            int minChannel = Math.Min(r, Math.Min(g, b));
            double white = (minChannel - 150) / 60.0;
            double cyan = (g - r - 30) / 60.0;
            double score = Math.Max(white, cyan);
            if (score < 0) score = 0;
            if (score > 1) score = 1;
            buf[i] = 255; buf[i + 1] = 255; buf[i + 2] = 255;
            buf[i + 3] = (byte)Math.Round(a * score);
        }
        System.Runtime.InteropServices.Marshal.Copy(buf, 0, bd.Scan0, buf.Length);
        copy.UnlockBits(bd);
        return copy;
    }

    private static void DrawGlyph(Graphics g, Bitmap glyph, int canvas, double widthRatio, bool white)
    {
        int targetW = (int)Math.Round(canvas * widthRatio);
        int targetH = (int)Math.Round(targetW * (double)glyph.Height / glyph.Width);
        Bitmap source = white ? Monochrome(glyph) : glyph;
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
        g.CompositingQuality = CompositingQuality.HighQuality;
        g.DrawImage(source, (canvas - targetW) / 2, (canvas - targetH) / 2, targetW, targetH);
        if (white) source.Dispose();
    }

    private static void SaveIcon(string path, int size, Bitmap glyph, Color top, Color bottom,
        double ratio, bool alpha, bool rounded)
    {
        PixelFormat format = alpha ? PixelFormat.Format32bppArgb : PixelFormat.Format24bppRgb;
        using (Bitmap canvas = new Bitmap(size, size, format))
        {
            canvas.SetResolution(96, 96);
            using (Graphics g = Graphics.FromImage(canvas))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.Clear(Color.Transparent);
                if (rounded)
                {
                    float radius = (float)(size * 0.225);
                    using (GraphicsPath clip = RoundedRect(size, radius))
                    {
                        g.SetClip(clip);
                    }
                }
                FillField(g, size, top, bottom);
                DrawGlyph(g, glyph, size, ratio, false);
            }
            canvas.Save(path, ImageFormat.Png);
        }
    }

    private static GraphicsPath RoundedRect(int size, float radius)
    {
        float d = radius * 2;
        GraphicsPath path = new GraphicsPath();
        path.AddArc(0, 0, d, d, 180, 90);
        path.AddArc(size - d, 0, d, d, 270, 90);
        path.AddArc(size - d, size - d, d, d, 0, 90);
        path.AddArc(0, size - d, d, d, 90, 90);
        path.CloseFigure();
        return path;
    }

    private static void SaveGlyphOnly(string path, int size, Bitmap glyph, double ratio, bool white)
    {
        using (Bitmap canvas = new Bitmap(size, size, PixelFormat.Format32bppArgb))
        {
            canvas.SetResolution(96, 96);
            using (Graphics g = Graphics.FromImage(canvas))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.Clear(Color.Transparent);
                DrawGlyph(g, glyph, size, ratio, white);
            }
            canvas.Save(path, ImageFormat.Png);
        }
    }
}
'@

Add-Type -TypeDefinition $brandCode -ReferencedAssemblies System.Drawing

$sourceLogo = Join-Path $RepoRoot 'assets/image/logo_literasiAI.png'
$lines = [BrandAssets]::Generate($RepoRoot, $sourceLogo)
foreach ($line in $lines) { Write-Host "  $line" }
Write-Host ''
Write-Host 'Brand assets regenerated from assets/image/logo_literasiAI.png' -ForegroundColor Green
