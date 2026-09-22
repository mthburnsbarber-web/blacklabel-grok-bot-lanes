# WINDOWS-REBRAND-BUILDABLE — 2026-09-22

**Author:** Grok Bot executor (Linux box `grok-bot-vm-310379197`, host machineId `4b9b996b-…`)  
**Requested Windows:** michaelscomp `f00ca738-2a76-4219-9d07-9dc6d7dcea3d` — **NOT reachable from this seat**  
**Requested Mac (STATE only):** `75ba8c96-11d2-42ad-b1f8-4eca9629bc9e` — **NOT reachable** (no Shell.machineId / ListMachines / SendToAgent in executor tool schema)  
**Time:** 2026-09-22 2:03 PM EDT  
**Contact:** michael@blacklabelbots.com · Brand MTH / Black Label Bots  

## Founder locks applied

| App | Public display name | Bundle / PFN |
|-----|---------------------|--------------|
| Real Estate / Deal Deck | **SalesSwipe** (not SwipeSales) | leave `com.blacklabel.*` / `MichaelBarber.BlackLabelRealEstate` stable |
| Marketing | **Brandlit** | leave `com.blacklabel.marketing` stable |
| Academy | **CoGuide** | leave `com.blacklabel.academy*` / `com.blacklabel.academy.win` stable |

No entitlements / paywall / product-field invention. Display / MagicalAuth / ProductName / CFBundleDisplayName / onboarding product-title only.

---

## 0. Seat / reachability

| Probe | Result |
|-------|--------|
| Shell with `machineId=f00ca738-…` | Parameter **not in executor Shell schema**; command ran on Linux box (PowerShell syntax failed under bash) |
| `C:\Users\michael\blacklabel\…` / `/mnt/c/…` | **Missing** on this VM |
| `tailscale` / SSH to michaelscomp | **Not installed** on box |
| `swift` | **Not installed** on box |
| Circuit-Converted trees on box | **Absent** (only conversion receipts under `/workspace/windows-sync/conversion-receipts/`) |
| Windows grok bot peer | Exists as agent `67f10beb-…` (windows grok bot) — this executor cannot SendToAgent |

**Blocker for live Windows apply + Circuit builds:** re-dispatch this task to **windows grok bot** (sameMachine on michaelscomp) or parent Shell with `machineId=f00ca738-…`, then run:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\michael\blacklabel\notes\windows-magical-20260922\scripts\Apply-WindowsRebrand-20260922.ps1
```

(Script packaged at `/workspace/windows-magical-20260922/scripts/Apply-WindowsRebrand-20260922.ps1` — copy to Windows notes before run.)

---

## 1. Inventory (box mirrors — pre/post)

### Pre (evidence)

| Surface | Old user-visible name | Path (box) |
|---------|----------------------|------------|
| Marketing AppBrand fallback | Black Label Marketing | `/workspace/mkt-wire/BlackLabelMarketing/Sources/AppBrand.swift` |
| Marketing CFBundleDisplayName / PRODUCT_NAME | Black Label Marketing | `…/project.yml` |
| MagicalAuthView title | `MARKETING` | `/workspace/windows-magical-20260922/marketing/MagicalAuthView.cs` |
| Magical apply MessageBox | Black Label Marketing | `…/scripts/Apply-MarketingMagical.ps1` |
| RE CFBundleDisplayName / PRODUCT_NAME | Black Label Real Estate | `/workspace/notes/blbestate-audit/repos/BlackLabelRealEstate/{Sources/Info*.plist,project.yml}` |
| RE MSIX Properties/DisplayName + VisualElements | Black Label Real Estate | `…/BlackLabel-Team/products/real-estate/windows/msix/AppxManifest.xml` (Identity Name **untouched**) |
| RE web UI `<title>` / brand chrome | Black Label Real Estate | `/workspace/windows-magical-20260922/src/re-ui/{index.html,app.js}` |
| Academy Electron productName / window title | Black Label Academy | `/workspace/windows-magical-20260922/src/academy-shell/{package.json,main.js}` (`appId` untouched) |
| Circuit live trees (Windows) | unknown this turn | `C:\Users\michael\blacklabel\Circuit-Converted\BlackLabel{RealEstate,Marketing,Academy}-windows` — **unread** |

### Still says old names (intentional / out of scope)

| What | Why left |
|------|----------|
| File headers `// Black Label Real Estate — …` | Not user-visible product title |
| LeadDomain niche label `"Real Estate"` | Category enum, not app title |
| Store `Identity Name` / Publisher CN / `MichaelBarber.BlackLabel*` | Lock: keep Store identity stable |
| `com.blacklabel.*` bundle IDs | Lock |
| Company attribution in some footers (`by Black Label`) | Company line, not product title |
| Mac canonical `~/BlackLabel*` Sources | Mac unreachable |
| Live Windows Circuit Package.swift trees | Windows unreachable |
| Comment in marketing `project.yml` UITest override note | Updated to mention Brandlit |

