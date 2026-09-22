# Windows Grok Bot sync — 2026-09-21 CT

## Root cause of “no data flowing”
Windows `michaelscomp` runs Grok Bot (local-exec daemon under `~\.grokbot\`) and has `~\blacklabel\` (Ace Windows portfolio notes), but **no BlackLabel-Team tree** and no Mac STATE mirror. USB-C shows on Mac as `en8` link-local `169.254.137.183`; Windows has **no USB Ethernet/RNDIS adapter up** (only Wi-Fi + Tailscale). Shared folders over that link were never established — so Mac STATE never reached Windows.

## What landed on Windows
Path: `C:\Users\michael\blacklabel\notes\`
- `win-sync-grokbot.tgz` (+ expanded under `win-sync-expanded/` when tar ran)
- `SYNC-BRIEF-20260921.md`
- `MOBILE-CYCLE-07.md`
- `MOBILE-SELLABLE-HOLD.md`
- `ACE-GROK-INTEGRATION-20260921.md`

Mac source also at: `~/BlackLabel-Team/STATE/grok-bot/windows-sync/`

## Next (optional peer)
- Mirror ongoing STATE into `C:\Users\michael\blacklabel\grok-bot-sync\` or create a thin `BlackLabel-Team\STATE\grok-bot\` on Windows for local-exec reads.
- Prefer Wi-Fi/Tailscale copy via Grok Bot CopyFromBox over USB until RNDIS/shared-folder is set up.
