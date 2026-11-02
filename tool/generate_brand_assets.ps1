<#
.SYNOPSIS
  Generates every native brand asset from the LiterasiAI logo.

.DESCRIPTION
  Two sources, each used for what it actually is:

    * `assets/image/logo_literasiAI.png` is the reference artwork for the app
      icon. Its glyph is extracted from the blue field (the white frame is
      flood-filled away, the field colour already blended into the
      anti-aliased edges is removed) and the field gradient is fitted with
      least squares, so launcher icons keep the artwork that was already
      approved and reproduce the brand colours instead of guessing two stops.
    * `assets/image/logo_literasiAI_white.png` is the master *shape* for every
      white mark (splash / launch / share card / monochrome layer). It is a
      pure-white glyph on a transparent canvas, so it is used as-is (cropped,
      RGB normalised to white, alpha preserved). Nothing is traced, flood
      filled, or re-coloured from a screenshot, which is what used to mangle
      the mark.

  The app icon therefore stays full colour, while every white mark (splash /
  launch / share card / monochrome layer) is drawn from the same white shape,
  so the splash logo can never drift between screens.

  Outputs:
    * iOS       AppIcon.appiconset (15 PNG, RGB / no alpha) + LaunchImage
    * Android   legacy launcher (rounded, transparent corners),
                launch mark, splash mark, adaptive foreground + monochrome
                bitmaps (layers referenced by the layer-list wrappers in
                android/app/src/main/res/drawable/)
    * Windows   windows/runner/resources/app_icon.ico (multi-size, PNG frames)
    * macOS     AppIcon.appiconset (squircle on transparent, Big Sur grid)
    * Web       icons/Icon-{192,512}.png, maskable variants, favicon.png
    * Branding  assets/branding/app_icon_1024.png (colour icon master)
                assets/branding/app_mark.png (tight white mark for the splash
                and the share card: the canvas hugs the glyph, so a widget
                size of N dp renders an N dp glyph)

  Regenerated PNGs are committed, so `flutter build` never needs this script.
  Re-run it when either logo file changes:

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
    // Glyph width as a share of the square canvas. The colour glyph is
    // 1.315:1 (wider than tall), so a single width ratio keeps the visual
    // weight the same as the previous square-ish mark instead of shrinking it.
    private const double IconGlyphRatio = 0.80;

    // Android legacy launchers crop less than adaptive ones; a slightly
    // wider glyph still leaves breathing room inside the rounded mask.
    private const double AndroidGlyphRatio = 0.68;

    // Adaptive icons show roughly 72dp of the 108dp layer, so 46% of the
    // layer reproduces the logo's glyph-to-field proportion inside the mask.
    private const double AdaptiveGlyphRatio = 0.46;

    // Native launch marks (Android < 31 / iOS LaunchImage) are centred in a
    // square canvas that the platform positions as a whole, so a calm margin
    // inside the bitmap is what defines their visual size.
    private const double MarkGlyphRatio = 0.82;

    // Padding of the tight splash mark, in pixels of its 384px glyph. The
    // canvas hugs the glyph so the Flutter splash can size it directly.
    private const int MarkPadPx = 4;

    // Android 12 enlarges the intrinsic bitmap when displaying
    // windowSplashScreenAnimatedIcon. Device capture showed a 0.35 asset ratio
    // rendered as a ~173dp glyph, so 0.20 produces a ~100dp mark like Flutter.
    private const double SplashGlyphRatio = 0.20;

    // Launcher-style icons (Windows / web). Web icons are full-bleed because
    // the browser applies the mask; maskable variants keep the glyph inside
    // the safe zone of that mask.
    private const double WebGlyphRatio = 0.80;
    private const double MaskableGlyphRatio = 0.52;

    // macOS Big Sur icon grid: the rounded square covers ~80.5% of the canvas
    // and is centred with transparent surroundings instead of being masked.
    private const double MacIconContent = 0.805;
    private const double MacIconRadius = 0.225;

    public static string[] Generate(string repoRoot, string colorLogo, string whiteLogo)
    {
        if (!File.Exists(colorLogo))
        {
            throw new FileNotFoundException("Logo sumber (field) tidak ditemukan: " + colorLogo);
        }
        if (!File.Exists(whiteLogo))
        {
            throw new FileNotFoundException("Logo putih (mark) tidak ditemukan: " + whiteLogo);
        }

        Color top, bottom;
        Bitmap iconGlyph = ExtractGlyph(colorLogo, out top, out bottom);
        Bitmap markGlyph = LoadWhiteGlyph(whiteLogo);

        StringBuilder log = new StringBuilder();
        log.AppendLine("icon glyph " + iconGlyph.Width + "x" + iconGlyph.Height
            + " px (berwarna, diekstrak dari logo)");
        log.AppendLine("mark glyph " + markGlyph.Width + "x" + markGlyph.Height
            + " px (putih, dari master)");
        log.AppendLine("field " + Hex(top) + " -> " + Hex(bottom));

        string iosIcons = Path.Combine(repoRoot, "ios/Runner/Assets.xcassets/AppIcon.appiconset");
        string iosLaunch = Path.Combine(repoRoot, "ios/Runner/Assets.xcassets/LaunchImage.imageset");
        string androidRes = Path.Combine(repoRoot, "android/app/src/main/res");
        string branding = Path.Combine(repoRoot, "assets/branding");
        string windowsIcon = Path.Combine(repoRoot, "windows/runner/resources");
        string macIcons = Path.Combine(repoRoot, "macos/Runner/Assets.xcassets/AppIcon.appiconset");
        string webIcons = Path.Combine(repoRoot, "web/icons");
        string webRoot = Path.Combine(repoRoot, "web");
        Ensure(iosIcons); Ensure(iosLaunch); Ensure(branding);
        Ensure(windowsIcon); Ensure(macIcons); Ensure(webIcons); Ensure(webRoot);

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
            SaveIcon(Path.Combine(iosIcons, iosNames[i]), iosSizes[i], iconGlyph, top, bottom,
                IconGlyphRatio, false, false);
        }
        log.AppendLine("ios           15 app icons + 3 launch images");

        string[] launchNames = { "LaunchImage.png", "LaunchImage@2x.png", "LaunchImage@3x.png" };
        int[] launchSizes = { 120, 240, 360 };
        for (int i = 0; i < launchNames.Length; i++)
        {
            SaveGlyphOnly(Path.Combine(iosLaunch, launchNames[i]), launchSizes[i], markGlyph,
                MarkGlyphRatio);
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
            SaveIcon(Path.Combine(folder, "ic_launcher.png"), densityPx[i], iconGlyph, top, bottom,
                AndroidGlyphRatio, true, true);
            SaveIcon(Path.Combine(folder, "ic_launcher_round.png"), densityPx[i], iconGlyph,
                top, bottom, AndroidGlyphRatio, true, true);
            // Native launch mark: 120dp canvas so the mark matches the iOS
            // LaunchImage (120pt) and the Flutter splash (120 logical px),
            // with no size jump while the native splash hands off.
            SaveGlyphOnly(Path.Combine(folder, "launch_mark.png"),
                (int)Math.Round(densityPx[i] * 2.5), markGlyph, MarkGlyphRatio);

            string drawableFolder = Path.Combine(androidRes, "drawable-" + densities[i]);
            Ensure(drawableFolder);
            SaveGlyphOnly(Path.Combine(drawableFolder, "ic_launcher_foreground_glyph.png"),
                adaptivePx[i], iconGlyph, AdaptiveGlyphRatio);
            SaveGlyphOnly(Path.Combine(drawableFolder, "ic_launcher_monochrome_glyph.png"),
                adaptivePx[i], markGlyph, AdaptiveGlyphRatio);
            // Android 12 splash icon: the platform renders it on a 288dp
            // canvas and keeps only the centre 192dp circle, so the glyph
            // needs its own, smaller ratio (see SplashGlyphRatio).
            SaveGlyphOnly(Path.Combine(drawableFolder, "splash_mark_glyph.png"),
                (int)Math.Round(densityPx[i] * 6.0), markGlyph, SplashGlyphRatio);
        }
        log.AppendLine("android       legacy + round + launch mark + adaptive layers");

        SaveIcon(Path.Combine(branding, "app_icon_1024.png"), 1024, iconGlyph, top, bottom,
            IconGlyphRatio, false, false);
        SaveTightMark(Path.Combine(branding, "app_mark.png"), markGlyph, 384, MarkPadPx);

        // Windows executable icon: several sizes in one ICO so Explorer, the
        // taskbar and the title bar all have a native frame to pick from.
        SaveIco(Path.Combine(windowsIcon, "app_icon.ico"),
            new int[] { 16, 24, 32, 48, 64, 128, 256 },
            iconGlyph, top, bottom, IconGlyphRatio);

        // macOS icons are not masked by the OS: draw the squircle ourselves on
        // a transparent canvas, following the Big Sur icon grid.
        int[] macSizes = { 16, 32, 64, 128, 256, 512, 1024 };
        for (int i = 0; i < macSizes.Length; i++)
        {
            SaveMacIcon(Path.Combine(macIcons, "app_icon_" + macSizes[i] + ".png"),
                macSizes[i], iconGlyph, top, bottom, IconGlyphRatio);
        }

        // Web: full-bleed icons for the manifest/favicon plus maskable variants
        // whose glyph stays inside the browser's safe circle.
        SaveIcon(Path.Combine(webIcons, "Icon-192.png"), 192, iconGlyph, top, bottom,
            WebGlyphRatio, false, false);
        SaveIcon(Path.Combine(webIcons, "Icon-512.png"), 512, iconGlyph, top, bottom,
            WebGlyphRatio, false, false);
        // Maskable variants: browsers crop these to a circle, so they use the
        // white mark over the brand field instead of the square artwork (which
        // would otherwise show its own squircle edge inside the mask).
        SaveMarkField(Path.Combine(webIcons, "Icon-maskable-192.png"), 192, markGlyph,
            MaskableGlyphRatio, top, bottom);
        SaveMarkField(Path.Combine(webIcons, "Icon-maskable-512.png"), 512, markGlyph,
            MaskableGlyphRatio, top, bottom);
        SaveIcon(Path.Combine(webRoot, "favicon.png"), 32, iconGlyph, top, bottom,
            WebGlyphRatio, false, false);

        log.AppendLine("branding      app_icon_1024.png + app_mark.png (rapat)");
        log.AppendLine("windows       app_icon.ico (16-256)");
        log.AppendLine("macos         app_icon 16-1024 (squircle transparan)");
        log.AppendLine("web           Icon-192/512 + maskable + favicon");

        iconGlyph.Dispose();
        markGlyph.Dispose();
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

    // --- sources -------------------------------------------------------------

    /// Loads the white master and keeps its alpha as the glyph silhouette.
    /// RGB is forced to white so anti-aliased export fringes cannot carry a
    /// blue halo onto the brand field.
    private static Bitmap LoadWhiteGlyph(string sourcePath)
    {
        Bitmap src = new Bitmap(sourcePath);
        int w = src.Width, h = src.Height;
        Bitmap bmp = ToArgb(src);
        src.Dispose();

        BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadWrite,
            PixelFormat.Format32bppArgb);
        int stride = bd.Stride;
        byte[] buf = new byte[stride * h];
        System.Runtime.InteropServices.Marshal.Copy(bd.Scan0, buf, 0, buf.Length);

        int minX = w, minY = h, maxX = -1, maxY = -1;
        for (int y = 0; y < h; y++)
        {
            int row = y * stride;
            for (int x = 0; x < w; x++)
            {
                int o = row + x * 4;
                byte a = buf[o + 3];
                buf[o] = 255; buf[o + 1] = 255; buf[o + 2] = 255;
                if (a <= 8) { buf[o + 3] = 0; continue; }
                if (x < minX) minX = x;
                if (x > maxX) maxX = x;
                if (y < minY) minY = y;
                if (y > maxY) maxY = y;
            }
        }
        System.Runtime.InteropServices.Marshal.Copy(buf, 0, bd.Scan0, buf.Length);
        bmp.UnlockBits(bd);

        if (maxX < 0) throw new InvalidDataException("Logo putih tidak punya piksel opaque.");

        int pad = 2;
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

    /// Extracts the colour glyph from the reference logo and, in the same
    /// pass, fits the blue field gradient:
    ///
    /// 1. flood fill the white frame that touches the canvas border (the book
    ///    pages are white too, but they are enclosed by the field),
    /// 2. erode the inside mask so the anti-aliased squircle rim never leaks
    ///    into the glyph,
    /// 3. model the field from four patches that never touch the glyph, then
    ///    turn every pixel into straight alpha against that local field
    ///    colour (removing the blue already blended into the edges),
    /// 4. least-squares fit the field colour over (x, y) so launcher icons
    ///    rebuild the same gradient instead of guessing two stops.
    ///
    /// The result is the artwork reviewers already approved; it is only used
    /// for the launcher icons. Splash marks come from the white master.
    private static Bitmap ExtractGlyph(string sourcePath, out Color top, out Color bottom)
    {
        top = Color.FromArgb(6, 181, 255);
        bottom = Color.FromArgb(6, 47, 230);

        Bitmap src = new Bitmap(sourcePath);
        int w = src.Width, h = src.Height;
        Bitmap bmp = ToArgb(src);
        src.Dispose();

        BitmapData bd = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadWrite,
            PixelFormat.Format32bppArgb);
        int stride = bd.Stride;
        byte[] buf = new byte[stride * h];
        System.Runtime.InteropServices.Marshal.Copy(bd.Scan0, buf, 0, buf.Length);

        int n = w * h;
        bool[] white = new bool[n];
        for (int y = 0; y < h; y++)
        {
            int row = y * stride;
            for (int x = 0; x < w; x++)
            {
                int o = row + x * 4;
                white[x + y * w] = buf[o] >= 232 && buf[o + 1] >= 232 && buf[o + 2] >= 232;
            }
        }

        // Flood fill the white frame that touches the canvas border, then
        // erode so the anti-aliased squircle rim never enters the sample.
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
                    if (inside[i] && inside[i - 1] && inside[i + 1]
                        && inside[i - w] && inside[i + w])
                    {
                        next[i] = true;
                    }
                }
            }
            inside = next;
        }

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
                    int i = xx + yy * w;
                    if (!inside[i]) continue;
                    int o = yy * stride + xx * 4;
                    int b = buf[o], g = buf[o + 1], r = buf[o + 2];
                    // Field pixels are blue-dominant and never near-white.
                    if (r > 90 && g > 170) continue;
                    if (b < 200) continue;
                    sumR += r; sumG += g; sumB += b; hits++;
                }
            }
            if (hits == 0) { sumR = 0; sumG = 120; sumB = 255; hits = 1; }
            fieldR[k] = sumR / hits; fieldG[k] = sumG / hits; fieldB[k] = sumB / hits;
        }

        double count = 0, fx = 0, fy = 0, fxx = 0, fxy = 0, fyy = 0;
        double[] sz = new double[3], sxz = new double[3], syz = new double[3];

        int minX = w, minY = h, maxX = -1, maxY = -1;
        for (int y = 0; y < h; y++)
        {
            int row = y * stride;
            for (int x = 0; x < w; x++)
            {
                int i = x + y * w;
                int o = row + x * 4;
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
                    // Flat field pixel: safe sample for the gradient fit.
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

        if (maxX < 0) throw new InvalidDataException("Logo tidak punya piksel opaque.");

        if (count >= 100)
        {
            double[,] m = new double[,] { { count, fx, fy }, { fx, fxx, fxy }, { fy, fxy, fyy } };
            double[] solR = Solve3(m, new double[] { sz[0], sxz[0], syz[0] });
            double[] solG = Solve3(m, new double[] { sz[1], sxz[1], syz[1] });
            double[] solB = Solve3(m, new double[] { sz[2], sxz[2], syz[2] });

            top = Color.FromArgb(Clamp255(solR[0]), Clamp255(solG[0]), Clamp255(solB[0]));
            bottom = Color.FromArgb(
                Clamp255(solR[0] + solR[1] * w + solR[2] * h),
                Clamp255(solG[0] + solG[1] * w + solG[2] * h),
                Clamp255(solB[0] + solB[1] * w + solB[2] * h));
        }

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

    private static Bitmap ToArgb(Bitmap src)
    {
        Bitmap bmp = new Bitmap(src.Width, src.Height, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.CompositingMode = CompositingMode.SourceCopy;
            g.DrawImageUnscaled(src, 0, 0);
        }
        return bmp;
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

    private static void DrawGlyph(Graphics g, Bitmap glyph, int canvas, double widthRatio)
    {
        int targetW = (int)Math.Round(canvas * widthRatio);
        int targetH = (int)Math.Round(targetW * (double)glyph.Height / glyph.Width);
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
        g.CompositingQuality = CompositingQuality.HighQuality;
        g.DrawImage(glyph, (canvas - targetW) / 2, (canvas - targetH) / 2, targetW, targetH);
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
                DrawGlyph(g, glyph, size, ratio);
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

    private static void SaveGlyphOnly(string path, int size, Bitmap glyph, double ratio)
    {
        using (Bitmap canvas = new Bitmap(size, size, PixelFormat.Format32bppArgb))
        {
            canvas.SetResolution(96, 96);
            using (Graphics g = Graphics.FromImage(canvas))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.Clear(Color.Transparent);
                DrawGlyph(g, glyph, size, ratio);
            }
            canvas.Save(path, ImageFormat.Png);
        }
    }

    /// White mark whose canvas hugs the glyph (with a hairline pad), so a
    /// widget that asks for N dp gets an N dp glyph instead of N dp worth of
    /// invisible margin.
    private static void SaveTightMark(string path, Bitmap glyph, int glyphWidth, int pad)
    {
        int targetW = glyphWidth;
        int targetH = (int)Math.Round(targetW * (double)glyph.Height / glyph.Width);
        int canvasW = targetW + pad * 2;
        int canvasH = targetH + pad * 2;
        using (Bitmap canvas = new Bitmap(canvasW, canvasH, PixelFormat.Format32bppArgb))
        {
            canvas.SetResolution(96, 96);
            using (Graphics g = Graphics.FromImage(canvas))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                g.CompositingQuality = CompositingQuality.HighQuality;
                g.Clear(Color.Transparent);
                g.DrawImage(glyph, pad, pad, targetW, targetH);
            }
            canvas.Save(path, ImageFormat.Png);
        }
    }

    /// Opaque square icon (Windows frames and web tiles).
    private static Bitmap RenderIcon(int size, Bitmap glyph, Color top, Color bottom,
        double ratio)
    {
        Bitmap canvas = new Bitmap(size, size, PixelFormat.Format24bppRgb);
        canvas.SetResolution(96, 96);
        using (Graphics g = Graphics.FromImage(canvas))
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            FillField(g, size, top, bottom);
            DrawGlyph(g, glyph, size, ratio);
        }
        return canvas;
    }

    /// White mark centred on the brand field (maskable web icons).
    private static void SaveMarkField(string path, int size, Bitmap glyph, double ratio,
        Color top, Color bottom)
    {
        using (Bitmap canvas = RenderIcon(size, glyph, top, bottom, ratio))
        {
            canvas.Save(path, ImageFormat.Png);
        }
    }

    /// Multi-resolution .ico with PNG-compressed frames (supported since
    /// Windows Vista), written by hand so the brand can be rebuilt with no
    /// extra tooling.
    private static void SaveIco(string path, int[] sizes, Bitmap glyph, Color top,
        Color bottom, double ratio)
    {
        byte[][] frames = new byte[sizes.Length][];
        for (int i = 0; i < sizes.Length; i++)
        {
            using (Bitmap frame = RenderIcon(sizes[i], glyph, top, bottom, ratio))
            using (MemoryStream buffer = new MemoryStream())
            {
                frame.Save(buffer, ImageFormat.Png);
                frames[i] = buffer.ToArray();
            }
        }

        using (FileStream file = new FileStream(path, FileMode.Create, FileAccess.Write))
        using (BinaryWriter writer = new BinaryWriter(file))
        {
            writer.Write((ushort)0);                  // reserved
            writer.Write((ushort)1);                  // 1 = icon
            writer.Write((ushort)sizes.Length);

            int offset = 6 + 16 * sizes.Length;
            for (int i = 0; i < sizes.Length; i++)
            {
                int size = sizes[i];
                writer.Write((byte)(size >= 256 ? 0 : size));
                writer.Write((byte)(size >= 256 ? 0 : size));
                writer.Write((byte)0);                // palette entries
                writer.Write((byte)0);                // reserved
                writer.Write((ushort)1);              // colour planes
                writer.Write((ushort)32);             // bits per pixel
                writer.Write((uint)frames[i].Length);
                writer.Write((uint)offset);
                offset += frames[i].Length;
            }
            for (int i = 0; i < frames.Length; i++) writer.Write(frames[i]);
        }
    }

    /// macOS icon: rounded squircle on a transparent canvas (Big Sur grid),
    /// because macOS applies no mask of its own.
    private static void SaveMacIcon(string path, int size, Bitmap glyph, Color top,
        Color bottom, double ratio)
    {
        int inner = (int)Math.Round(size * MacIconContent);
        int offset = (size - inner) / 2;
        using (Bitmap canvas = new Bitmap(size, size, PixelFormat.Format32bppArgb))
        {
            canvas.SetResolution(96, 96);
            using (Graphics g = Graphics.FromImage(canvas))
            {
                g.SmoothingMode = SmoothingMode.AntiAlias;
                g.Clear(Color.Transparent);
                using (Matrix shift = new Matrix())
                {
                    shift.Translate(offset, offset);
                    g.Transform = shift;
                    using (GraphicsPath clip = RoundedRect(inner, (float)(inner * MacIconRadius)))
                    {
                        g.SetClip(clip);
                    }
                    FillField(g, inner, top, bottom);
                    DrawGlyph(g, glyph, inner, ratio);
                }
            }
            canvas.Save(path, ImageFormat.Png);
        }
    }
}
'@

Add-Type -TypeDefinition $brandCode -ReferencedAssemblies System.Drawing

$colorLogo = Join-Path $RepoRoot 'assets/image/logo_literasiAI.png'
$whiteLogo = Join-Path $RepoRoot 'assets/image/logo_literasiAI_white.png'
$lines = [BrandAssets]::Generate($RepoRoot, $colorLogo, $whiteLogo)
foreach ($line in $lines) { Write-Host "  $line" }
Write-Host ''
Write-Host 'Brand assets regenerated: colour app icon + white splash mark.' -ForegroundColor Green
