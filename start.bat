@echo off
REM Start DeepSeek Harness Web UI from a source checkout.
REM Installs deps, builds once if needed, then boots the web profile.
REM Extra args are forwarded to "dsh web": e.g. start.bat --no-open --port 3081
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo [start] ERROR: Node.js not found on PATH. Install Node 22.19+ or 24+. 1>&2
  exit /b 1
)

where corepack >nul 2>nul
if errorlevel 1 (
  echo [start] ERROR: Corepack not found. It ships with Node.js - reinstall Node or fix PATH. 1>&2
  exit /b 1
)

call corepack pnpm --version >nul 2>nul
if errorlevel 1 (
  echo [start] Enabling Corepack pnpm shim...
  call corepack enable
  if errorlevel 1 (
    echo [start] ERROR: "corepack enable" failed. 1>&2
    exit /b 1
  )
)

if not exist "node_modules" (
  echo [start] Installing dependencies with pnpm...
  call corepack pnpm install
  if errorlevel 1 (
    echo [start] ERROR: "pnpm install" failed. 1>&2
    exit /b 1
  )
)

if not exist "packages\core\agent\lib" (
  echo [start] Build output missing - running full build...
  call corepack pnpm run build
  if errorlevel 1 (
    echo [start] ERROR: "pnpm run build" failed. 1>&2
    exit /b 1
  )
)

echo [start] Launching Web UI (browser opens by default)...
call corepack pnpm dsh web %*
if errorlevel 1 (
  echo [start] ERROR: "pnpm dsh web" exited with code %errorlevel%. 1>&2
  exit /b 1
)
