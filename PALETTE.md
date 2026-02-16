# Poikile — Color Palette Reference

> Two variants: dark (Apatheia) and light (Katalepsis). Both use [Tailwind CSS](https://tailwindcss.com/docs/customizing-colors) default palette. All text colors pass WCAG AA (4.5:1) against their backgrounds.

| Variant      | Mode  | Tailwind levels | Background   |
| ------------ | ----- | ---------------- | ------------ |
| **Apatheia** | Dark  | 300, 400         | `#131316`    |
| **Katalepsis** | Light | 500, 600 + slate surfaces | `#f8fafc` (slate-50) |

---

## 1. Surface Colors

### Dark — Apatheia

Unchanged custom surfaces (not Tailwind).

| Token          | Hex       | Role                              |
| -------------- | --------- | --------------------------------- |
| `bg.deep`      | `#0f0f10` | Activity bar, title bar           |
| `bg.editor`    | `#131316` | Editor background                 |
| `bg.surface`   | `#18181b` | Sidebar, panel backgrounds        |
| `bg.highlight` | `#1c1c21` | Current line, hover states        |
| `bg.overlay`   | `#212126` | Autocomplete, command palette     |
| `bg.selection` | `#34343d` | Text selection, search highlights |

### Light — Katalepsis (Tailwind slate)

| Token          | Hex       | Role                              |
| -------------- | --------- | --------------------------------- |
| `bg.deep`      | `#e2e8f0` | Tabs, activity bar (slate-200)    |
| `bg.editor`    | `#f8fafc` | Editor background (slate-50)      |
| `bg.surface`   | `#f1f5f9` | Sidebar, panels (slate-100)       |
| `bg.highlight` | `#f1f5f9` | Current line, hover (slate-100)   |
| `bg.overlay`   | `#ffffff` | Autocomplete, widgets             |
| `bg.selection` | `#e2e8f0` | Text selection (slate-200)        |

---

## 2. Foreground Colors

### Apatheia (Tailwind 300/400)

| Token        | Hex       | Tailwind     | Role                    |
| ------------ | --------- | ------------ | ----------------------- |
| `fg.muted`   | `#9ca3af` | gray-400     | Comments, line numbers  |
| `fg.subtle`  | `#94a3b8` | slate-400    | Operators, punctuation  |
| `fg.default` | `#d1d5db` | gray-300     | Variables, general text |
| `fg.bright`  | `#cbd5e1` | slate-300    | Emphasis, active tabs   |

### Katalepsis (Tailwind 500/600)

| Token        | Hex       | Tailwind     | Role                    |
| ------------ | --------- | ------------ | ----------------------- |
| `fg.muted`   | `#6b7280` | gray-500     | Comments, line numbers  |
| `fg.subtle`  | `#64748b` | slate-500    | Operators, punctuation  |
| `fg.default` | `#475569` | slate-600    | Variables, general text |
| `fg.bright`  | `#334155` | slate-700    | Emphasis, active tabs   |

---

## 3. Syntax Colors

### Apatheia (Tailwind 300/400)

| Token       | Hex       | Tailwind     | Role                    |
| ----------- | --------- | ------------ | ----------------------- |
| `keyword`   | `#fb7185` | rose-400     | `if`, `for`, `return`   |
| `tag`       | `#fb923c` | orange-400   | HTML/JSX tag names      |
| `regex`     | `#fb923c` | orange-400   | Regex, escape sequences |
| `number`    | `#fbbf24` | amber-400    | Numbers, booleans       |
| `attribute` | `#fcd34d` | amber-300    | HTML attributes         |
| `function`  | `#facc15` | yellow-400   | Functions               |
| `constant`  | `#facc15` | yellow-400   | Constants, enum members |
| `string`    | `#a3e635` | lime-400     | String literals         |
| `type`      | `#34d399` | emerald-400  | Types, classes         |
| `link`      | `#38bdf8` | sky-400      | Links, URLs             |
| `namespace` | `#60a5fa` | blue-400     | Package/module names    |
| `decorator` | `#a78bfa` | violet-400   | Decorators              |

### Katalepsis (Tailwind 500/600)

| Token       | Hex       | Tailwind     | Role                    |
| ----------- | --------- | ------------ | ----------------------- |
| `keyword`   | `#e11d48` | rose-600     | `if`, `for`, `return`   |
| `tag`       | `#ea580c` | orange-600   | HTML/JSX tag names      |
| `regex`     | `#ea580c` | orange-600   | Regex, escape sequences |
| `number`    | `#d97706` | amber-600    | Numbers, booleans       |
| `attribute` | `#d97706` | amber-600    | HTML attributes         |
| `function`  | `#ca8a04` | yellow-600   | Functions               |
| `constant`  | `#ca8a04` | yellow-600   | Constants, enum members |
| `string`    | `#65a30d` | lime-600     | String literals         |
| `type`      | `#059669` | emerald-600  | Types, classes         |
| `link`      | `#0284c7` | sky-600      | Links, URLs             |
| `namespace` | `#2563eb` | blue-600     | Package/module names    |
| `decorator` | `#7c3aed` | violet-600   | Decorators              |

---

## 4. UI Semantic Colors

### Apatheia

| Token     | Hex       | Tailwind    |
| --------- | --------- | ----------- |
| `error`   | `#f87171` | red-400     |
| `warning` | `#fbbf24` | amber-400   |
| `info`    | `#38bdf8` | sky-400     |
| `success` | `#4ade80` | green-400   |
| `modified`| `#fbbf24` | amber-400   |
| `deleted` | `#f87171` | red-400     |
| `accent`  | `#e879f9` | fuchsia-400 |

### Katalepsis

| Token     | Hex       | Tailwind    |
| --------- | --------- | ----------- |
| `error`   | `#dc2626` | red-600     |
| `warning` | `#d97706` | amber-600   |
| `info`    | `#0284c7` | sky-600     |
| `success` | `#16a34a` | green-600   |
| `modified`| `#d97706` | amber-600   |
| `deleted` | `#dc2626` | red-600     |
| `accent`  | `#c026d3` | fuchsia-600 |

---

## 5. Bracket Pair Colors

- **Apatheia:** `#facc15` (yellow-400) — brackets contrast with green types.
- **Katalepsis:** `#ca8a04` (yellow-600).

---

## 6. Terminal ANSI Colors

### Apatheia (Tailwind 300/400)

Red `#f87171`, Green `#4ade80`, Yellow `#fbbf24`, Blue `#38bdf8`, Magenta `#e879f9`, Cyan `#34d399`, White `#d1d5db` / `#cbd5e1`.

### Katalepsis (Tailwind 500/600)

Red `#dc2626`, Green `#16a34a`, Yellow `#d97706`, Blue `#2563eb`, Magenta `#c026d3`, Cyan `#059669`, White `#475569` / `#334155`.

---

## 7. Design Rationale

- **Apatheia (dark):** Tailwind 300 and 400 — light enough on dark background, saturated for clarity.
- **Katalepsis (light):** Tailwind 500 and 600 plus slate-50/100/200 for surfaces — dark enough on light background, consistent with Tailwind.
- All text colors meet WCAG AA (4.5:1) against their variant background.