---

## 2. Files changed on this seat (box mirrors)

1. `/workspace/mkt-wire/BlackLabelMarketing/Sources/AppBrand.swift` — fallback → **Brandlit**
2. `/workspace/mkt-wire/BlackLabelMarketing/project.yml` — PRODUCT_NAME + CFBundleDisplayName → **Brandlit**
3. `/workspace/mkt-wire/BlackLabelMarketing/Sources/ReferenceReelEngine.swift` — product list Marketing/Academy/RE → Brandlit/CoGuide/SalesSwipe
4. `/workspace/windows-magical-20260922/marketing/MagicalAuthView.cs` — title `MARKETING` → `BRANDLIT`
5. `/workspace/windows-magical-20260922/scripts/Apply-MarketingMagical.ps1` — MessageBox → Brandlit
6. `/workspace/notes/blbestate-audit/repos/BlackLabelRealEstate/Sources/Info.plist` — CFBundleDisplayName → **SalesSwipe**
7. `/workspace/notes/blbestate-audit/repos/BlackLabelRealEstate/Sources/Info-iOS.plist` — CFBundleDisplayName → **SalesSwipe**
8. `/workspace/notes/blbestate-audit/repos/BlackLabelRealEstate/project.yml` — PRODUCT_NAME + CFBundleDisplayName → **SalesSwipe**
9. `/workspace/notes/blbestate-audit/repos/BlackLabelRealEstate/Sources/UpdaterUI.swift` — user strings → SalesSwipe
10. `/workspace/notes/blbestate-audit/repos/BlackLabel-Team/products/real-estate/windows/msix/AppxManifest.xml` — Properties/DisplayName + VisualElements DisplayName → **SalesSwipe** (Identity Name placeholder unchanged)
11. `/workspace/windows-magical-20260922/src/re-ui/index.html` — `<title>` → SalesSwipe
12. `/workspace/windows-magical-20260922/src/re-ui/app.js` — brand chrome + footer → SalesSwipe by Black Label
13. `/workspace/windows-magical-20260922/src/academy-shell/package.json` — productName → **CoGuide** (`appId` `com.blacklabel.academy.win` kept)
14. `/workspace/windows-magical-20260922/src/academy-shell/main.js` — BrowserWindow title → CoGuide
15. `/workspace/windows-magical-20260922/scripts/Apply-WindowsRebrand-20260922.ps1` — **NEW** Windows-seat apply + Circuit build driver

---

## 3. Build results

| Target | Command | Exit | Notes |
|--------|---------|-----:|-------|
| BlackLabelRealEstate-windows | `swift build -Xswiftc -DCIRCUIT_WINDOWS_SIM` | **N/A** | Tree not on this VM; `swift` missing |
| BlackLabelMarketing-windows | same | **N/A** | same |
| BlackLabelAcademy-windows | same | **N/A** | same; Academy Circuit path also not mirrored |

Conversion receipts (prior, Mac/Windows): Marketing 24.5% / RE 38.4% / Academy 57.9% Mac-sim; native reverify PASS on michaelscomp earlier today per `CIRCUIT-CONVERT-QUEUE.md` — **not re-run this turn**.

---

## 4. Next seat (windows grok bot) checklist

1. Copy `Apply-WindowsRebrand-20260922.ps1` + updated MagicalAuthView.cs into `C:\Users\michael\blacklabel\notes\windows-magical-20260922\`.
2. Run the apply script (inventories, renames display strings in Circuit-Converted + repos worktrees, runs three `swift build -Xswiftc -DCIRCUIT_WINDOWS_SIM`).
3. Fix **rename-only** compile breaks if any.
4. Append real exit codes into this receipt on Windows notes + STATE.
5. Optional Mac: mirror receipt to `~/BlackLabel-Team/STATE/demo-day-20260922/` when Mac reachable.

---

## 5. Receipt locations this turn

- `/workspace/notes/WINDOWS-REBRAND-BUILDABLE-20260922.md` (this file)
- `/home/box/BlackLabel-Team/STATE/demo-day-20260922/WINDOWS-REBRAND-BUILDABLE-20260922.md` (mirror)
- **Not written:** `C:\Users\michael\blacklabel\notes\…` (Windows unreachable)
- **Not written:** Mac `~/BlackLabel-Team/STATE/demo-day-20260922/…` (Mac unreachable)
