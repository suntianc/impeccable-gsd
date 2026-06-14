---
name: gsd-discuss-phase
description: "Gather phase context through adaptive questioning — with Impeccable design aesthetic probes for UI phases"
argument-hint: "<phase-number> [--power] [--all] [--auto] [--text] [--batch] [--analyze] [--chain]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
  - AskUserQuestion
---

<objective>
Gather phase context through adaptive questioning, including Impeccable design aesthetic decisions for phases with UI components.

Extends the standard /gsd:discuss-phase workflow with design quality probes that capture visual direction before ui-phase begins. This ensures the UI-SPEC reflects a distinctive aesthetic, not generic defaults.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/discuss-phase.md
@$HOME/.claude/skills/impeccable/SKILL.md
</execution_context>

<impeccable_integration>
## Design Aesthetic Probes for UI Phases

After identifying standard implementation gray areas, detect whether the phase involves UI/frontend work:

```bash
# Extract phase number from $ARGUMENTS (first positional token)
PHASE_ARG=$(echo "$ARGUMENTS" | grep -oE '^[0-9]+' | head -1)
PHASE_DIR=$(gsd-sdk query roadmap.get-phase "${PHASE_ARG}" 2>/dev/null | grep -o '"phase_dir":"[^"]*"' | cut -d'"' -f4 || echo "")
HAS_UI_WORK=0
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  HAS_UI_WORK=$(find "$PHASE_DIR" -maxdepth 1 -name "*.md" -exec grep -liE "UI|UX|frontend|interface|screen|page|component|dashboard|form|modal|layout|design" {} \; 2>/dev/null | wc -l)
fi
```

**If `HAS_UI_WORK > 0`**, add **"Design Aesthetic Direction"** as a gray area option alongside the implementation decisions. Present it in the AskUserQuestion menu under a "Design" heading.

Ask all four design questions together in one interaction (not one-by-one):

---

**Design Aesthetic Direction**

> These choices guide the UI-SPEC and prevent generic SaaS aesthetics. Capturing them now means gsd-ui-researcher won't ask again.

**1. Visual Personality** — How should this UI feel?
- Functional / utilitarian — every element serves a purpose, minimal decoration
- Professional / refined — clean, composed, trustworthy
- Bold / expressive — strong personality, memorable, distinctive
- Playful / human — warm, approachable, energetic

**2. Color Philosophy** — What is the color mood?
- Monochromatic / neutral — one color family, subtle variation
- Restrained with one bold accent — mostly neutral + one pop of color
- Rich palette — multiple intentional colors, each with clear purpose
- Dark-first — dark background, light content as default

**3. Spatial Feel** — How dense should the layout be?
- Compact / efficient — maximize information density, tight spacing
- Balanced — standard spacing, neither dense nor airy
- Airy / generous — lots of whitespace, content breathes

**4. Typography Direction** — What is the typographic personality?
- System-native — use what the OS provides; fastest, most neutral
- Clean sans-serif — custom sans, utility-focused, not decorative
- Display contrast — a distinctive display font paired with a clean body font
- Editorial — strong typographic personality; serif or expressive display

---

Capture answers in CONTEXT.md under `## Decisions` as:

```yaml
design_aesthetic:
  visual_personality: "{answer}"
  color_philosophy: "{answer}"
  spatial_feel: "{answer}"
  typography_direction: "{answer}"
  notes: "{any specifics the user mentioned — references, inspirations, anti-examples}"
```

This design context is consumed by gsd-ui-researcher during ui-phase to pre-populate UI-SPEC.md with Impeccable-aligned decisions rather than generic defaults.

**If user skips design aesthetic probes:** note in CONTEXT.md:
```yaml
design_aesthetic:
  status: "deferred — no design direction captured; ui-phase researcher will ask"
```
</impeccable_integration>

<process>
Execute the standard GSD discuss-phase workflow end-to-end.

Apply Impeccable integration at this point in the flow:

**After gray area identification, before presenting the discussion menu:**
1. Run the UI work detection check
2. If UI work detected: add "Design Aesthetic Direction" as an optional gray area in the menu
3. If user selects it: present the 4 design questions as a group
4. Capture decisions in CONTEXT.md alongside implementation decisions

Preserve all standard workflow gates: phase validation, scope guardrails, all mode flags (--power, --all, --auto, --text, --batch, --analyze, --chain), state updates.
</process>
