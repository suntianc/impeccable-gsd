---
name: gsd-ui-phase
description: "Generate UI design contract (UI-SPEC.md) with Impeccable design quality standards"
argument-hint: "<phase-number> [--text]"
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
Generate a UI design contract (UI-SPEC.md) that enforces Impeccable design quality.

Extends the standard /gsd:ui-phase workflow by:
1. Loading .impeccable.md project design context (if present) into the researcher prompt
2. Injecting Impeccable DO/DON'T rules into the researcher's contract generation
3. Adding an Impeccable anti-pattern dimension to the checker's validation pass
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/ui-phase.md
@$HOME/.claude/skills/impeccable/SKILL.md
@$HOME/.claude/skills/impeccable/references/typography.md
@$HOME/.claude/skills/impeccable/references/color-and-contrast.md
@$HOME/.claude/skills/impeccable/references/spatial-design.md
</execution_context>

<impeccable_integration>
## Impeccable Design Quality Gate

**Run before spawning gsd-ui-researcher (before Step 5):**

```bash
IMPECCABLE_CTX=""
if [ -f .impeccable.md ]; then
  IMPECCABLE_CTX=".impeccable.md"
  echo "✅ Found .impeccable.md — project design context will be loaded into researcher"
else
  echo "ℹ No .impeccable.md found — using Impeccable reference defaults"
fi
```

---

### Researcher Injection

**When building the gsd-ui-researcher prompt (Step 5), add these blocks after `<files_to_read>`:**

```markdown
<impeccable_files>
{If IMPECCABLE_CTX is set: "- .impeccable.md (Project design context — overrides generic defaults)"}
- $HOME/.claude/skills/impeccable/references/typography.md
- $HOME/.claude/skills/impeccable/references/color-and-contrast.md
- $HOME/.claude/skills/impeccable/references/spatial-design.md

Read all files above before writing any section of UI-SPEC.md.
</impeccable_files>

<impeccable_constraints>
Apply these Impeccable rules when specifying design tokens in UI-SPEC.md.

**Typography**
DO:
- Choose 1-2 fonts with clear personality (display + body, OR mono + humanist)
- Declare 3-4 sizes max, ideally using clamp() or a fluid type scale
- Pair contrasting weights (400 + 700, or 300 + 600) — not same-weight throughout
DON'T:
- ❌ Default to Inter, Roboto, Arial, or Open Sans as the primary display font
- ❌ Declare 5+ font sizes (creates visual chaos)
- ❌ Use weight 400 only (no typographic hierarchy)

**Color**
DO:
- Use oklch() for CSS custom property declarations where possible
- Declare a specific 60/30/10 split with explicit reserved-for rules for the 10% accent
- Give the palette a personality descriptor ("warm terracotta" not just "primary: #E35B30")
DON'T:
- ❌ Purple-blue gradients or neon glow accents
- ❌ Accent color reserved for "all interactive elements" (defeats hierarchy)
- ❌ Pure black #000000 or pure white #FFFFFF

**Spacing**
DO:
- Declare a rhythm descriptor (compact / balanced / generous) alongside numeric values
- Explain briefly why this rhythm fits the product's use case
DON'T:
- ❌ Just list "8pt scale: 4, 8, 16, 24…" with no design intent

**Copywriting**
DO:
- Every CTA: specific verb + noun ("Save Draft", "Delete Account", "Add Team Member")
- Empty states: what will appear here + one action to get started
- Error states: what happened + what to do next
DON'T:
- ❌ "Submit", "OK", "Cancel", "Save" as standalone CTA labels
- ❌ "No data found" / "Nothing here yet" as empty state copy
- ❌ "Something went wrong. Please try again." as error copy
</impeccable_constraints>
```

---

### Checker Injection

**When building the gsd-ui-checker prompt (Step 7), add this block after `<files_to_read>`:**

