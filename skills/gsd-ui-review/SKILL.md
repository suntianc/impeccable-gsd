---
name: gsd-ui-review
description: "Retroactive 6-pillar UI audit with Impeccable design distinctiveness scoring (Pillar 7) and --fix support"
argument-hint: "<phase-number> [--fix [--dry-run] [--all]]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
  - Agent
  - AskUserQuestion
---

<objective>
Retroactive visual audit of implemented frontend code using the 6-pillar framework extended with Impeccable design distinctiveness criteria.

Extends the standard /gsd:ui-review workflow by:
1. Loading .impeccable.md project design context (if present) into the auditor prompt
2. Adding Impeccable anti-pattern detection (AI slop checks) to the audit
3. Scoring design distinctiveness as Pillar 7 in UI-REVIEW.md
4. `--fix` flag: reads UI-REVIEW.md findings, classifies auto-fixable vs manual-only, spawns gsd-impeccable-fixer to apply design fixes with atomic commits

Flags:
- `--fix` — after audit (or if UI-REVIEW.md already exists), apply auto-fixable findings
- `--dry-run` — with --fix: classify findings without applying any changes
- `--all` — with --fix: include Pillar 7 / low-severity findings in fix scope (default: BLOCKER + WARNING only)
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/ui-review.md
@$HOME/.claude/skills/impeccable/SKILL.md
@$HOME/.claude/skills/impeccable/references/typography.md
@$HOME/.claude/skills/impeccable/references/color-and-contrast.md
@$HOME/.claude/skills/impeccable/references/spatial-design.md
</execution_context>

<impeccable_integration>
## Impeccable Distinctiveness Audit

**Run before spawning gsd-ui-auditor (before Step 3):**

```bash
IMPECCABLE_CTX=""
if [ -f .impeccable.md ]; then
  IMPECCABLE_CTX=".impeccable.md"
  echo "✅ Found .impeccable.md — design context loaded for distinctiveness audit"
else
  echo "ℹ No .impeccable.md — auditing against Impeccable reference standards"
fi
```

---

### Auditor Injection

**When building the gsd-ui-auditor prompt (Step 3), add these paths to `<files_to_read>`:**

```markdown
{If IMPECCABLE_CTX is set: "- .impeccable.md (Project design context — expected aesthetic direction and brand personality)"}
- $HOME/.claude/skills/impeccable/references/typography.md (Typography quality standards)
- $HOME/.claude/skills/impeccable/references/color-and-contrast.md (Color quality standards)
- $HOME/.claude/skills/impeccable/references/spatial-design.md (Spatial design quality standards)
```

**Add this block after `<files_to_read>`:**

```markdown
<impeccable_audit_extension>
After scoring all 6 standard pillars, run the following anti-pattern checks and add
**Pillar 7: Design Distinctiveness** to UI-REVIEW.md.

Anti-pattern grep checks:

```bash
# Detect AI slop fonts in use
grep -rn "Inter\|Roboto\|Open.Sans\|Arial" src --include="*.css" --include="*.tsx" --include="*.html" 2>/dev/null | grep -i "font"

# Detect purple-blue gradient patterns (common AI slop signal)
grep -rn "purple\|violet\|indigo" src --include="*.css" --include="*.tsx" 2>/dev/null | grep -iE "gradient|from-|to-"

# Check for modern color usage (oklch signals intentional design)
OKLCH_COUNT=$(grep -rn "oklch\|color-mix" src --include="*.css" 2>/dev/null | wc -l)

# Detect generic copy strings
grep -rn '"Submit"\|"OK"\|"Cancel"\|"Save"\|"No data"\|"Nothing here"\|"Something went wrong"' src --include="*.tsx" --include="*.jsx" 2>/dev/null
```

Score Pillar 7: Design Distinctiveness (1-4):

- **4 — Distinctive:** Unique font pairing with clear personality, oklch colors with purposeful palette, declared spatial rhythm, memorable visual identity. Could identify this product by UI alone.
- **3 — Character:** Mostly standard choices but with ≥1 deliberate distinctive element (unusual font, unique color, strong spacing rhythm, sharp copywriting)
- **2 — Generic:** System fonts, standard blue/gray palette, typical SaaS card layout. Functional but forgettable.
- **1 — AI Slop:** Inter font + purple-blue gradient + rounded white cards + "Submit" buttons + "No data found" empty states. Indistinguishable from AI-generated defaults.

{If .impeccable.md found: "Compare actual implementation against the intended design direction from .impeccable.md. Note any divergences between intended aesthetic and what was built."}

Include specific grep evidence in findings for each point deduction.
For score 1-2: provide concrete remediation steps (specific font alternatives, oklch color declarations, copy rewrites).

Each finding in UI-REVIEW.md MUST include machine-readable metadata for the fix pipeline.
Write the metadata as a single-line HTML comment immediately before each finding heading:

`<!-- finding id="P{pillar}-{N}" pillar="{1-7}" severity="BLOCKER|WARNING|INFO" files="{comma-separated paths}" fix_hint="{one-line concrete change}" -->`

Example:
`<!-- finding id="P1-01" pillar="1" severity="BLOCKER" files="src/components/LoginForm.tsx" fix_hint="Replace 'Submit' button label with 'Sign In'" -->`

Rules:
- Single line only — never multi-line
- All values double-quoted
- `files` is a comma-separated string (not JSON array)
- Do NOT include an `auto_fixable` field — classification is done by the fix pipeline, not the auditor
- Place the comment on the line immediately before the finding heading (e.g. `### P1-01 — ...`)

