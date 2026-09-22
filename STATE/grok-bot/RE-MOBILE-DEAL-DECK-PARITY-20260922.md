# RE Mobile ↔ blbestate.com Deal Deck parity — 2026-09-22

**Author:** mobile grok bot executor (box `grok-bot-vm-*`, Linux)  
**Written:** 2026-09-22 ~11:24 EDT (America/New_York)  
**Target Mac worktree:** `~/BlackLabel-Team/.worktrees/realestate-auth-mobile`  
**machineId requested:** `75ba8c96-11d2-42ad-b1f8-4eca9629bc9e` (Shell **ignored** — this session stays Linux)  
**Course-correct applied:** Mac Grok Bot web delta ~11:18–11:19 ET (photo honesty, live corpus, masking, no sample)

---

## HARD EXECUTION FACTS

| Check | Result |
|-------|--------|
| Hostname | `grok-bot-vm-*` (Linux) — **not** Darwin |
| `~/BlackLabel-Team/.worktrees/realestate-auth-mobile` | **MISSING** on this box (thin STATE mirror only) |
| `xcodebuild` / simulator | **ABSENT** |
| Physical iPhone install/launch/screenshot | **NOT DONE** (hard rule + no Mac) |
| Web Deal Deck | Box is editing `~/BlackLabelRealEstate-Website` (`deal-deck.js` / `.css` **untracked**, not landed) — mirrored card fields; did **not** fight web PR |
| Implementation vehicle | Cloned `shflikawgfhlaigrk/BlackLabelRealEstate` → branch `deal-deck-parity-20260922` from `release/apple-20260820` (auth-mobile DeckBuyBox train is Mac-local / not on remote) |

**Device prove waits on founder phone re-auth** (and a Mac-bound executor to apply + build).

---

## PHOTO HONESTY (intentional parity with web)

**Photos are NOT in the PropertyRecord / scan schema.**  
iOS Deal Deck uses a **void + gold-ink placeholder** with a **category glyph only**.  

Explicitly **do NOT** use:
- Apple Look Around / MapKit satellite as if it were the parcel
- Stock house photography
- Any invented multi-angle gallery

Page-bar chrome may show a single stub bar so layout matches the brief; it must not imply multiple real photos exist. When a real photo feed lands, multi-photo + page bars can light up without changing the product contract.

---

## LIVE CORPUS

| Source | Role |
|--------|------|
| `GET https://blbestate.com/api/index/scan?lat=&lng=&miles=` | **Primary** (same projection as web `deal-deck.js`; public-preview masked) |
| `https://api.blbestate.com` `/v1/stats`, `/v1/opportunities`, `/v1/search` | Corpus / fallback shapes |
| Live searchable states | **AZ CA FL NJ NY TX only** |
| Default cold-open | Phoenix, AZ · 3 mi (proven cards) |
| Empty geos / Utah archived | **Honest empty** — never invent parcels |
| Sample/demo/filler rows | Rejected in client (`sample` / `is_sample` / `demo` / `filler` / `source=sample`) |

Probed this turn: Phoenix scan returns live Maricopa rows with `owner_masked` / `mailing_masked`; no `photos` field.

---

## GAP TABLE (visual brief + founder locks)

| Requirement | Had (prior auth-mobile / overnight) | Missing on box reach | Fixed this turn (branch) |
|-------------|--------------------------------------|----------------------|---------------------------|
| Multi-photo + page bars | Overnight Tinder note claimed multi-angle when photos exist | Photos **not in API** | **Placeholder honesty** + stub page bar (intentional) |
| Chips ON photo (offer/spread/category) | Partial on device builds | Need scan/opportunity chips | **Yes** — assessed / basis / category / absentee / near-you / offer / spread when present |
| Near-you distance when location allowed | Partial | Hide when null | **Yes** — only after CLLocation authorize; else hidden |
| Full owner mailing + Copy | Overnight mailing PASS on device | Public-preview mask | **Yes** — show `mailing_masked` only; Copy; never invent |
| Area Builders → work queue | Partial | Hook | **Yes** — link when builders array non-empty (callback) |
| Guest browse live deals | Guest CRM path | Deal Deck = sample Oak Hollow behind paywall | **Yes** — unpaid PaidRoot → `DealDeckLiveView` |
| Soft “Keep this deal?” on save | Skip-trace gate historically | Soft auth gate | **Yes** — shortlist local + gate sheet |
| Strip SAMPLE / Explore sample from Deal Deck | Auth “Explore with sample data”; PaidRoot FREE SAMPLE | Founder lock | **Yes** — Browse live Deal Deck; teaching dossier relabeled; Deal Deck door is live |
| Identity “Swipe the property — not a spreadsheet.” | Missing | Needed | **Yes** on `DealDeckLiveView` |
| Magnetic void + gold `#c9a35f` | Gold was `#C9A961` | Brief token | **Yes** — default accent → `#C9A35F` |

---

## FILES TOUCHED

### On GitHub branch `deal-deck-parity-20260922` (`BlackLabelRealEstate`)

