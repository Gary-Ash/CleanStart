#!/usr/bin/env bash
set -euo pipefail
#*****************************************************************************************
# build.sh
#
# This script will build and notarize the CleanStart.app
#
# Author   :  Gary Ash <gary.ash@icloud.com>
# Created  :   3-Feb-2026  8:20pm
# Modified :
#
# Copyright © 2026 By Gary Ash All rights reserved.
#*****************************************************************************************

readonly NOTARY_PROFILE="notary-profile"

cleanup() {
	local exit_code="${?}"
	rm -f "CleanStart.app.zip"
	rm -f "entitlements.plist"
	exit "${exit_code}"
}

main() {
	trap cleanup EXIT

	cat >"entitlements.plist" <<'ENTITLEMENTS_PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
ENTITLEMENTS_PLIST

	SIGNING_IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)".*/\1/')

	if [[ -z "${SIGNING_IDENTITY}" ]]; then
		echo "Error: No Apple Distribution certificate found in keychain" >&2
		exit 1
	fi

	echo "Using signing identity: [${SIGNING_IDENTITY}]"

	osacompile -o "CleanStart.app" "CleanStart.applescript" >/dev/null
	cp -f Info.plist CleanStart.app/Contents/Info.plist
	cp -f AppIcon.icns CleanStart.app/Contents/Resources
	rm -f CleanStart.app/Contents/Resources/applet.icns

	while IFS= read -r binary; do
		if file "${binary}" | grep -q "Mach-O"; then
			lipo "${binary}" -remove x86_64 -output "${binary}.tmp"
			mv "${binary}.tmp" "${binary}"
			codesign --force --sign - "${binary}" 2>/dev/null || true
		fi
	done < <(find "CleanStart.app" -type f -perm +111)

	codesign --force --sign "${SIGNING_IDENTITY}" \
		--options runtime \
		--entitlements "entitlements.plist" \
		--deep "CleanStart.app"

	codesign --verify --verbose "CleanStart.app"
	ditto -c -k --keepParent "CleanStart.app" "CleanStart.app.zip"

	xcrun notarytool submit "CleanStart.app.zip" \
		--keychain-profile "${NOTARY_PROFILE}" \
		--wait

	xcrun stapler staple "CleanStart.app"
}

main "${@}"
