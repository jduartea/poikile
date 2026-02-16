# Poikile

**Two Stoic-inspired color themes for VS Code and Cursor — dark and light, both using Tailwind CSS colors.**

Named after the **Stoa Poikile** ("Painted Porch") in ancient Athens, where Zeno of Citium founded Stoicism around 300 BCE.

---

## Variants

| Variant | Mode | Palette | Meaning |
|---------|------|---------|---------|
| **Poikile - Apatheia** | Dark | Tailwind 300 & 400 | Freedom from destructive passions; disciplined contrast in darkness |
| **Poikile - Katalepsis** | Light | Tailwind 500 & 600 + slate surfaces | Clear apprehension and grasped truth; high clarity and precision |

---

## Preview

Open any file in `test/` to see the themes in action.

---

## Philosophy

- Every token has a single, unambiguous visual role.
- Functions, types, and errors draw the eye; noise recedes.
- All text colors pass **WCAG AA** (4.5:1) against their background.

See [`PALETTE.md`](./PALETTE.md) for the full palette reference.

---

## Install

### From the Marketplace

1. Open **Extensions** (`Ctrl+Shift+X` / `Cmd+Shift+X`)
2. Search for **Poikile**
3. Install, then **Preferences: Color Theme** → **Poikile - Apatheia** (dark) or **Poikile - Katalepsis** (light)

### From VSIX

```bash
npx @vscode/vsce package
code --install-extension poikile-theme-0.1.0.vsix
```

### Manual

Clone into your VS Code extensions folder:

```bash
git clone https://github.com/jduartea/poikile-theme.git ~/.vscode/extensions/poikile-theme
```

Restart VS Code and select a theme.

---

## Icon Theme

We recommend **[Catppuccin Icons](https://marketplace.visualstudio.com/items?itemName=Catppuccin.catppuccin-vsc-icons)**: use **Mocha** with Apatheia (dark) and **Latte** with Katalepsis (light).

---

## Recommended Settings

```jsonc
{
  "editor.semanticHighlighting.enabled": true,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active"
}
```

See [`recommended-settings.json`](./recommended-settings.json) for more.

---

## License

[MIT](./LICENSE)
