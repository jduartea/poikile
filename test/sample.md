---
title: "Poikile Theme — Markdown Test File"
description: "A comprehensive sample to verify all Markdown-specific theme scopes."
author: "jduartea"
date: 2026-02-15
tags:
  - theme
  - markdown
  - test
draft: false
layout: post
permalink: /test/sample-markdown/
meta:
  version: 0.1.0
  license: MIT
---

# Poikile Theme — Markdown Test File

<!--
Colors vary by variant — see PALETTE.md for hex values per theme.

Scopes to verify:
  meta.embedded.block.frontmatter   → YAML scopes apply inside frontmatter
  punctuation.definition.block.sequence.item → fg.subtle (list dash in YAML)
  heading.1 entity.name.section     → function  bold italic
  heading.2 entity.name.section     → keyword  bold
  heading.3 entity.name.section     → type  bold
  heading.4 entity.name.section     → link  bold
  heading.5 entity.name.section     → decorator  bold
  heading.6 entity.name.section     → fg.subtle  bold
  punctuation.definition.heading    → fg.muted
  markup.bold.markdown              → fg.bright  bold
  markup.italic.markdown            → fg.default  italic
  markup.strikethrough.markdown     → strikethrough
  markup.inline.raw.markdown        → regex  (inline code)
  markup.fenced_code.block.markdown → regex
  fenced_code.block.language        → regex  (language identifier)
  markup.quote.markdown             → fg.muted  italic
  markup.list.numbered.markdown     → fg.subtle
  markup.list.unnumbered.markdown   → fg.subtle
  markup.underline.link.markdown    → link  underline    (URL)
  string.other.link.title.markdown  → function               (link text)
  meta.link.inline.markdown         → fg.subtle               (brackets/parens)
  meta.image.inline.markdown        → fg.subtle               (brackets/parens)
  punctuation.definition.bold       → fg.muted
  punctuation.definition.italic     → fg.muted
  punctuation.definition.list.begin → fg.subtle
  meta.separator.markdown           → bg.selection  (horizontal rules)
  markup.deleted                    → deleted color
  markup.inserted                   → success color
  markup.changed                    → modified color
-->

A sample document to verify all Markdown-specific theme scopes render correctly.

---

## Architecture Overview

The system follows a **layered architecture** with clear separation of concerns. Each layer communicates through well-defined *interfaces*, ensuring loose coupling.

### Core Components

The core consists of three primary modules:

1. **Task Engine** — orchestrates job scheduling and execution
2. **Storage Layer** — handles persistence with pluggable backends
3. **Event Bus** — provides async communication between components

#### Design Principles

We adhere to these principles throughout the codebase:

- Single Responsibility: each module does one thing well
- Open/Closed: extend via *interfaces*, not modification
- Dependency Inversion: depend on abstractions, not concretions

##### Implementation Notes

Some additional details about the implementation approach.

###### Edge Cases

Rarely used heading level to test all six depths.

---

## Text Formatting

This paragraph contains **bold text**, *italic text*, and ***bold italic text*** together. You can also use ~~strikethrough~~ for deprecated information.

Here is `inline code` used within a sentence. The function `processTask()` accepts a `TaskConfig` parameter and returns a `Result<Task>`.

---

## Links and Images

- [Poikile GitHub Repository](https://github.com/jduartea/poikile-theme)
- [VS Code Theme Documentation](https://code.visualstudio.com/api/references/theme-color)
- [TextMate Scope Reference](https://macromates.com/manual/en/language_grammars)

An inline image: ![Theme Preview](./screenshots/preview.png "Poikile dark theme preview")

Reference-style links: [Stoic philosophy][stoicism] influenced the design of this [color theme][theme].

[stoicism]: https://en.wikipedia.org/wiki/Stoicism "Stoicism on Wikipedia"
[theme]: https://marketplace.visualstudio.com/items?itemName=jduartea.poikile-theme

---

## Code Blocks

Fenced code blocks with language identifiers:

```typescript
interface ThemeColor {
  readonly hex: string;
  readonly hsl: [number, number, number];
  contrast: number;
}

function validateContrast(color: ThemeColor, background: string): boolean {
  return color.contrast >= 4.5;
}
```

```python
@dataclass(frozen=True)
class Palette:
    name: str
    colors: dict[str, str]

    def get_color(self, token: str) -> str | None:
        return self.colors.get(token)
```

```bash
#!/bin/bash
# Build and package the theme
npm run build && vsce package --out dist/
echo "Package created: $(ls dist/*.vsix)"
```

Indented code block (4 spaces):

    const theme = loadTheme("poikile");
    applyTheme(editor, theme);

---

## Blockquotes

> "The happiness of your life depends upon the quality of your thoughts."
> — Marcus Aurelius, *Meditations*

> **Note:** Blockquotes can contain **formatted text**, `inline code`, and even
> nested elements:
>
> > This is a nested blockquote with *emphasis*.

---

## Lists

### Unordered

- Surface colors define spatial hierarchy
  - `bg.deep` — deepest background (activity bar)
  - `bg.editor` — main editing surface
  - `bg.overlay` — floating panels
- Syntax colors map to semantic roles
  - Keywords → dusty rose
  - Functions → warm gold
  - Types → sage teal

### Ordered

1. Define the color palette in `PALETTE.md`
2. Build UI colors in the theme JSON
3. Add TextMate token scopes
4. Configure semantic token colors
5. Create test files for each language
6. Verify WCAG AA contrast ratios

### Task Lists

- [x] Design color palette
- [x] Implement UI colors
- [x] Add tokenColors
- [x] Add semanticTokenColors
- [ ] Create all test files
- [ ] Package extension

---

## Tables

| Token | Hex | Role |
|---|---|---|
| `keyword` | `#c2788e` | Control flow, declarations |
| `function` | `#d4a55c` | Function/method names |
| `type` | `#7db89e` | Types, classes, interfaces |
| `string` | `#a3b87c` | String literals |
| `number` | `#c9905a` | Numeric literals, booleans |
| `comment` | `#8a8784` | Comments (italic) |
| `operator` | `#9b9baa` | Operators, punctuation |

---

## Horizontal Rules

The three styles of horizontal rules:

---

***

___

---

## HTML in Markdown

<details>
<summary>Click to expand advanced configuration</summary>

Configure the theme with these settings:

```json
{
  "editor.semanticHighlighting.enabled": true,
  "editor.bracketPairColorization.enabled": true
}
```

</details>

<div align="center">
  <strong>Poikile</strong> — A Stoic-inspired theme for focused work.
</div>

---

## Footnotes and References

The Stoa Poikile[^1] was a covered walkway in Athens where Zeno taught philosophy.

[^1]: The name means "Painted Porch" in Greek, referring to the murals that decorated the colonnade.

---

*End of Markdown test file.*