Add Pillar 7 row to the score table in UI-REVIEW.md:
```markdown
| 7. Design Distinctiveness | {1-4}/4 | {one-line summary} |
```

Update "Overall" score to be out of 28 (not 24).
</impeccable_audit_extension>
```

---

## Fix Flow Steps

(Entered from `<process>` when FIX_MODE=true. Flags are already parsed.)

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► UI REVIEW FIX — PHASE {N}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Reading findings from {UI_REVIEW_FILE}...
```

**Step F1: Parse findings from UI-REVIEW.md**

Extract all single-line `<!-- finding ... -->` comments using this pattern:
`<!-- finding id="..." pillar="..." severity="..." files="..." fix_hint="..." -->`

Parse each attribute by name from within the comment. For each finding record: `id`, `pillar` (int), `severity`, `files` (split on comma), `fix_hint`.

Filter by severity:
- Default (no `--all`): include BLOCKER + WARNING only
- With `--all`: include all severities

**Step F2: Classify findings as auto-fixable or manual-only**

The orchestrator classifies each finding using this capability table — the auditor does NOT decide this:

| Condition | Classification | Reason |
|-----------|---------------|--------|
| Pillar 1 + specific file + string replacement | ✅ auto | Targeted text change |
| Pillar 3 + CSS file + hex→oklch conversion | ✅ auto | Mechanical color transform |
| Pillar 3 + accent overuse + specific elements cited | ✅ auto | Class removal/swap |
| Pillar 4 + font swap (slop→specific alternative) | ✅ auto | CSS/config change |
| Pillar 4 + font size consolidation (specific classes) | ✅ auto | Class replacement |
| Pillar 5 + specific spacing values cited | ✅ auto | Value replacement |
| Pillar 6 + missing copy string (empty/error state) | ✅ auto | String addition |
| Pillar 7 + gradient→solid on specific element | ✅ auto | CSS rule change |
| Pillar 7 + slop font (maps to Pillar 4 font swap) | ✅ auto | CSS/config change |
| Pillar 2 — visual hierarchy / focal point | ❌ manual | Requires design judgment |
| Pillar 5 — full spacing rhythm overhaul | ❌ manual | Widespread architectural change |
| Pillar 6 — error boundary / architectural patterns | ❌ manual | Structural decision |
| Pillar 7 — generic identity (no specific element) | ❌ manual | Needs design direction |
| Any finding with no `files` attribute | ❌ manual | Cannot locate target |

**Step F3: Present classification table**

```
## UI Fix Classification — Phase {N}

| ID | Pillar | Severity | Auto-fixable? | Finding |
|----|--------|----------|---------------|---------|
| P1-01 | Copywriting | BLOCKER | ✅ Yes | Generic CTA "Submit" in LoginForm.tsx |
| P3-01 | Color | WARNING | ✅ Yes | Hex-only colors in globals.css |
| P4-01 | Typography | WARNING | ✅ Yes | Inter as sole font — no personality font |
| P7-01 | Distinctiveness | WARNING | ✅ Yes | Purple-blue gradient in Hero.tsx |
| P2-01 | Visuals | WARNING | ❌ Manual | No clear focal point — design judgment needed |
| P6-01 | Experience | BLOCKER | ❌ Manual | No error boundary — architectural decision |

Auto-fixable: {N} findings
Manual-only: {N} findings (listed with guidance after fixes complete)
```

**If `--dry-run`:** Display table and exit. Do not spawn fixer.

**Step F4: Spawn gsd-impeccable-fixer**

Build prompt:

```markdown
Read $HOME/.claude/agents/gsd-impeccable-fixer.md for instructions.

<objective>
Apply auto-fixable UI design findings for Phase {phase_number}: {phase_name}
Fix each finding atomically — one commit per finding.
</objective>

<files_to_read>
- {ui_review_path} (UI-REVIEW.md — context only, do NOT re-parse findings from here)
{If .impeccable.md exists: "- .impeccable.md (Project design context — use for Impeccable-aware replacements)"}
- $HOME/.claude/skills/impeccable/SKILL.md (Impeccable command routing table)
</files_to_read>

<findings_to_fix>
{For each auto-fixable finding from Step F2, one entry per line:}
id="{id}" pillar="{pillar}" severity="{severity}" files="{files}" fix_hint="{fix_hint}"
</findings_to_fix>

<config>
phase_dir: {phase_dir}
padded_phase: {padded_phase}
output: {phase_dir}/{padded_phase}-UI-REVIEW-FIX.md
</config>
```

