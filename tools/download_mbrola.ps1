# Script d'aide pour obtenir les ressources MBROLA (fr_phtrans + fr4)
# ====================================================================
# Approche validee : extraction depuis paquets Debian officiels via 7-Zip.
#   - fr_phtrans : depuis espeak-ng-data (Debian main)
#   - fr4        : depuis mbrola-fr4 (Debian non-free)
#
# PREREQUIS : 7-Zip installe (cherche dans ProgramFiles ou PATH)
#
# MBROLA.EXE pour Windows : aucun binaire pre-compile disponible dans les releases
#   officielles de numediart/MBROLA. Options si voix mb-fr4 souhaitee :
#     A) Compiler depuis source : https://github.com/numediart/MBROLA
#        (C source, AGPL-3.0 - Visual Studio ou MinGW)
#     B) Sans mbrola.exe : l'app utilise la voix fr+f1 + IPA SSML (deja fonctionnel)
# ====================================================================

$ErrorActionPreference = "Stop"
$scriptDir   = Split-Path $MyInvocation.MyCommand.Path
$projectRoot = Split-Path $scriptDir
$mbDataDir   = "$projectRoot\windows\espeak-ng-data\mb"
$winDir      = "$projectRoot\windows"

New-Item -ItemType Directory -Force -Path $mbDataDir | Out-Null

# Localiser 7-Zip
$sz = @("7z.exe", "C:\Program Files\7-Zip\7z.exe", "C:\Program Files (x86)\7-Zip\7z.exe") |
    ForEach-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1
if (-not $sz) {
    Write-Host "ERREUR : 7-Zip introuvable. Installez-le depuis https://7-zip.org" -ForegroundColor Red
    exit 1
}
$szExe = $sz.Source

Write-Host ""
Write-Host "=== Ressources MBROLA pour eSpeak NG ===" -ForegroundColor Cyan
Write-Host "  7-Zip : $szExe"
Write-Host ""

# -----------------------------------------------------------------------
# Fonction utilitaire : extraction d un fichier depuis un .deb Debian
# -----------------------------------------------------------------------
function Extract-FromDeb {
    param(
        [string]$DebUrl,
        [string]$SearchPattern,
        [string]$DestPath,
        [string]$Label
    )
    if (Test-Path $DestPath) {
        Write-Host "$Label deja present." -ForegroundColor Yellow
        return
    }
    $tmpDir = Join-Path $env:TEMP ("deb_extract_" + [System.IO.Path]::GetRandomFileName())
    New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
    try {
        Write-Host "$Label telechargement..." -NoNewline
        Invoke-WebRequest -Uri $DebUrl -OutFile "$tmpDir\pkg.deb" -UseBasicParsing
        Write-Host " $([math]::Round((Get-Item "$tmpDir\pkg.deb").Length/1MB,1)) Mo" -ForegroundColor DarkGray

        Write-Host "$Label extraction..." -NoNewline
        & $szExe x "$tmpDir\pkg.deb" -o"$tmpDir\d1" -y -bd | Out-Null
        $tar = Get-ChildItem "$tmpDir\d1" -Filter "*.tar" | Select-Object -First 1
        & $szExe x $tar.FullName -o"$tmpDir\d2" -y -bd | Out-Null

        $found = Get-ChildItem "$tmpDir\d2" -Recurse -Filter $SearchPattern |
                 Where-Object { -not $_.PSIsContainer } | Select-Object -First 1
        if (-not $found) {
            Write-Host " ECHEC : '$SearchPattern' introuvable dans le paquet." -ForegroundColor Red
            return
        }
        Copy-Item $found.FullName $DestPath
        Write-Host " OK ($([math]::Round((Get-Item $DestPath).Length/1KB,0)) Ko)" -ForegroundColor Green
    } catch {
        Write-Host " ECHEC : $_" -ForegroundColor Red
    } finally {
        Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 1. fr_phtrans depuis Debian main (espeak-ng-data amd64)
Extract-FromDeb `
    -DebUrl "http://ftp.debian.org/debian/pool/main/e/espeak-ng/espeak-ng-data_1.52.0+dfsg-5+b1_amd64.deb" `
    -SearchPattern "fr_phtrans" `
    -DestPath "$mbDataDir\fr_phtrans" `
    -Label "[1/3] fr_phtrans"

# 2. fr4 depuis Debian non-free (mbrola-fr4 _all)
Extract-FromDeb `
    -DebUrl "http://ftp.debian.org/debian/pool/non-free/m/mbrola-fr4/mbrola-fr4_0.0.19990521+repack2-6_all.deb" `
    -SearchPattern "fr4" `
    -DestPath "$mbDataDir\fr4" `
    -Label "[2/3] fr4"

# 3. mbrola.exe
$mbrolaExe = "$winDir\mbrola.exe"
Write-Host "[3/3] mbrola.exe..." -NoNewline
if (Test-Path $mbrolaExe) {
    Write-Host " deja present." -ForegroundColor Yellow
} else {
    Write-Host " ABSENT (optionnel)" -ForegroundColor Yellow
    Write-Host "  Sans mbrola.exe, l app utilise fr+f1 + speakPhonetic IPA (deja fonctionnel)."
    Write-Host "  Pour activer la voix mb-fr4 :"
    Write-Host "    Compilez depuis : https://github.com/numediart/MBROLA (source AGPL-3.0)"
    Write-Host "    Puis copiez mbrola.exe dans : $winDir\"
    Write-Host "    Et changez la voix dans lib/core/audio/tts_service.dart : mb-fr4"
}

Write-Host ""
Write-Host "=== Resume ===" -ForegroundColor Cyan
Write-Host "fr_phtrans : $(if (Test-Path "$mbDataDir\fr_phtrans") { 'OK' } else { 'MANQUANT' })"
Write-Host "fr4        : $(if (Test-Path "$mbDataDir\fr4")        { 'OK' } else { 'MANQUANT' })"
Write-Host "mbrola.exe : $(if (Test-Path $mbrolaExe)              { 'OK' } else { 'OPTIONNEL - non installe' })"
Write-Host ""
Write-Host "Note : sans mbrola.exe, speakPhonetic() utilise fr+f1 + SSML IPA (fonctionnel)." -ForegroundColor Cyan
