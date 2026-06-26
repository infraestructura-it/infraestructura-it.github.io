# ============================================================
#  deploy-iit-web.ps1
#  Despliegue sitio corporativo infraestructura-it.github.io
#  IIT — Jairo Sepúlveda — 2026-06-26
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── CONFIGURACIÓN ────────────────────────────────────────────
$REPO_DIR    = "C:\Users\User01\OneDrive\2026-proyectos\infraestructura-it.github.io"
$DESCARGA    = "C:\descargas"
$ASSETS_DIR  = "$REPO_DIR\assets"
$GIT_USER    = "infraestructura-it"
$COMMIT_MSG  = "feat: logo IIT-CORE inline en nav + leyenda infraestructura-it.com closes #3"
$BRANCH      = "main"

# Archivos a copiar desde C:\descargas al repo
$ARCHIVOS_HTML = @(
    "datacenter.html",
    "solar.html",
    "redes.html",
    "iot.html",
    "ia.html",
    "CLAUDE.md"
)

$ARCHIVOS_ASSETS = @(
    "logo-iit-core.svg",
    "logo-iit-nav.svg"
)

# ── FUNCIONES ────────────────────────────────────────────────
function Write-Step { param($n, $msg)
    Write-Host "`n[$n] " -ForegroundColor Cyan -NoNewline
    Write-Host $msg -ForegroundColor White
}

function Write-OK   { param($msg) Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-WARN { param($msg) Write-Host "    WRN $msg" -ForegroundColor Yellow }
function Write-ERR  { param($msg) Write-Host "    ERR $msg" -ForegroundColor Red }

# ── INICIO ───────────────────────────────────────────────────
Clear-Host
Write-Host "============================================" -ForegroundColor DarkCyan
Write-Host "  IIT Web Deploy — infraestructura-it.com  " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor DarkCyan

# PASO 1 — Verificar directorios
Write-Step "1/7" "Verificando directorios..."

if (-not (Test-Path $REPO_DIR)) {
    Write-ERR "Repo no encontrado: $REPO_DIR"
    Write-Host "  Clona primero con:" -ForegroundColor Yellow
    Write-Host "  git clone https://github.com/$GIT_USER/$GIT_USER.github.io `"$REPO_DIR`"" -ForegroundColor White
    exit 1
}
Write-OK "Repo local: $REPO_DIR"

if (-not (Test-Path $DESCARGA)) {
    Write-ERR "Directorio de descargas no encontrado: $DESCARGA"
    exit 1
}
Write-OK "Descargas: $DESCARGA"

# Crear assets/ si no existe
if (-not (Test-Path $ASSETS_DIR)) {
    New-Item -ItemType Directory -Path $ASSETS_DIR | Out-Null
    Write-OK "Creado: $ASSETS_DIR"
}

# PASO 2 — Verificar archivos fuente
Write-Step "2/7" "Verificando archivos en $DESCARGA..."

$faltantes = @()
foreach ($f in ($ARCHIVOS_HTML + $ARCHIVOS_ASSETS)) {
    $src = "$DESCARGA\$f"
    if (Test-Path $src) {
        $size = (Get-Item $src).Length
        Write-OK "$f  ($([math]::Round($size/1KB,1)) KB)"
    } else {
        Write-WARN "No encontrado: $f"
        $faltantes += $f
    }
}

if ($faltantes.Count -gt 0) {
    Write-Host "`n  Archivos faltantes. Descarga desde Claude antes de continuar." -ForegroundColor Yellow
    Write-Host "  Continuar de todas formas? (s/N): " -ForegroundColor Yellow -NoNewline
    $resp = Read-Host
    if ($resp -ne "s" -and $resp -ne "S") { exit 0 }
}

# PASO 3 — Copiar archivos HTML al raíz del repo
Write-Step "3/7" "Copiando archivos HTML al repo..."

foreach ($f in $ARCHIVOS_HTML) {
    $src  = "$DESCARGA\$f"
    $dst  = "$REPO_DIR\$f"
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-OK "Copiado: $f → raíz del repo"
    }
}

# PASO 4 — Copiar assets (logo SVG)
Write-Step "4/7" "Copiando assets al repo..."

foreach ($f in $ARCHIVOS_ASSETS) {
    $src = "$DESCARGA\$f"
    $dst = "$ASSETS_DIR\$f"
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-OK "Copiado: $f → assets\"
    }
}

# PASO 5 — Verificar cuenta Git activa
Write-Step "5/7" "Verificando cuenta Git..."

Set-Location $REPO_DIR
$currentUser = git config user.name 2>$null
$currentEmail = git config user.email 2>$null

Write-OK "Usuario: $currentUser <$currentEmail>"

# Cambiar a cuenta IIT si es necesario
if ($currentUser -notmatch "infraestructura") {
    Write-WARN "La cuenta activa no parece ser infraestructura-it"
    Write-Host "  Cambiando con gh auth switch..." -ForegroundColor Yellow
    try {
        gh auth switch --user $GIT_USER
        Write-OK "Cuenta cambiada a $GIT_USER"
    } catch {
        Write-WARN "gh CLI no disponible o cuenta no configurada. Continúa manualmente si es necesario."
    }
}

# PASO 6 — Git status y confirmación
Write-Step "6/7" "Estado del repositorio..."

$gitStatus = git status --short
if ($gitStatus) {
    Write-Host "`n  Cambios detectados:" -ForegroundColor White
    $gitStatus | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

    Write-Host "`n  Mensaje de commit: " -ForegroundColor Yellow
    Write-Host "  $COMMIT_MSG" -ForegroundColor White
    Write-Host "`n  Confirmar push a origin/$BRANCH ? (s/N): " -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host

    if ($confirm -ne "s" -and $confirm -ne "S") {
        Write-Host "`n  Operación cancelada. Archivos ya copiados al repo." -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-WARN "No hay cambios detectados en el repo. ¿Los archivos ya estaban actualizados?"
    exit 0
}

# PASO 7 — Git add + commit + push
Write-Step "7/7" "Subiendo a GitHub..."

git add .
Write-OK "git add . completado"

git commit -m $COMMIT_MSG
Write-OK "Commit creado"

git push origin $BRANCH
Write-OK "Push a origin/$BRANCH completado"

# ── RESUMEN FINAL ────────────────────────────────────────────
Write-Host "`n============================================" -ForegroundColor DarkCyan
Write-Host "  DESPLIEGUE COMPLETADO                    " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "  Sitio activo en ~30 segundos:" -ForegroundColor White
Write-Host "  https://infraestructura-it.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Verificar en GitHub Pages:" -ForegroundColor White
Write-Host "  https://github.com/$GIT_USER/$GIT_USER.github.io/actions" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Páginas actualizadas:" -ForegroundColor White
@("datacenter", "solar", "redes", "iot", "ia") | ForEach-Object {
    Write-Host "    https://infraestructura-it.com/$_.html" -ForegroundColor DarkCyan
}
Write-Host ""
