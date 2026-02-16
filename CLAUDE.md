# CLAUDE.md

## Project
VS Code/Cursor color theme extension **Poikile** with 2 variants:
- **Poikile - Apatheia** — dark (Tailwind 300/400)
- **Poikile - Katalepsis** — light (Tailwind 500/600 + slate surfaces)

## Spec
Read `SPEC.md` for the full theme specification (UI colors, TextMate scopes, semantic tokens, test files).

## Workflow
- Palette and Tailwind mapping are documented in `PALETTE.md`
- Theme JSONs: `themes/poikile-apatheia.json`, `themes/poikile-katalepsis.json`
- Verify WCAG AA (4.5:1) for all text colors:
  - Apatheia: background `#131316`
  - Katalepsis: background `#f8fafc` (slate-50)
- Test files in `test/` cover 21 languages

## Constraints
- Use jsonc for theme files
- Color changes must be applied to both theme files where the same token exists
- All text colors must pass WCAG AA against their variant background
