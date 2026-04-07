#!/usr/bin/env sh

# Build bakin-extractor using the local .venv PyInstaller
# Output: ./dist/bakin-extractor (or ./dist/bakin-extractor.exe on Windows)

set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR" || exit 1

VENV_PY="$SCRIPT_DIR/.venv/bin/python"
if [ ! -x "$VENV_PY" ]; then
  echo "ERROR: Could not find venv python at: $VENV_PY" >&2
  echo "Create the venv first (python -m venv .venv) and install deps." >&2
  exit 1
fi

# Clean previous build artifacts (optional)
rm -rf "$SCRIPT_DIR/build" "$SCRIPT_DIR/dist"
rm -f "$SCRIPT_DIR"/*.spec 2>/dev/null || true

# Make sure PyInstaller is available in the venv
"$VENV_PY" -m PyInstaller --version >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: PyInstaller not installed in .venv" >&2
  echo "Install it with: $VENV_PY -m pip install pyinstaller" >&2
  exit 1
fi

# Build (console app; keep console so print() output is visible)
"$VENV_PY" -m PyInstaller \
  --noconfirm \
  --clean \
  --onefile \
  --name "bakin-extractor" \
  "$SCRIPT_DIR/bakin-extractor.py"

RC=$?
if [ "$RC" -ne 0 ]; then
  echo "" >&2
  echo "Build failed with exit code $RC." >&2
  exit "$RC"
fi

echo ""
if [ -f "$SCRIPT_DIR/dist/bakin-extractor" ]; then
  echo "Build OK: $SCRIPT_DIR/dist/bakin-extractor"
elif [ -f "$SCRIPT_DIR/dist/bakin-extractor.exe" ]; then
  echo "Build OK: $SCRIPT_DIR/dist/bakin-extractor.exe"
else
  echo "Build OK: (dist output created)"
fi

exit 0