```markdown
<impeccable_dimension>
In addition to the 6 standard dimensions, validate Dimension 7: Impeccable Quality.

BLOCK if any of the following are true in UI-SPEC.md:
- Primary display font is Inter, Roboto, Arial, Open Sans, or "system-ui" ONLY (no personality font paired alongside)
- Accent color is reserved for "all interactive elements" — too broad, defeats visual hierarchy
- Spacing section contains only a list of values with no rhythm descriptor (compact/balanced/generous)

FLAG if:
- All color values are plain hex codes (no oklch() or color-mix() declarations)
- Only a single font weight is used across all text levels
- The design contract could describe any generic SaaS app — no distinctive visual identity
- Empty state copy not declared or uses placeholder text

A UI-SPEC that passes all 6 standard dimensions but fails Dimension 7 must return "## ISSUES FOUND" — not "## UI-SPEC VERIFIED".
</impeccable_dimension>
```
</impeccable_integration>

<process>
Execute the standard GSD ui-phase workflow end-to-end.

Apply Impeccable integration at these workflow steps:
1. **Before Step 5 (spawn researcher):** Run .impeccable.md detection, set IMPECCABLE_CTX
2. **At Step 5:** Inject `<impeccable_files>` and `<impeccable_constraints>` into researcher prompt, after `<files_to_read>`
3. **At Step 7:** Inject `<impeccable_dimension>` into checker prompt, after `<files_to_read>`
4. **At Step 9 (revision loop):** ALSO inject `<impeccable_files>` and `<impeccable_constraints>` into the revision researcher prompt, appended after the `<revision>` block. The revision spawn is treated identically to Step 5 for Impeccable injection — every researcher spawn, including revision, receives the full Impeccable context.

Also inject `<impeccable_context_mapping>` into EVERY researcher prompt (Step 5 and Step 9):

```markdown
<impeccable_context_mapping>
If CONTEXT.md contains a `design_aesthetic:` section under `## Decisions`, apply these mappings directly to the corresponding UI-SPEC sections — do NOT re-ask these questions:

| design_aesthetic key | → UI-SPEC section | How to apply |
|---|---|---|
| visual_personality: "Bold / expressive" | Typography + Color | Choose distinctive display font; use high-contrast, saturated palette |
| visual_personality: "Functional / utilitarian" | Spacing + Typography | Compact rhythm; neutral sans; no decorative elements |
| visual_personality: "Playful / human" | Color + Copywriting | Warm palette; round weights; conversational CTA copy |
| visual_personality: "Professional / refined" | All | Restrained palette; clean hierarchy; precise spacing |
| color_philosophy: "Dark-first" | Color | Dark surface as 60%, light content as 30%, accent as 10% |
| color_philosophy: "Monochromatic / neutral" | Color | Single hue family; desaturated variants; one accent pop |
| color_philosophy: "Rich palette" | Color | 3+ intentional colors; each with declared purpose |
| color_philosophy: "Restrained with one bold accent" | Color | Neutral 90% + one saturated accent reserved for primary CTA only |
| spatial_feel: "Compact / efficient" | Spacing | rhythm: compact; base unit 4px; tight gaps (8–16px) |
| spatial_feel: "Airy / generous" | Spacing | rhythm: generous; base unit 8px; wide gaps (24–48px) |
| spatial_feel: "Balanced" | Spacing | rhythm: balanced; base unit 8px; standard gaps (16–32px) |
| typography_direction: "Display contrast" | Typography | Pair distinctive display font (headings) + clean body font |
| typography_direction: "Editorial" | Typography | Serif or expressive display; strong size contrast |
| typography_direction: "Clean sans-serif" | Typography | Custom geometric or humanist sans; avoid Inter/Roboto |
| typography_direction: "System-native" | Typography | system-ui or OS default; acceptable only when explicitly chosen |

Pre-populate the relevant UI-SPEC sections with these values. Mark each pre-populated field with `(from discuss-phase)` so the checker can verify alignment.
</impeccable_context_mapping>
```

Preserve all standard workflow gates: UI_ENABLED config check, phase validation, prerequisite checks (CONTEXT.md / RESEARCH.md), existing UI-SPEC handling (update/view/skip), revision loop (max 2 iterations), commit, state update.
</process>
