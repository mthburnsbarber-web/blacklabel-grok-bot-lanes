# MOBILE-CYCLE-07 — 2026-09-21 evening ET (updated)

## Item 1 — 82 public claims on device
- UI Automation unlocked.
- PhoneAcceptance cycle-06: **9 passed / 12 failed** (21 harness tests). Not full 82-claim remap yet.
- Evidence: `STATE/iphone-portfolio-qa-20260921/phone-cycle-06.*`, `cycle-06-summary.json`.

## Item 2 — Academy sheets
- Developer **1.3.3 (36)** installed; `testAcademySheetBounds` **PASSED** including Certificates + after-scroll.
- Evidence: `sheet-bounds-build36.*`, `academy-build36-install.json`, `sheet-fix-cycle07.md`.
- DoD checker still hard-binds build 33; regenerate before contract PASS.
- **Public restore still pending:** App Store remains **1.3.0 (26)** — do not promote 36.

## Item 3 — Real Estate free decision + IAP
- Free accept saves a real DatabaseLead (code) + physical `testLiveCardRightSwipeSavesAndShowsHonestConnectorGate` **PASSED**.
- Evidence: `STATE/realestate-tinder-20260921/evidence/free-decision-physical-20260921.*`.
- ASC Starter/Growth/Pro localizations still **PREPARE_FOR_SUBMISSION** ($24.99/25, $49.99/55, $99.99/400). **Sandbox buys blocked until products leave prepare state.** IAP gate stays closed.

## Item 4 — Marketing connectors
- Root cause: Connectors lived in Overview, but iPhone Home roots at Dashboard only — Connectors were unreachable on device (builds ≤32).
- Fix: More tab groups now include Overview (`Sources/main.swift`). Physical test **PASSED** after install.
- Evidence: `STATE/marketing-mobile-connectors-20260921/physical-connectors-r5.*`, install receipts, nav patch.
- Store listing still **1.2** vs developer **1.0 (32-ish)** — align before promote.

## Item 5 — Vigil
- Public App Store download surface exists; `testVigilStoreDownloadSurface` passed in cycle-06.
- Local paid-core: **5 passed** (`STATE/grok-bot/vigil-paid-core-20260921.log`).

## Item 6 — Hold
- `MOBILE-SELLABLE-HOLD.md` remains active until remaining gates close (full claim coverage, Academy public restore, RE sandbox IAP, Marketing listing sync).
