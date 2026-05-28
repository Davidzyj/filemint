#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/FileMint.xcodeproj"
SCHEME="FileMint"
BUNDLE_ID="com.zhouyajie.filemint"
DEVICE_NAME="${FILEMINT_SCREENSHOT_DEVICE:-iPhone 16 Pro Max}"
DEVICE_OS="${FILEMINT_SCREENSHOT_OS:-18.6}"
DERIVED_DATA="${FILEMINT_DERIVED_DATA:-/tmp/FileMintScreenshotDerivedData}"
LOG_FILE="$ROOT_DIR/build/screenshots/screenshot.log"
OUT_ROOT="$ROOT_DIR/build/screenshots"
TARGET_WIDTH=1242
TARGET_HEIGHT=2688

mkdir -p "$OUT_ROOT/en" "$OUT_ROOT/zh-Hans" "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"

log() {
  printf '%s\n' "$*" | tee -a "$LOG_FILE"
}

fail() {
  log "ERROR: $*"
  exit 1
}

dimension_summary() {
  local file="$1"
  sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null | awk '/pixelWidth|pixelHeight/ {print $2}' | paste -sdx -
}

assert_dimensions() {
  local file="$1"
  local dims
  dims="$(dimension_summary "$file")"
  [[ "$dims" == "${TARGET_WIDTH}x${TARGET_HEIGHT}" ]] || fail "Unexpected dimensions for $file: $dims"
}

capture_png() {
  local udid="$1"
  local language="$2"
  local screen="$3"
  local name="$4"
  local raw="$OUT_ROOT/$language/${name}-raw.png"
  local final="$OUT_ROOT/$language/${name}.png"

  xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$udid" "$BUNDLE_ID" -FileMintScreenshot -FileMintLanguage "$language" -FileMintScreen "$screen" >> "$LOG_FILE" 2>&1

  local min_bytes=120000
  if [[ "$screen" == "home" ]]; then
    min_bytes=180000
  fi
  sleep 2

  local attempt
  for attempt in {1..8}; do
    xcrun simctl io "$udid" screenshot "$raw" >> "$LOG_FILE" 2>&1
    local bytes
    bytes="$(wc -c < "$raw" | tr -d ' ')"
    if [[ "$bytes" -gt "$min_bytes" ]]; then
      break
    fi
    sleep 1
  done

  sips -s format png -z "$TARGET_HEIGHT" "$TARGET_WIDTH" "$raw" --out "$final" >> "$LOG_FILE" 2>&1
  rm -f "$raw"
  assert_dimensions "$final"
}

make_contact_sheet() {
  local language="$1"
  local sheet="$OUT_ROOT/${language}-contact-sheet.jpg"
  "$ROOT_DIR/scripts/make_contact_sheet.swift" "$OUT_ROOT/$language" "$sheet" >> "$LOG_FILE" 2>&1
}

log "Building $SCHEME for $DEVICE_NAME ($DEVICE_OS)..."
rm -rf "$DERIVED_DATA"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME,OS=$DEVICE_OS" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build >> "$LOG_FILE" 2>&1

UDID="$(xcrun simctl list devices available | awk -v name="$DEVICE_NAME" -v os="-- iOS $DEVICE_OS --" '
  $0 == os { in_runtime = 1; next }
  /^-- / && $0 != os { in_runtime = 0 }
  in_runtime && index($0, name) {
    print
    exit
  }
')"
UDID="$(printf '%s\n' "$UDID" | sed -E 's/.*\(([A-F0-9-]{36})\).*/\1/')"

[[ -n "$UDID" ]] || fail "Simulator not found: $DEVICE_NAME ($DEVICE_OS)"

APP_PATH="$(find "$DERIVED_DATA/Build/Products/Debug-iphonesimulator" -name 'FileMint.app' -type d | head -n 1)"
[[ -d "$APP_PATH" ]] || fail "Built app not found."

log "Booting simulator $UDID..."
xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$UDID" -b >> "$LOG_FILE" 2>&1
xcrun simctl install "$UDID" "$APP_PATH" >> "$LOG_FILE" 2>&1

for language in en zh-Hans; do
  rm -f "$OUT_ROOT/$language"/*.png
  capture_png "$UDID" "$language" "home" "01-home"
  capture_png "$UDID" "$language" "compress" "02-compress-pdf"
  capture_png "$UDID" "$language" "images-to-pdf" "03-images-to-pdf"
  capture_png "$UDID" "$language" "settings" "04-settings"
  make_contact_sheet "$language"
done

log "Generated screenshots:"
find "$OUT_ROOT" -maxdepth 2 \( -name '*.png' -o -name '*contact-sheet.jpg' \) -print | sort | while read -r file; do
  dims="$(dimension_summary "$file")"
  printf '%s %s\n' "$dims" "$file" | tee -a "$LOG_FILE"
done
