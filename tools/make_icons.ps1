param([string]$SrcPath, [string]$Res, [string]$Docs)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System; using System.Drawing; using System.Drawing.Imaging; using System.Runtime.InteropServices;
public static class Icon {
  // Fit color = a + b*x + c*y per channel from border samples (the gradient).
  public static double[,] Fit(Bitmap b) {
    int n = b.Width; var pts = new System.Collections.Generic.List<int[]>();
    for (int i = 0; i < n; i += 16) { pts.Add(new[]{i,2}); pts.Add(new[]{i,n-3}); pts.Add(new[]{2,i}); pts.Add(new[]{n-3,i}); }
    double[,] m = new double[3,3]; double[,] r = new double[3,3];
    foreach (var p in pts) { Color c = b.GetPixel(p[0], p[1]); double[] v = {1, p[0]/(double)n, p[1]/(double)n}; int[] ch = {c.R,c.G,c.B};
      for (int i=0;i<3;i++){ for(int j=0;j<3;j++) m[i,j]+=v[i]*v[j]; for(int k=0;k<3;k++) r[i,k]+=v[i]*ch[k]; } }
    double[,] coef = new double[3,3];
    for (int k=0;k<3;k++){ double[,] a=(double[,])m.Clone(); double[] y={r[0,k],r[1,k],r[2,k]};
      for(int i=0;i<3;i++){ for(int j=i+1;j<3;j++){ double f=a[j,i]/a[i,i]; for(int q=0;q<3;q++) a[j,q]-=f*a[i,q]; y[j]-=f*y[i]; } }
      for(int i=2;i>=0;i--){ double s=y[i]; for(int q=i+1;q<3;q++) s-=a[i,q]*coef[q,k]; coef[i,k]=s/a[i,i]; } }
    return coef;
  }
  static int Bg(double[,] c, int k, double x, double y){ return (int)Math.Max(0,Math.Min(255,c[0,k]+c[1,k]*x+c[2,k]*y)); }
  public static Bitmap Gradient(double[,] c, int n) {
    var o = new Bitmap(n, n, PixelFormat.Format32bppArgb);
    for (int y=0;y<n;y++) for (int x=0;x<n;x++){ double fx=x/(double)n, fy=y/(double)n; o.SetPixel(x,y,Color.FromArgb(255,Bg(c,0,fx,fy),Bg(c,1,fx,fy),Bg(c,2,fx,fy))); }
    return o;
  }
  // Art only: alpha from distance to the fitted background. mono = white silhouette.
  public static Bitmap Art(Bitmap b, double[,] c, bool mono) {
    int n=b.Width; var o=new Bitmap(n,n,PixelFormat.Format32bppArgb);
    for (int y=0;y<n;y++) for (int x=0;x<n;x++){ Color p=b.GetPixel(x,y); double fx=x/(double)n, fy=y/(double)n;
      int d=Math.Max(Math.Abs(p.R-Bg(c,0,fx,fy)),Math.Max(Math.Abs(p.G-Bg(c,1,fx,fy)),Math.Abs(p.B-Bg(c,2,fx,fy))));
      int a=mono ? (int)Math.Max(0,Math.Min(255,(d-55)*255.0/40)) : (int)Math.Max(0,Math.Min(255,(d-18)*255.0/45)); if(a==0) continue;
      o.SetPixel(x,y, mono? Color.FromArgb(a,255,255,255) : Color.FromArgb(a,p.R,p.G,p.B)); }
    return o;
  }
}
"@
$src = New-Object System.Drawing.Bitmap $SrcPath
# Inner square of the rounded tile: avoids the white corners.
$inset = 112; $size = $src.Width - 2 * $inset
$crop = New-Object System.Drawing.Bitmap $size, $size; $cg=[System.Drawing.Graphics]::FromImage($crop); $cg.DrawImage($src, (New-Object System.Drawing.Rectangle 0,0,$size,$size), (New-Object System.Drawing.Rectangle $inset,$inset,$size,$size), [System.Drawing.GraphicsUnit]::Pixel); $cg.Dispose()
$coef = [Icon]::Fit($crop)
$grad = [Icon]::Gradient($coef, 432)
$art = [Icon]::Art($crop, $coef, $false)
$mono = [Icon]::Art($crop, $coef, $true)

function Save-Scaled($img, $n, $path, [double]$scale = 1.0, $bg = $null, [double]$radius = 0) {
  $o = New-Object System.Drawing.Bitmap $n, $n
  $g = [System.Drawing.Graphics]::FromImage($o)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'AntiAlias'; $g.PixelOffsetMode = 'HighQuality'
  if ($radius -gt 0) {
    $r = $n * $radius; $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc(0, 0, 2*$r, 2*$r, 180, 90); $p.AddArc($n-2*$r, 0, 2*$r, 2*$r, 270, 90)
    $p.AddArc($n-2*$r, $n-2*$r, 2*$r, 2*$r, 0, 90); $p.AddArc(0, $n-2*$r, 2*$r, 2*$r, 90, 90); $p.CloseFigure()
    $g.SetClip($p)
  }
  if ($bg) { $g.DrawImage($bg, 0, 0, $n, $n) }
  $s = $n * $scale; $off = ($n - $s) / 2
  $g.DrawImage($img, [single]$off, [single]$off, [single]$s, [single]$s)
  $g.Dispose(); New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  $o.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $o.Dispose()
}

$dens = @{ mdpi = 1; hdpi = 1.5; xhdpi = 2; xxhdpi = 3; xxxhdpi = 4 }
foreach ($d in $dens.Keys) {
  $k = $dens[$d]
  Save-Scaled $crop ([int](48 * $k)) "$Res\mipmap-$d\ic_launcher.png" 1.0 $null 0.22
  # Adaptive layers are 108dp; art is kept inside the 66dp safe zone.
  Save-Scaled $grad ([int](108 * $k)) "$Res\mipmap-$d\ic_launcher_background.png"
  Save-Scaled $art ([int](108 * $k)) "$Res\mipmap-$d\ic_launcher_foreground.png" 0.50
  Save-Scaled $mono ([int](108 * $k)) "$Res\mipmap-$d\ic_launcher_monochrome.png" 0.50
}
Save-Scaled $crop 512 "$Docs\icon-512.png"
Save-Scaled $art 432 "$Docs\_preview_fg.png" 0.50 $grad 0.5; $blk = New-Object System.Drawing.Bitmap 8,8; $bg2=[System.Drawing.Graphics]::FromImage($blk); $bg2.Clear([System.Drawing.Color]::FromArgb(255,40,48,30)); $bg2.Dispose(); Save-Scaled $mono 432 "$Docs\_preview_mono.png" 0.50 $blk 0.5
"done: crop corner color = " + $crop.GetPixel(0,0) + " / " + $crop.GetPixel($size-1,$size-1)





