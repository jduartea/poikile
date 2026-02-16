# CLAUDE.md

## Project
This is a VS Code/Cursor color theme extension called "Poikile" with 4 variants:
- **Poikile - Ataraxia** — dark warm
- **Poikile - Apatheia** — dark vivid
- **Poikile - Euthymia** — light warm
- **Poikile - Katalepsis** — light vivid

## Spec
Read `SPEC.md` for the complete theme specification including palette design, 
all UI color keys, all TextMate scopes, semantic tokens, and test files.

## Workflow
- Work through the spec section by section
- Palette is defined in PALETTE.md with all 4 variants
- Theme JSONs are in themes/ — one per variant
- Verify WCAG AA contrast (4.5:1) for all text colors against their respective backgrounds
  - Dark variants: #1a1a1e (Ataraxia), #131316 (Apatheia)
  - Light variants: #f5f2ed (Euthymia), #f8f8f6 (Katalepsis)
- Test files in test/ cover 21 languages

## Constraints
- Use jsonc (JSON with comments) for theme files
- Every color choice must be intentional — no copy-paste from other themes
- Changes to font styles or scopes must be applied to all 4 theme files
- All text colors must pass WCAG AA (4.5:1) against their variant's background
