#!/bin/bash
# Generates the Xcode project and patches the project format so it opens in Xcode 15.
# Run this instead of `xcodegen generate` directly.
#
# Why: recent XcodeGen writes objectVersion 77 (Xcode 16 format). On Xcode 15 that
# fails with "future Xcode project file format", so we lower it to 54. Once you move
# to Xcode 16 you can delete this script and just run `xcodegen generate`.
set -e
cd "$(dirname "$0")"

xcodegen generate
sed -i '' -E 's/objectVersion = [0-9]+;/objectVersion = 54;/' "TravelWorld.xcodeproj/project.pbxproj"

echo "✅ Project generated and patched to objectVersion 54. Open TravelWorld.xcodeproj."