```
Agent(
  prompt=fix_prompt,
  subagent_type="gsd-impeccable-fixer",
  description="UI Fix Phase {N}"
)
```

**Step F5: Handle fixer return**

Display fix summary from `## UI FIX COMPLETE` return block.

**Step F6: Present manual-only findings**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ❌ Manual-Only Findings ({N})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

These require design judgment and cannot be auto-applied:

{For each manual finding:}
  [{ID}] {pillar name} — {severity}
  Issue: {finding description}
  Why manual: {reason auto-fix can't handle this}
  Guidance: {concrete suggestion for how to approach it}

To address these: run /gsd:execute-phase {N} with a targeted fix plan,
or edit manually and re-run /gsd:ui-review {N} to verify.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
</impeccable_integration>

<process>
## Pre-Flight: Flag Parsing and Route Decision

This runs BEFORE the standard workflow loads. Parse flags and decide the execution route:

```bash
FIX_MODE=false
DRY_RUN=false
FIX_ALL=false
# Use word-boundary match to avoid --fix-something false positives
[[ "$ARGUMENTS" =~ (^|[[:space:]])--fix([[:space:]]|$) ]] && FIX_MODE=true
[[ "$ARGUMENTS" =~ (^|[[:space:]])--dry-run([[:space:]]|$) ]] && DRY_RUN=true
[[ "$ARGUMENTS" =~ (^|[[:space:]])--all([[:space:]]|$) ]] && FIX_ALL=true
```

**If `FIX_MODE=true`:**

Check for existing UI-REVIEW.md:

```bash
UI_REVIEW_FILE=$(ls "${PHASE_DIR}"/*-UI-REVIEW.md 2>/dev/null | head -1)
```

**If UI-REVIEW.md exists:** Check for Impeccable finding metadata:

```bash
HAS_METADATA=$(grep -c '<!-- finding id=' "${UI_REVIEW_FILE}" 2>/dev/null || echo "0")
```

- **If `HAS_METADATA > 0`:** Skip the standard workflow entirely. Jump directly to Fix Flow Steps F1–F5. Do NOT run the standard ui-review.md workflow. Do NOT show AskUserQuestion about re-auditing.

- **If `HAS_METADATA == 0`:** UI-REVIEW.md is pre-Impeccable format (no finding metadata). Display warning and force re-audit:

  ```
  ⚠ UI-REVIEW.md exists but has no Impeccable finding metadata.
    This file was generated before Impeccable integration.
    Running fresh audit to generate machine-readable findings...
  ```

  Then run the full audit (standard workflow), followed automatically by Fix Flow.

**If `FIX_MODE=false`:** Execute the standard workflow normally (including its existing AskUserQuestion for existing UI-REVIEW.md).

---

**Standard audit path (no --fix, or --fix triggered re-audit above):**

Execute the standard GSD ui-review workflow end-to-end.

Apply Impeccable integration at these workflow steps:
1. **Before Step 3 (spawn auditor):** Run .impeccable.md detection, set IMPECCABLE_CTX
2. **At Step 3:** Inject impeccable file paths into auditor's `<files_to_read>` and append `<impeccable_audit_extension>` block to auditor prompt
3. Update score display to show "/28" overall

**After the auditor returns, replace the standard "▶ Next" block with:**

```
───────────────────────────────────────────────────────────────

## ▶ Next

{If any pillar scored < 4 (findings exist):}

`/clear` then:

  /gsd:ui-review {N} --fix        ← 自动应用可修复 findings（推荐）
  /gsd:ui-review {N} --fix --dry-run  ← 先看分类表，不改代码

  或手动修复后重新审计：
  /gsd:ui-review {N}

{If all pillars scored 4/4 (perfect score):}

`/clear` then one of:

  /gsd:verify-work {N}    — UAT 测试
  /gsd:plan-phase {N+1}   — 规划下一阶段

───────────────────────────────────────────────────────────────
```

After audit completes: if `--fix` was present in $ARGUMENTS, automatically continue into Fix Flow Steps F1–F6 without re-displaying next steps.

**Fix-only path (--fix + existing UI-REVIEW.md with metadata):**

Already handled in Pre-Flight: jump directly to Fix Flow Steps F1–F6.

Preserve all standard workflow gates: phase validation, SUMMARY.md existence check, existing UI-REVIEW.md handling via AskUserQuestion (only when --fix is NOT present), commit, state update.
</process>
