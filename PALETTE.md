# Poikile — Color Palette Reference

> Four variants, one philosophy: every color has a singular semantic purpose.
> All text colors pass WCAG AA (4.5:1) against their respective backgrounds.


| Variant        | Mode  | Style | Background |
| -------------- | ----- | ----- | ---------- |
| **Ataraxia**   | Dark  | Warm  | `#1a1a1e`  |
| **Apatheia**   | Dark  | Vivid | `#131316`  |
| **Euthymia**   | Light | Warm  | `#f5f2ed`  |
| **Katalepsis** | Light | Vivid | `#f8f8f6`  |


---

## 1. Surface Colors

### Dark Surfaces — Ataraxia (warm)

Hue 240° with very low saturation (5–8%), stepping in lightness from 8% to 25%.


| Token          | Hex       | Role                              |
| -------------- | --------- | --------------------------------- |
| `bg.deep`      | `#141416` | Activity bar, title bar           |
| `bg.editor`    | `#1a1a1e` | Editor background                 |
| `bg.surface`   | `#1e1e22` | Sidebar, panel backgrounds        |
| `bg.highlight` | `#24242a` | Current line, hover states        |
| `bg.overlay`   | `#28282e` | Autocomplete, command palette     |
| `bg.selection` | `#3a3a44` | Text selection, search highlights |


### Dark Surfaces — Apatheia (vivid)

Deeper blacks for more contrast with vivid syntax colors. Lightness steps from 6% to 22%.


| Token          | Hex       | Role                              |
| -------------- | --------- | --------------------------------- |
| `bg.deep`      | `#0f0f10` | Activity bar, title bar           |
| `bg.editor`    | `#131316` | Editor background                 |
| `bg.surface`   | `#18181b` | Sidebar, panel backgrounds        |
| `bg.highlight` | `#1c1c21` | Current line, hover states        |
| `bg.overlay`   | `#212126` | Autocomplete, command palette     |
| `bg.selection` | `#34343d` | Text selection, search highlights |


### Light Surfaces — Euthymia (warm)

Hue 35° with low saturation (10–14%), stepping in lightness from 82% to 100%.


| Token          | Hex       | Role                              |
| -------------- | --------- | --------------------------------- |
| `bg.deep`      | `#dddad4` | Activity bar, title bar           |
| `bg.editor`    | `#f5f2ed` | Editor background                 |
| `bg.surface`   | `#e9e6e2` | Sidebar, panel backgrounds        |
| `bg.highlight` | `#edebe8` | Current line, hover states        |
| `bg.overlay`   | `#ffffff` | Autocomplete, command palette     |
| `bg.selection` | `#d7d2cc` | Text selection, search highlights |


### Light Surfaces — Katalepsis (vivid)

Brighter whites for more contrast with vivid syntax colors. Lightness steps from 86% to 100%.


| Token          | Hex       | Role                              |
| -------------- | --------- | --------------------------------- |
| `bg.deep`      | `#e3e1dd` | Activity bar, title bar           |
| `bg.editor`    | `#f8f8f6` | Editor background                 |
| `bg.surface`   | `#efeeeb` | Sidebar, panel backgrounds        |
| `bg.highlight` | `#f4f2f1` | Current line, hover states        |
| `bg.overlay`   | `#ffffff` | Autocomplete, command palette     |
| `bg.selection` | `#dfdcd8` | Text selection, search highlights |


---

## 2. Foreground Colors

### Dark Foregrounds (Ataraxia & Apatheia)


| Token        | Ataraxia  | Apatheia  | Contrast | Role                    |
| ------------ | --------- | --------- | -------- | ----------------------- |
| `fg.muted`   | `#8a8784` | `#898784` | ~4.8:1   | Comments, line numbers  |
| `fg.subtle`  | `#9b9baa` | `#9b9baa` | 6.33:1   | Operators, punctuation  |
| `fg.default` | `#d4d0c8` | `#dad5cc` | ~11.5:1  | Variables, general text |
| `fg.bright`  | `#e8e4dc` | `#ede9e2` | ~14.0:1  | Emphasis, active tabs   |


### Light Foregrounds (Euthymia & Katalepsis)

Shared by both light variants.


| Token        | Hex       | Contrast | Role                    |
| ------------ | --------- | -------- | ----------------------- |
| `fg.muted`   | `#706b66` | 4.72:1   | Comments, line numbers  |
| `fg.subtle`  | `#6c6660` | 5.07:1   | Operators, punctuation  |
| `fg.default` | `#3e3832` | 10.35:1  | Variables, general text |
| `fg.bright`  | `#1c1a17` | 15.55:1  | Emphasis, active tabs   |


