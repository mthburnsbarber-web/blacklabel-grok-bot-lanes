# Brand icon source patch — executor blocked (2026-09-22 ~15:28 ET)

## Blocker
Executor subagent `sand-subagent-bd6382b3` only has **Linux box Shell** (`grok-bot-vm`).  
Shell tool schema for this subagent has **no `machineId`**; cannot reach `/Users/michaelbarber/*`.

Parent steering confirmed:
- Masters identical: `~/Downloads/{academy logo,marketing logo,vigil logo,the real estate icon}.png` == STATE brand-icons
- ASC 1024s already at `~/BlackLabel-Team/STATE/brand-icons-20260922/derived/asc-1024/`

## Unblock (parent — one of)
1. Re-dispatch executor with `machine: 75ba8c96-11d2-42ad-b1f8-4eca9629bc9e` and ask it to run:
   `bash ~/BlackLabel-Team/STATE/brand-icons-20260922/MAC-APPLY-BRAND-ICONS-20260922.sh`
2. Or run that script yourself on Mac Shell (no Terminal.app UI needed via local-exec).

## Script
`STATE/brand-icons-20260922/MAC-APPLY-BRAND-ICONS-20260922.sh`

Does:
- Backup each AppIcon.appiconset / windows Assets once to `*.bak-pre-brand-20260922`
- Regen every PNG listed in Contents.json via `sips -z` from locked masters
- Patch Academy iOS + any Mac AppIcon under Academy/Home
- Patch Marketing / Real Estate Mac AppIcons (+ Marketing iOS if present)
- Patch Vigil Home iOS AppIcon (+ Mac if found)
- Patch RE windows msix + msix-layout Assets; discover academy/marketing/vigil windows Assets
- Refresh ASC 1024s; write APPLY-REPORT-*.txt with pixel proof

No xcodebuild / notarize / ASC submit.
