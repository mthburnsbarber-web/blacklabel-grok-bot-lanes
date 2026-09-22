#!/bin/bash
# Apply Deal Deck parity onto auth-mobile worktree. RUN ON MAC ONLY.
# machineId 75ba8c96-11d2-42ad-b1f8-4eca9629bc9e — no Terminal.app UI, no phone install.
set -euo pipefail
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Users/michaelbarber/Downloads/Xcode-beta.app/Contents/Developer}"
export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
WT="${WT:-$HOME/BlackLabel-Team/.worktrees/realestate-auth-mobile}"
SRC_REPO="${SRC_REPO:-$HOME/BlackLabelRealEstate}"
STATE="$HOME/BlackLabel-Team/STATE/grok-bot"
test "$(uname -s)" = Darwin || { echo FATAL:not Darwin; exit 78; }
test -d "$WT" || { echo FATAL:missing $WT; exit 78; }
mkdir -p "$STATE"
# Prefer git fetch of deal-deck-parity-20260922 if remotes allow; else copy DealDeckLive.swift from pack.
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"
cp -f "$PACK_DIR/DealDeckLive.swift" "$WT/Sources/DealDeckLive.swift"
echo "Copied DealDeckLive.swift → $WT/Sources/"
# Remind: still need Auth/PaidRoot/gold hunks from branch (git cherry-pick or manual).
echo "Next: merge/cherry-pick origin/deal-deck-parity-20260922 Auth+PaidRoot+gold OR re-apply hunks."
if command -v xcodegen >/dev/null; then (cd "$WT" && xcodegen generate); fi
DD=/tmp/bl-re-deal-deck-parity
rm -rf "$DD"; mkdir -p "$DD"
PROJ=$(find "$WT" -name 'BlackLabelRealEstate.xcodeproj' | head -1)
set +e
xcodebuild -project "$PROJ" -scheme BlackLabelRealEstateiOS -configuration Debug \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DD" \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | tee "$STATE/RE-MOBILE-DEAL-DECK-PARITY-build.log" | tail -40
XC=$?
set -e
echo xcodebuild_exit=$XC
rg -n 'BUILD SUCCEEDED|BUILD FAILED' "$STATE/RE-MOBILE-DEAL-DECK-PARITY-build.log" | tail -5 || true
exit $XC
