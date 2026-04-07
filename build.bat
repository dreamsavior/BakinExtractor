@echo off
setlocal EnableExtensions

REM Build winutils.exe using the local .venv PyInstaller
REM Output: .\dist\winutils.exe

cd /d "%~dp0"

set "VENV_PY=%CD%\.venv\Scripts\python.exe"
if not exist "%VENV_PY%" (
  echo ERROR: Could not find venv python at: "%VENV_PY%"
  echo Create the venv first ^(python -m venv .venv^) and install deps.
  exit /b 1
)

REM Clean previous build artifacts (optional)
if exist "%CD%\build" rmdir /s /q "%CD%\build"
if exist "%CD%\dist"  rmdir /s /q "%CD%\dist"
del /q "%CD%\*.spec" 2>nul

REM Make sure PyInstaller is available in the venv
"%VENV_PY%" -m PyInstaller --version >nul 2>nul
if errorlevel 1 (
  echo ERROR: PyInstaller not installed in .venv
  echo Install it with: "%VENV_PY%" -m pip install pyinstaller
  exit /b 1
)

REM Build (console app; keep console so print() output is visible)
"%VENV_PY%" -m PyInstaller ^
  --noconfirm ^
  --clean ^
  --onefile ^
  --name "bakin-extractor" ^
  "%CD%\bakin-extractor.py"

set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo.
  echo Build failed with exit code %RC%.
  exit /b %RC%
)

echo.
echo Build OK: "%CD%\dist\bakin-extractor.exe"
exit /b 0
