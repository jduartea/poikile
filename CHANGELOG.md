# Changelog

All notable changes to the Poikile theme will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-02-15

### Added

- Two Stoic-inspired color theme variants (Tailwind CSS palette):
  - **Poikile - Apatheia** — dark (Tailwind 300 & 400)
  - **Poikile - Katalepsis** — light (Tailwind 500 & 600, slate surfaces)
- Full UI color coverage: editor, sidebar, activity bar, status bar, title bar, tabs, panels, terminal, minimap, diff editor, debug, breadcrumbs, notifications, inputs, buttons, badges, peek view, merge conflicts, settings editor, welcome page, inlay hints
- TextMate token scopes for 21 languages: Go, Dart, TypeScript, TSX, Python, Rust, Ruby, HTML, CSS, SCSS, Markdown, JSON, YAML, TOML, Shell/Bash, SQL, GraphQL, Protocol Buffers, Dockerfile, Vue, Svelte
- Semantic token colors for all VS Code semantic highlighting token types
- 6-color bracket pair colorization palette per variant
- 16-color terminal ANSI palette per variant
- WCAG AA contrast compliance (4.5:1 minimum) for all text colors in all variants
- Test files for every supported language in `test/`
- Recommended VS Code settings in `recommended-settings.json`
- Complete color palette reference in `PALETTE.md`

[0.1.0]: https://github.com/jduartea/poikile-theme/releases/tag/v0.1.0
