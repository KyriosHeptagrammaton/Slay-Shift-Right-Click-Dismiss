# Slay - Shift+Right-Click Dismiss patcher
# Patches the Slay.exe in this folder. Keeps a backup as Slay_original.exe.
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here

function Test-Writable { try { $f = Join-Path $here '.__slayfix_test'; [IO.File]::WriteAllText($f,'x'); Remove-Item $f; return $true } catch { return $false } }
if (-not (Test-Writable)) {
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    Write-Host 'The Slay folder needs administrator rights to modify. Asking for permission...'
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
  }
}

$exe = Join-Path $here 'Slay.exe'
$bak = Join-Path $here 'Slay_original.exe'
if (-not (Test-Path $exe)) { Write-Host 'Slay.exe not found. Put these files in your Slay folder (next to Slay.exe) and run again.'; Read-Host 'Press Enter'; exit 1 }

$H_ORIGINAL = 'E590D95CDBD9D202EDC692BD42F114A775629439D5EB5903FF3225F5F23BD019'
$H_PATCHED  = 'E09D340085EFD7C3F6BD1DE0ADDBBF707FABCAADF99013D5CF5A194B9B5580AD'
function Sha($p) { (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash }

$h = Sha $exe
if ($h -eq $H_PATCHED) { Write-Host 'Slay.exe is already patched. Nothing to do.'; Read-Host 'Press Enter'; exit 0 }
if ($h -ne $H_ORIGINAL) {
  Write-Host 'This Slay.exe is not the version this patch was made for (Slay 5.0u, 577,536 bytes).'
  Write-Host 'Nothing was changed.'
  Write-Host "SHA256: $h"
  Read-Host 'Press Enter'; exit 1
}

if (-not (Test-Path $bak)) { Copy-Item -LiteralPath $exe -Destination $bak; Write-Host 'Backup saved as Slay_original.exe' }

$data = '8AEAAAIAAAAAUDgdAQAGAAAA6cM8AQCQAFoCAGEAAAD3hCS4AwAABAAAAHR7oeBsQwCFwA+EfHb+/4M92EFEAAB+EOjINf//gz3gbEMAAHQ16+eDPeBsQwAID4VWdv7/odxsQwCFwHQTD78ExepURABrwCxmg4AObUMAD8cF4GxDZloCAAUAAADHBexsQ3BaAgAFAAAAxwUQGkR6WgIAGQAAAIusJLADAAAx/+lRrv7/ixXcbEMA6avC/v8='
$blob = [Convert]::FromBase64String($data)
$out  = [IO.File]::ReadAllBytes($exe)
$p = 0
while ($p -lt $blob.Length) {
  $off = [int][BitConverter]::ToUInt32($blob,$p); $len = [int][BitConverter]::ToUInt32($blob,$p+4)
  [Array]::Copy($blob, $p+8, $out, $off, $len)
  $p += 8 + $len
}
$tmp = Join-Path $here 'Slay_patched.tmp'
[IO.File]::WriteAllBytes($tmp, $out)
if ((Sha $tmp) -ne $H_PATCHED) { Remove-Item $tmp; Write-Host 'Patch verification failed - nothing was changed.'; Read-Host 'Press Enter'; exit 1 }
Move-Item -Force -LiteralPath $tmp -Destination $exe
Write-Host ''
Write-Host 'Done! Slay.exe is patched.'
Write-Host 'Right-click works as before. Shift + right-click puts back whatever is in your hand.'
Read-Host 'Press Enter'