---

## 3. Syntax Colors

Each color maps to a semantic role, not a language. All four variants share the same hue families.


| Token       | Ataraxia  | Apatheia  | Euthymia  | Katalepsis | Role                                  |
| ----------- | --------- | --------- | --------- | ---------- | ------------------------------------- |
| `keyword`   | `#c2788e` | `#ef3966` | `#8d3f56` | `#9e1a41`  | `if`, `for`, `return`, `class`, `let` |
| `tag`       | `#cf7d6b` | `#ef5934` | `#974735` | `#a32e14`  | HTML/JSX tag names                    |
| `regex`     | `#d08a6e` | `#ec7c3c` | `#975135` | `#a13e17`  | Regex, escape sequences               |
| `number`    | `#c9905a` | `#f2952c` | `#8a5a2e` | `#934f10`  | Numbers, booleans, `null`             |
| `attribute` | `#b8a88e` | `#d7b375` | `#7c6746` | `#86642d`  | HTML attributes, CSS properties       |
| `function`  | `#d4a55c` | `#f4b434` | `#896224` | `#8e5c0b`  | Functions — most prominent token      |
| `constant`  | `#c8ba5e` | `#f1d627` | `#7a7029` | `#76680f`  | Constants, enum members               |
| `string`    | `#a3b87c` | `#94e147` | `#566b2e` | `#507114`  | String literals                       |
| `type`      | `#7db89e` | `#36e29b` | `#317256` | `#15754b`  | Types, classes, interfaces            |
| `link`      | `#8aadcf` | `#61a3e5` | `#3b6b9b` | `#1d61a5`  | Links, URLs                           |
| `namespace` | `#8a9db5` | `#5e8fd4` | `#4d6889` | `#2c5c96`  | Package/module names                  |
| `decorator` | `#b09cc5` | `#a66edd` | `#725095` | `#642e9e`  | Decorators, annotations               |


### Aliased tokens (not separate colors)


| Token      | Resolves To  | Role                               |
| ---------- | ------------ | ---------------------------------- |
| `variable` | `fg.default` | Variables — neutral baseline       |
| `comment`  | `fg.muted`   | Comments — de-emphasized, italic   |
| `operator` | `fg.subtle`  | Operators/punctuation — structural |


---

## 4. UI Semantic Colors


| Token      | Ataraxia  | Apatheia  | Euthymia  | Katalepsis | Role                    |
| ---------- | --------- | --------- | --------- | ---------- | ----------------------- |
| `error`    | `#d4626e` | `#ef3444` | `#ab2b38` | `#ae1323`  | Error squiggles, badges |
| `warning`  | `#d9b44c` | `#f1bf27` | `#816518` | `#7f600a`  | Warning squiggles       |
| `info`     | `#7a9ec2` | `#5099e2` | `#3b6b9b` | `#1f61a3`  | Info diagnostics        |
| `success`  | `#7db87a` | `#2fda2f` | `#3b7b37` | `#227c1d`  | Git added, success      |
| `modified` | `#c9a84c` | `#eeb32b` | `#856b23` | `#846510`  | Git modified            |
| `deleted`  | `#c27a7a` | `#e44444` | `#983e3e` | `#a02222`  | Git deleted             |
| `accent`   | `#b48ead` | `#c952e0` | `#86507c` | `#913080`  | Cursor, focus, buttons  |


---

## 5. Bracket Pair Colors

All bracket pairs use a single **warm yellow/amber** so brackets contrast clearly with greenish type colors and read as structure.

### Dark (Ataraxia / Apatheia)


| All pairs                                    | Ataraxia         | Apatheia               |
| -------------------------------------------- | ---------------- | ---------------------- |
| `editorBracketHighlight.foreground1–6`       | `#d4a55c` (gold) | `#f4b434` (vivid gold) |
| `editorBracketPairGuide.activeBackground1–6` | `#d4a55c40`      | `#f4b43440`            |


### Light (Euthymia / Katalepsis)


| All pairs                                    | Euthymia              | Katalepsis             |
| -------------------------------------------- | --------------------- | ---------------------- |
| `editorBracketHighlight.foreground1–6`       | `#896224` (dark gold) | `#8e5c0b` (dark amber) |
| `editorBracketPairGuide.activeBackground1–6` | `#89622440`           | `#8e5c0b40`            |


