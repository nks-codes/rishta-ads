#!/usr/bin/env bash
# Verifies a built APK against the Google Play requirements checked in Step 1:
#   - package name has not changed
#   - targetSdkVersion and compileSdkVersion are at least MIN_TARGET (36)
# Prints a short report and fails (exit 1) if a requirement is not met.
#
# Usage: tools/verify_apk.sh <apk> [min_target_sdk] [expected_package]
set -euo pipefail

APK="${1:?Usage: verify_apk.sh <apk> [min_target_sdk] [expected_package]}"
MIN_TARGET="${2:-36}"
EXPECTED_PACKAGE="${3:-pk.biah.rishta_ads}"

AAPT2="${AAPT2:-}"
if [ -z "$AAPT2" ]; then
  SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
  AAPT2="$(ls -d "$SDK_ROOT"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -n 1 || true)"
fi
if [ -z "$AAPT2" ] || [ ! -x "$AAPT2" ]; then
  echo "aapt2 was not found (set AAPT2 or ANDROID_HOME)." >&2
  exit 2
fi

BADGING="$("$AAPT2" dump badging "$APK")"

first() { sed -n "$1" <<<"$BADGING" | head -n 1; }

PACKAGE="$(first "s/^package: name='\([^']*\)'.*/\1/p")"
VERSION_CODE="$(first "s/^package:.* versionCode='\([^']*\)'.*/\1/p")"
VERSION_NAME="$(first "s/^package:.* versionName='\([^']*\)'.*/\1/p")"
COMPILE_SDK="$(first "s/^package:.* compileSdkVersion='\([0-9]*\)'.*/\1/p")"
MIN_SDK="$(first "s/^sdkVersion:'\([0-9]*\)'.*/\1/p")"
TARGET_SDK="$(first "s/^targetSdkVersion:'\([0-9]*\)'.*/\1/p")"
PERMISSIONS="$(sed -n "s/^uses-permission: name='\([^']*\)'.*/\1/p" <<<"$BADGING" | tr '\n' ' ')"

FAIL=0
status() { if [ "$1" = "ok" ]; then echo "PASS"; else echo "FAIL"; fi; }

PKG_OK=ok;     [ "$PACKAGE" = "$EXPECTED_PACKAGE" ] || { PKG_OK=bad; FAIL=1; }
TARGET_OK=ok;  { [ -n "$TARGET_SDK" ] && [ "$TARGET_SDK" -ge "$MIN_TARGET" ]; } || { TARGET_OK=bad; FAIL=1; }
COMPILE_OK=ok; if [ -n "$COMPILE_SDK" ]; then [ "$COMPILE_SDK" -ge "$MIN_TARGET" ] || { COMPILE_OK=bad; FAIL=1; }; fi

REPORT="$(cat <<TXT
### APK verification
| Check | Value | Result |
|---|---|---|
| Package name (expected \`$EXPECTED_PACKAGE\`) | \`${PACKAGE:-unknown}\` | $(status $PKG_OK) |
| targetSdkVersion (need >= $MIN_TARGET) | \`${TARGET_SDK:-unknown}\` | $(status $TARGET_OK) |
| compileSdkVersion (need >= $MIN_TARGET) | \`${COMPILE_SDK:-not reported}\` | $(status $COMPILE_OK) |
| minSdkVersion | \`${MIN_SDK:-unknown}\` | info |
| Version | \`${VERSION_NAME:-?} (${VERSION_CODE:-?})\` | info |
| Permissions | \`${PERMISSIONS:-none}\` | info |
TXT
)"

echo "$REPORT"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  echo "$REPORT" >> "$GITHUB_STEP_SUMMARY"
fi

if [ "$FAIL" -ne 0 ]; then
  echo "APK verification FAILED." >&2
  exit 1
fi
echo "APK verification passed."
