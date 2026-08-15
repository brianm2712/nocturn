#!/bin/bash
# Nocturn — one-shot finisher: icon render → project regen → tests → commit → Xcode.
set -e
cd "$(dirname "$0")"

echo "── 1/5 Rendering app icon (SVG → PNG) ──"
ICONDIR="Nocturn/Resources/Assets.xcassets/AppIcon.appiconset"
if command -v rsvg-convert >/dev/null; then
  rsvg-convert -w 1024 -h 1024 Nocturn/Resources/icon.svg -o "$ICONDIR/icon-1024.png"
else
  # qlmanage ships with macOS; renders SVG via QuickLook
  qlmanage -t -s 1024 -o /tmp Nocturn/Resources/icon.svg >/dev/null
  # QuickLook may letterbox; crop/pad to exactly 1024x1024
  sips -z 1024 1024 /tmp/icon.svg.png --out "$ICONDIR/icon-1024.png" >/dev/null
fi
cp "$ICONDIR/icon-1024.png" "$ICONDIR/icon-mac-1024.png"
echo "icon rendered: $(sips -g pixelWidth -g pixelHeight "$ICONDIR/icon-1024.png" | tail -2 | tr '\n' ' ')"

echo "── 2/5 Regenerating Xcode project ──"
xcodegen generate

echo "── 3/5 Running tests ──"
xcodebuild test -scheme Nocturn -destination 'platform=macOS,arch=arm64' 2>&1 | tail -4

echo "── 4/5 Committing ──"
git init -q 2>/dev/null || true
git add -A
git commit -q -m "feat: Nocturn v1 complete — dashboard, tests, icon, App Store docs

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>" || echo "(nothing new to commit)"
git log --oneline | head -3

echo "── 5/5 Opening in Xcode ──"
open Nocturn.xcodeproj

echo ""
echo "✅ Done. In Xcode: set your team under Signing & Capabilities (or add"
echo "   DEVELOPMENT_TEAM to project.yml), then Product → Archive to upload."
echo "   Full App Store steps: see SUBMISSION.md"
