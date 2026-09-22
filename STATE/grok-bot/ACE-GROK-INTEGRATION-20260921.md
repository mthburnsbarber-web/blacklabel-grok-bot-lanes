# Ace ↔ Grok integration map — 2026-09-21 (CT)

## Lease gate (do not force)
Active lease `ace-cli:build87-completion` / task `ACE.BUILD87.COMPLETE.20260921` covers Ace build-87 completion source.
**No Ace `leanring-buddy` source edits in this turn.** Integration plan only until lease clears or founder assigns a Grok-provider task lease.

## How Claude + Codex (GPT lane) are wired today

### Seat / enum
- `BrainCLI` (`leanring-buddy/BrainCLI.swift`): customer-selectable providers = **codex | claude | qwen** (Qwen optional via `BLIncludesQwen`).
- Codex = OpenAI / ChatGPT subscription lane (“Codex CLI”).
- Claude = Anthropic / Claude Code lane.
- Qwen = embedded local brain (not a third cloud seat like Grok would be).

### Runtime packs
- `AceRuntimePackKind`: **codex | claude | voice** (`AceRuntimePacks.swift`).
- Bundled under `/Applications/Ace.app/Contents/Resources/{codex,claude}`.
- Staging scripts: `script/stage_codex_runtime.sh`, `script/stage_claude_runtime.sh`.

### Connection + receipts
- `BrainConnection.swift`: per-`BrainCLI` status map, onboarding state, `SelectedBrainCLI` preference, reusable runtime proofs, private auth state (Codex ChatGPT sign-in vs Claude `.claude.json` / credential files).
- Handoff receipts keyed by provider (`BrainConnectionReceipt` / invalidate paths).
- Panel accessibility IDs (`PermissionRepairCoordinator.swift`):
  - `ace.panel.provider.codex.connect`
  - `ace.panel.provider.claude.connect`
  - `ace.panel.provider.qwen.connect`

### Turn / call path
- `AceProviderTurn.swift` takes `provider: BrainCLI` and routes the closed enum into the provider execution path.
- `RedProviderExecutionProfile.swift`: codexFullAccess / claudePermissionBypass profiles.
- Claude-specific: `ClaudeAPI.swift`, `AceClaudeModel.swift`.
- Codex-specific: `CodexModelResolver.swift` + staged Codex runtime.

### Agent-bus note
Team `AGENT-SYSTEM.md`: Claude and Codex prompts are **runtime adapters, never authority**. Grok Bot founder-ops seat is outside Atlas roster unless assigned — product Grok-in-Ace is a **BrainCLI provider**, not the Grok Bot chat agent.

## What to build for Grok (mirror pattern — deferred until lease)

1. Add `case grok` to `BrainCLI` (+ displayName “Grok”, vendorLine “xAI · runs on your xAI / Grok API key or subscription”, symbol, install/sign-in copy).
2. Extend `customerChoices` behind a feature flag (e.g. `BLIncludesGrok`) mirroring Qwen’s sealed flag pattern — or ship as always-on once runtime exists.
3. Add `AceRuntimePackKind.grok` **or** host via API-only path (no embedded CLI) if Grok uses cloud HTTP like a thin HostedBrainClient lane — decide against Claude/Codex CLI embedding first.
4. Wire `BrainConnection` switches: auth proof (API key in Keychain / xAI OAuth), status seed maps, panel id `ace.panel.provider.grok.connect`.
5. Extend `AceProviderTurn` + any exhaustive `switch` sites (~100+ BrainCLI references) — compile-fail closed until complete.
6. Tests: mirror `test_ace_claude_model.swift` / `test_codex_model_resolver.swift` / provider matrix scripts.
7. Handoff receipts: same receipt store keying as Claude/Codex.

**Recommended first cut:** API-key HostedBrain path (not embedding a Grok CLI binary) to avoid Acepack signing complexity while proving the seat UI + turn wiring.

## Files touched this turn
- This report only.
- Founder strategy lanes copied to `STATE/grok-bot/founder-lanes-20260921/`.

## Next
Clear or obtain a dedicated lease for `ace:provider-grok`, then implement enum + connection + panel + turn switches with compile-gated tests. Do not collide with `ACE.BUILD87.COMPLETE.20260921`.
