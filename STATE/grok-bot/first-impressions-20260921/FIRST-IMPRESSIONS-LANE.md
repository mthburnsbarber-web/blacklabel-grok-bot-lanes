# First Impressions Lane — 2026-09-21 CT
**Owner:** Grok Bot (founder-facing ops)  
**Goal:** First ~30 seconds of each product feel welcoming, intuitive, professional — not feature-complete.  
**Revenue rank (SUMMARY):** Vigil → Leads → Ace → Academy → Marketing → Real Estate

## Priority score (worst first impression × revenue potential)

| Rank | Product | Impression risk | Why | Action |
|------|---------|-----------------|-----|--------|
| 1 | **BLVigil (iOS)** | High × High revenue | First screen was hub IP + token + Connect (paywall if not entitled); sample buried | **IMPLEMENTED** sample-first welcome |
| 2 | **Ace** | High × High | First-run can land on setup / repair / permission proof before “helpful partner” | Handoff — **Ace build87 lease active; no source edits** |
| 3 | **Academy (iOS public)** | High × Mid | Public free-sample claims FAIL on owner/dev (“Owner · full library”); buyer expects 3-of-332 | Handoff — restore public 1.3.0 (26) for buyer proof; keep sample banner honest |
| 4 | **Marketing (iOS)** | Mid × Mid | Connectors lived under Overview but Home = Dashboard only → dead end | **DONE earlier** More tab includes Overview; keep store↔dev version aligned |
| 5 | **Leads** | Mid × High $ potential | Packaging/sales gap more than UI; no dedicated mobile first-run audited this turn | Handoff — package export/API; friendly empty “your list is ready” surface |
| 6 | **Real Estate (iOS/mac)** | Lower door × lower until ASC | Guest + sample doors exist and copy is honest; sample scroll / Restore still fail on device | Keep guest CTA; make Oak Hollow dossier the immediate sample hero after Explore |
| 7 | **Others** (Sovereign, Utah, Circuit…) | Low | Don’t invest first-impression polish until cut/merge | Hold |

---

## Per-product audit (first ~30 seconds)

### 1. BLVigil (iPhone companion)
**Before:** Form titled “Home hub” with address + token, Connect (subscription sheet if not entitled), then “Preview with sample data” below. Feels like IT setup, not “someone is home.”  
**Friction:** Advanced fields first; sample secondary; Connect→paywall before curiosity is rewarded.  
**Minimal changes:**
1. **DONE in `~/BlackLabelHome/ios/VigilRemoteApp.swift`:** “Welcome home” + prominent **Take a 30-second tour** (sample) first; hub fields under disclosure “I already have a home hub.”
2. Mirror same UX into App Store fixes tree when shipping.
3. Handoff: one-line empty alert copy stays soft (“No alerts yet — you’re all clear”) once on dashboard.
4. Do not auto-prompt Monitoring sheet on first paint of sample.

### 2. Ace (Mac)
**Current:** First-run tour + setup phases (provider → core permissions → optional live Command-Shift proof). Failure path exposes Repair. Policy already tries not to trap Start behind optional tour.  
**Friction:** Permissions and provider choice dominate emotional first minute; repair UI can feel like a broken install.  
**Minimal changes (lease-blocked — propose only):**
1. First paint: one sentence “Ace helps you on this Mac” + Start when provider+permissions ready; tour optional secondary.
2. Repair copy in plain English (“Screen recording is off — turn it on in System Settings”) not internal identifiers.
3. Skip auto-replay of unfinished tour after crash if owner already passed Start (policy partially there).
**Handoff:** Ace engineer seat after `ace-cli:build87-completion` lease clears.

### 3. Black Label Academy (iPhone)
**Current (public contract):** Exact three-lesson free sample + paywall; pillars/search/tutor.  
**Observed:** Owner/developer installs show “Owner · full library” — public free-sample tests FAIL. Sheets fixed on building 36 but public is still 1.3.0 (26).  
**Friction:** Wrong entitlement skin for buyers; dense library without a “start here” card; Certificates/calculators sheets historically clipped.  
**Minimal changes:**
1. Public restore to 1.3.0 (26) on device for buyer-facing QA.
2. Home: single **Start with lesson 1 of your free sample** card above pillar list.
3. Keep unlock banner copy short; price once, no wall of trial legalese on first paint.
**Handoff:** Academy iOS seat + hold (`MOBILE-SELLABLE-HOLD.md`).

### 4. Marketing Studio (iPhone)
**Current:** Demo/sample + guest paths; tabs Home/Create/Distribute/Grow/More.  
**Friction:** Connectors unreachable when Overview only under Home but Home roots at Dashboard — fixed by More → `["Overview","Account"]` in `marketing-auth-mobile`. Store 1.2 vs developer ~1.0 drift.  
**Minimal changes:**
1. **Already done:** Overview on More.
2. First open: if sample, show one card “This is sample — try Connectors under More” once.
3. Align public listing build with developer before promotion.
**Handoff:** Marketing mobile seat for one-time tip card.

### 5. Real Estate CRM
**Current:** Three doors — guest / sample / sign-in; Onboarding copy points access key to Settings (honest).  
**Friction:** After Explore, dossier/sample scroll + Restore failed cycle-06; ASC IAP still PREPARE_FOR_SUBMISSION. Guest empty workspace can feel blank.  
**Minimal changes:**
1. After “Explore with sample data”, land on Oak Hollow dossier hero (not empty CRM chrome).
2. Guest empty: one card “Save a property to start your shortlist” (free tangible value).
3. Keep `Onboarding.guestCTA` as-is — already friendly.
**Handoff:** RE mobile seat; ASC for IAP.

### 6. Leads (packaging)
**Not a first-open UI audit from App Store this turn.** Revenue potential is high; first impression is likely purchase/export UX on web/Mac.  
**Minimal:** Friendly “355k verified ready” honesty only after truth.json; empty state for new buyers with one export CTA.

---

## Implemented this turn
| Change | Path | Status |
|--------|------|--------|
| Vigil iOS sample-first welcome | `~/BlackLabelHome/ios/VigilRemoteApp.swift` (`ConnectView`) | **Patched** — not yet rebuilt/installed on phone |
| Marketing Overview on More | `marketing-auth-mobile` (prior) | Already shipped to device proof r5 |
| Ace UI | — | **Blocked** by build87 lease |
| Academy / RE copy | — | Proposed only |

## Not implemented (need seat / lease / device)
- Rebuild+install Vigil iOS with new ConnectView; physical first-open screenshot
- Ace first-paint copy (lease)
- Academy “Start free sample” home card
- RE Oak Hollow hero landing
- Leads packaging surface

## Proof / next
1. Install Vigil from `BlackLabelHome` iOS lane onto UDID `00008140-001A0DA12EA2801C` and confirm ConnectView shows Welcome + tour first.
2. Do not promote portfolio until mobile hold clears — except Vigil sell-now path stays valid with honest sample.