| File | Change |
|------|--------|
| `Sources/DealDeckLive.swift` | **NEW** — scan client, card, placeholder, chips, shortlist, Keep gate, identity |
| `Sources/RealEstatePaidCoreView.swift` | Unpaid door → `DealDeckLiveView` (not Oak Hollow sample) |
| `Sources/Auth.swift` | “Browse live Deal Deck” guest cold-open; reviewer creds → live guest (no sample) |
| `Sources/Premium.swift` / `Holographic.swift` / `Screens.swift` / `Theme.swift` | Gold default `#c9a35f` |

### STATE / box mirrors

| Path | Role |
|------|------|
| `/home/box/BlackLabel-Team/STATE/grok-bot/RE-MOBILE-DEAL-DECK-PARITY-20260922.md` | This note |
| `/workspace/mobile-fix-artifacts/re-deal-deck-parity-20260922/` | CopyFromBox pack + MAC-APPLY script |
| `/home/box/BlackLabelRealEstate-Website/deal-deck.js` | Web WIP (untracked) — field mirror only |

---

## BUILD RESULT

| Attempt | Result |
|---------|--------|
| Debug-iphonesimulator / unsigned generic iOS on this executor | **BUILD FAILED / BLOCKED** — no Darwin, no Xcode, auth-mobile worktree not mounted |
| Prior Mac truth (not re-run) | auth-mobile overnight/simulator builds had **BUILD SUCCEEDED** historically; **not** claimed for this patch set |

### Mac apply + build (parent / Mac-bound executor)

```bash
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Users/michaelbarber/Downloads/Xcode-beta.app/Contents/Developer}"
WT="$HOME/BlackLabel-Team/.worktrees/realestate-auth-mobile"
# Prefer: merge GitHub branch deal-deck-parity-20260922 into the worktree, OR
# copy Sources/DealDeckLive.swift + re-apply PaidRoot/Auth/gold hunks onto auth-mobile tip.
cd "$WT"
xcodegen generate   # if project.yml driven
xcodebuild -project BlackLabelRealEstate.xcodeproj -scheme BlackLabelRealEstateiOS \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/bl-re-deal-deck-parity CODE_SIGNING_ALLOWED=NO build
# Expect: ** BUILD SUCCEEDED **
```

Device prove: waits on founder phone re-auth; do **not** install/launch from this note.

---

## STILL OPEN

| Item | Owner / path |
|------|----------------|
| Merge branch into **auth-mobile** tip (DeckBuyBox / ledger / multi-photo chrome already there) | Mac-bound executor |
| Simulator/unsigned **BUILD SUCCEEDED** proof for this exact patch | Mac `xcodebuild` |
| Wire `onOpenWorkQueue` → real Work Queue section in auth-mobile `Screens`/`AdaptiveLayout` | Mac |
| Web `deal-deck.js` land + deploy | Web / Mac Grok (box has untracked files — don’t fight) |
| Utah live searchable | Archived in API — ops/activation; iOS must stay honest-empty |
| Real photo feed | API schema addition; until then placeholder stays |
| Soft-gate → full account while unpaid PaidRoot still blocks CRM | Product: browse OK; paid CRM still StoreKit — confirm founder intent |
| Strip residual “sample” strings in CRM DemoData / teaching dossier if still reachable | Optional cleanup |
| Device screenshots / DealDeckAcceptance updates for live-not-sample | After phone re-auth |

---

## WEB SYNC NOTE

Mac/Grok (this box) **is** editing `BlackLabelRealEstate-Website` Deal Deck (`deal-deck.js` untracked). iOS card fields aligned to scan `normalizeRow`: id, parcel, situs, owner_masked, mailing_masked, absentee, assessed, basis, gap, builders, distance — **no photos**. Do not invent a competing API shape.

---

## SUCCESS CRITERIA vs OUTCOME

| Criterion | Outcome |
|-----------|---------|
| Gap inventory written | **YES** (this file) |
| Sample language removed from Deal Deck iOS UX | **YES** on branch (PaidRoot + Auth); teaching dossier relabeled |
| Critical parity gaps fixed or honestly blocked | **Fixed on branch**; **blocked** on auth-mobile apply + build |
| Simulator/unsigned build attempted with real result | **FAILED/BLOCKED** (no Mac toolchain) — honest |
| STATE note written | **YES** |
| Device prove | **WAITS** on founder phone re-auth |


---

## GIT PUSH (box → GitHub)

| Field | Value |
|-------|--------|
| Repo | `shflikawgfhlaigrk/BlackLabelRealEstate` |
| Branch | `deal-deck-parity-20260922` |
| Commit | `fef1b18` |
| PR create | https://github.com/shflikawgfhlaigrk/BlackLabelRealEstate/pull/new/deal-deck-parity-20260922 |

Mac: fetch/merge into `realestate-auth-mobile` tip (or run `MAC-APPLY-DEAL-DECK-PARITY.sh` then cherry-pick Auth/PaidRoot/gold).