---

## 6. Terminal ANSI Colors

### Dark (Ataraxia)


| ANSI Name | Normal    | Bright    |
| --------- | --------- | --------- |
| Black     | `#1a1a1e` | `#3a3a44` |
| Red       | `#c27a7a` | `#d4626e` |
| Green     | `#7db87a` | `#a3b87c` |
| Yellow    | `#c9a84c` | `#d9b44c` |
| Blue      | `#7a9ec2` | `#8aadcf` |
| Magenta   | `#b48ead` | `#b09cc5` |
| Cyan      | `#7db89e` | `#8aadcf` |
| White     | `#d4d0c8` | `#e8e4dc` |


### Dark (Apatheia)


| ANSI Name | Normal    | Bright    |
| --------- | --------- | --------- |
| Black     | `#1a1a1e` | `#3a3a44` |
| Red       | `#e44444` | `#ef3444` |
| Green     | `#2fda2f` | `#94e147` |
| Yellow    | `#eeb32b` | `#f1bf27` |
| Blue      | `#5099e2` | `#61a3e5` |
| Magenta   | `#c952e0` | `#a66edd` |
| Cyan      | `#36e29b` | `#61a3e5` |
| White     | `#dad5cc` | `#ede9e2` |


### Light (Euthymia)


| ANSI Name | Normal    | Bright    |
| --------- | --------- | --------- |
| Black     | `#f5f2ed` | `#d7d2cc` |
| Red       | `#983e3e` | `#ab2b38` |
| Green     | `#3b7b37` | `#566b2e` |
| Yellow    | `#856b23` | `#816518` |
| Blue      | `#3b6b9b` | `#4d6889` |
| Magenta   | `#86507c` | `#725095` |
| Cyan      | `#317256` | `#3b6b9b` |
| White     | `#3e3832` | `#1c1a17` |


### Light (Katalepsis)


| ANSI Name | Normal    | Bright    |
| --------- | --------- | --------- |
| Black     | `#f5f2ed` | `#d7d2cc` |
| Red       | `#a02222` | `#ae1323` |
| Green     | `#227c1d` | `#507114` |
| Yellow    | `#846510` | `#7f600a` |
| Blue      | `#1f61a3` | `#2c5c96` |
| Magenta   | `#913080` | `#642e9e` |
| Cyan      | `#15754b` | `#1d61a5` |
| White     | `#3e3832` | `#1c1a17` |


---

## 7. Design Rationale

### Why these hue choices?

The palette draws from natural, warm-climate pigments — ochre, terracotta, sage, copper, olive, sand — evoking the painted walls of the Stoa Poikile. Cool hues (teal, blue-gray, lavender) are used sparingly as counterpoints, never as dominant tones.

### Warm vs Vivid strategy

- **Warm** (Ataraxia, Euthymia): Saturation 20–58%. Muted, natural-pigment aesthetic. Designed for long sessions.
- **Vivid** (Apatheia, Katalepsis): Saturation 55–90%. Highly saturated, punchy colors with strong hue identity. Reds are red, yellows are yellow, greens are green.

### Dark vs Light strategy

- **Ataraxia** (dark warm): Light text on `#1a1a1e`. Surfaces at hue 240° (cool neutral). Syntax at 55–70% lightness.
- **Apatheia** (dark vivid): Light text on deeper `#131316`. Extra contrast makes vivid colors pop more.
- **Euthymia** (light warm): Dark text on `#f5f2ed`. Surfaces at hue 35° (warm neutral). Syntax darkened to 30–45% lightness.
- **Katalepsis** (light vivid): Dark text on brighter `#f8f8f6`. Extra contrast makes vivid colors stand out sharply.

### Distinctness guarantees

- 12 unique syntax hues spanning 342° of the color wheel
- Closest hue pair with overlapping context: `function` (37°) vs `constant` (52°) — 15° separation plus different saturation
- Colors sharing similar hues (`tag` at 11° and `regex` at 17°) never appear in the same syntactic context
- `variable`/`comment`/`operator` are achromatic, avoiding hue conflicts

### Accessibility

Every foreground color used for text meets WCAG 2.1 AA (4.5:1 minimum) against its respective background:

- Ataraxia: all text ≥ 4.55:1 against `#1a1a1e`
- Apatheia: all text ≥ 4.60:1 against `#131316`
- Euthymia: all text ≥ 4.50:1 against `#f5f2ed`
- Katalepsis: all text ≥ 4.96:1 against `#f8f8f6`

