# Poikile — VS Code / Cursor Theme

> Named after the **Stoa Poikile** ("Painted Porch") in ancient Athens, where Zeno of Citium founded Stoicism (~300 BCE). The theme embodies Stoic clarity, restraint, and enduring focus.

---

## 1. WHAT TO BUILD

Create a **complete, production-ready VS Code color theme** distributed as a standalone extension with the following file structure:

```
poikile-theme/
├── package.json                    # Extension manifest
├── README.md                       # Theme overview, palette preview, install instructions
├── CHANGELOG.md
├── LICENSE                         # MIT
├── icon.png                        # 256×256 theme icon (provide an SVG source too)
├── themes/
│   ├── poikile-ataraxia.json       # Dark warm variant
│   ├── poikile-apatheia.json       # Dark vivid variant
│   ├── poikile-euthymia.json       # Light warm variant
│   └── poikile-katalepsis.json     # Light vivid variant
└── test/
    ├── sample.go
    ├── sample.dart
    ├── sample.ts
    ├── sample.tsx
    ├── sample.py
    ├── sample.rs
    ├── sample.rb
    ├── sample.md
    ├── sample.json
    ├── sample.yaml
    ├── sample.toml
    ├── sample.html
    ├── sample.css
    ├── sample.scss
    ├── sample.sh
    ├── sample.sql
    ├── sample.graphql
    ├── sample.proto
    ├── sample.dockerfile
    ├── sample.vue
    └── sample.svelte
```

---

## 2. DESIGN PHILOSOPHY

### Stoic Principles → Design Decisions

| Principle | Design Translation |
|---|---|
| **Katalepsis** (clarity of thought) | Crystal-clear visual hierarchy — every token has exactly one unambiguous role |
| **Ataraxia** (tranquility) | Muted, desaturated palette that reduces cognitive noise |
| **Prosoche** (attention) | Important elements (functions, types, errors) draw the eye; noise recedes |
| **Sophrosyne** (temperance) | Restrained palette of ~14–16 semantic colors, no gratuitous decoration |
| **Endurance** | Timeless warm-neutral tones that won't feel dated in 5 years |

### Aesthetic Rules
- **Dark theme**, true dark background — NOT pure black `#000000`, use a very dark warm neutral (think `#1a1a1e` range)
- **Warm lean** — slight amber/ochre warmth in the palette, avoid cold sterile blues as primary tones
- **Muted & desaturated** — think 40-60% saturation, NOT neon. Colors should feel like natural pigments, not LEDs
- **No pure white** — foreground text should be warm off-white (e.g., `#d4d0c8` to `#e0ddd5` range)
- **Comfortable for 10+ hour sessions** — minimize glare, maximize readability
- **WCAG AA contrast minimum** (4.5:1 for normal text, 3:1 for large text) on ALL text tokens against the editor background

---

## 3. COLOR PALETTE SPECIFICATION

Design a cohesive palette of **14–16 named semantic colors** plus UI surface variants. Use the structure below. Every color must have a clear, singular purpose.

### 3.1 Base / Surface Colors (6-8 shades)
These define the spatial hierarchy of the UI:

| Role | Example Range | Usage |
|---|---|---|
| `bg.deep` | Darkest | Activity bar, title bar |
| `bg.surface` | Slightly lighter | Sidebar, panel backgrounds |
| `bg.editor` | Main editor | Editor background |
| `bg.highlight` | Subtle lift | Current line, hover states |
| `bg.selection` | Noticeable | Text selection, search highlights |
| `bg.overlay` | Popover | Autocomplete, hover panels, command palette |
| `fg.muted` | Low contrast | Comments, line numbers, inactive tabs, breadcrumbs |
| `fg.subtle` | Medium contrast | Punctuation, operators, secondary text |
| `fg.default` | Primary text | Variables, general code, editor foreground |
| `fg.bright` | High contrast | Emphasized text, active tab titles |

### 3.2 Syntax Colors (10–14 hues)
Each color maps to a **semantic role**, not a language:

| Semantic Role | Suggested Hue Family | Targets |
|---|---|---|
| **Keyword** | Warm rose / dusty mauve | Control flow (`if`, `else`, `for`, `return`, `go`, `async`, `await`), declaration keywords (`func`, `class`, `let`, `const`, `var`, `import`) |
| **Function / Method** | Warm gold / ochre | Function declarations, function calls, method names — **the most-read tokens, make them prominent** |
| **Type / Class** | Teal / sage green | Type names, class names, interfaces, structs, enums, type annotations |
| **String** | Olive / warm green | All string literals, template strings, f-strings, interpolation delimiters |
| **Number / Boolean / Nil** | Copper / burnt orange | Numeric literals, `true`/`false`/`nil`/`null`/`None`, `iota` |
| **Variable / Parameter** | Off-white / warm cream | Local variables, parameters, properties, fields — should be clear but NOT compete with functions |
| **Constant / Enum Member** | Amber / soft gold | Constants, enum values, `const` declarations with ALL_CAPS convention |
| **Comment** | Muted warm gray | All comments — **italic style**, clearly de-emphasized but still legible |
| **Operator / Punctuation** | Dim warm gray | `=`, `+`, `<-`, `=>`, `.`, `,`, `:`, brackets, braces — **subtle but visible** |
| **Decorator / Annotation** | Dusty purple / lavender | `@override`, `@required`, Python decorators, Go struct tags |
| **Namespace / Module** | Muted blue-gray | Package names, module names, imports |
| **Regex / Escape** | Distinct accent | Regex patterns, escape sequences (`\n`, `\t`, `${...}`) |
| **Tag (HTML/JSX)** | Warm coral / terracotta | HTML/JSX tag names |
| **Attribute** | Soft peach / sand | HTML attributes, JSX props, CSS properties |
| **Link / URL** | Underlined accent | Markdown links, URLs in comments |

### 3.3 UI Semantic Colors (diagnostics, git, etc.)

| Role | Hue | Usage |
|---|---|---|
| **Error** | Warm red (not harsh) | Error squiggles, error text, error badges, error gutter icons |
| **Warning** | Amber | Warning squiggles, warning text |
| **Info** | Muted blue | Info diagnostics, hints |
| **Success / Added** | Soft green | Git added lines, success badges |
| **Modified** | Warm yellow | Git modified indicators |
| **Deleted** | Muted red | Git deleted lines, removed markers |
| **Accent** | Your signature accent | Focused borders, active selections, buttons, links, cursor, progress bars |

### 3.4 Bracket Pair Colorization
Provide a harmonious set of **6 bracket pair colors** that are distinguishable but don't clash with syntax highlighting. These should be slightly more saturated than the base syntax colors to stand out against code.

---

## 4. COMPLETE UI ELEMENT COVERAGE

Style **every** major VS Code UI surface. Reference: https://code.visualstudio.com/api/references/theme-color

### Must cover ALL of the following categories:

#### Editor Core
- `editor.background`, `editor.foreground`
- `editor.lineHighlightBackground`, `editor.lineHighlightBorder`
- `editor.selectionBackground`, `editor.selectionHighlightBackground`
- `editor.inactiveSelectionBackground`
- `editor.wordHighlightBackground`, `editor.wordHighlightStrongBackground`
- `editor.findMatchBackground`, `editor.findMatchHighlightBackground`
- `editor.findMatchBorder`, `editor.findMatchHighlightBorder`
- `editor.rangeHighlightBackground`
- `editor.hoverHighlightBackground`
- `editorCursor.foreground`
- `editor.linkedEditingBackground`
- `editorWhitespace.foreground`
- `editorIndentGuide.background`, `editorIndentGuide.activeBackground`
- `editorRuler.foreground`
- `editorCodeLens.foreground`
- `editorBracketMatch.background`, `editorBracketMatch.border`
- `editorBracketHighlight.foreground1` through `foreground6`
- `editorBracketPairGuide.activeBackground1` through `6`
- `editorGhostText.foreground`
- `editorStickyScroll.background`, `editorStickyScrollHover.background`

#### Editor Gutter
- `editorGutter.background`
- `editorGutter.modifiedBackground`
- `editorGutter.addedBackground`
- `editorGutter.deletedBackground`
- `editorGutter.commentRangeForeground`
- `editorGutter.foldingControlForeground`
- `editorLineNumber.foreground`, `editorLineNumber.activeForeground`

#### Editor Groups & Tabs
- `editorGroup.border`, `editorGroup.dropBackground`
- `editorGroupHeader.tabsBackground`, `editorGroupHeader.tabsBorder`
- `tab.activeBackground`, `tab.activeForeground`, `tab.activeBorderTop`
- `tab.inactiveBackground`, `tab.inactiveForeground`
- `tab.hoverBackground`, `tab.hoverForeground`
- `tab.unfocusedActiveBackground`, `tab.unfocusedActiveForeground`
- `tab.border`, `tab.lastPinnedBorder`

#### Editor Widgets
- `editorWidget.background`, `editorWidget.foreground`, `editorWidget.border`
- `editorSuggestWidget.background`, `editorSuggestWidget.border`, `editorSuggestWidget.foreground`
- `editorSuggestWidget.highlightForeground`, `editorSuggestWidget.selectedBackground`
- `editorHoverWidget.background`, `editorHoverWidget.border`, `editorHoverWidget.foreground`
- `editorMarkerNavigation.background`
- `editorMarkerNavigationError.background`, `editorMarkerNavigationWarning.background`, `editorMarkerNavigationInfo.background`
- `peekView.border`
- `peekViewEditor.background`, `peekViewEditor.matchHighlightBackground`
- `peekViewResult.background`, `peekViewResult.fileForeground`
- `peekViewResult.lineForeground`, `peekViewResult.matchHighlightBackground`
- `peekViewResult.selectionBackground`, `peekViewResult.selectionForeground`
- `peekViewTitle.background`
- `peekViewTitleLabel.foreground`, `peekViewTitleDescription.foreground`

#### Diff Editor
- `diffEditor.insertedTextBackground`, `diffEditor.insertedLineBackground`
- `diffEditor.removedTextBackground`, `diffEditor.removedLineBackground`
- `diffEditor.border`, `diffEditor.diagonalFill`
- `diffEditorGutter.insertedLineBackground`, `diffEditorGutter.removedLineBackground`

#### Minimap
- `minimap.findMatchHighlight`
- `minimap.selectionHighlight`
- `minimap.errorHighlight`, `minimap.warningHighlight`
- `minimap.background`
- `minimapSlider.background`, `minimapSlider.hoverBackground`, `minimapSlider.activeBackground`
- `minimapGutter.addedBackground`, `minimapGutter.modifiedBackground`, `minimapGutter.deletedBackground`

#### Side Bar & Explorer
- `sideBar.background`, `sideBar.foreground`, `sideBar.border`
- `sideBarTitle.foreground`
- `sideBarSectionHeader.background`, `sideBarSectionHeader.foreground`, `sideBarSectionHeader.border`
- `list.activeSelectionBackground`, `list.activeSelectionForeground`
- `list.inactiveSelectionBackground`, `list.inactiveSelectionForeground`
- `list.hoverBackground`, `list.hoverForeground`
- `list.focusBackground`, `list.focusForeground`
- `list.highlightForeground`
- `list.dropBackground`
- `list.errorForeground`, `list.warningForeground`
- `tree.indentGuidesStroke`, `tree.tableColumnsBorder`

#### Activity Bar
- `activityBar.background`, `activityBar.foreground`, `activityBar.inactiveForeground`
- `activityBar.border`, `activityBar.activeBorder`
- `activityBarBadge.background`, `activityBarBadge.foreground`

#### Status Bar
- `statusBar.background`, `statusBar.foreground`, `statusBar.border`
- `statusBar.debuggingBackground`, `statusBar.debuggingForeground`
- `statusBar.noFolderBackground`, `statusBar.noFolderForeground`
- `statusBarItem.hoverBackground`
- `statusBarItem.activeBackground`
- `statusBarItem.remoteBackground`, `statusBarItem.remoteForeground`
- `statusBarItem.prominentBackground`, `statusBarItem.prominentForeground`
- `statusBarItem.errorBackground`, `statusBarItem.errorForeground`
- `statusBarItem.warningBackground`, `statusBarItem.warningForeground`

#### Title Bar
- `titleBar.activeBackground`, `titleBar.activeForeground`
- `titleBar.inactiveBackground`, `titleBar.inactiveForeground`
- `titleBar.border`

#### Panels (Terminal, Output, Problems, Debug Console)
- `panel.background`, `panel.border`, `panel.dropBorder`
- `panelTitle.activeBorder`, `panelTitle.activeForeground`, `panelTitle.inactiveForeground`
- `panelSection.border`, `panelSectionHeader.background`
- `terminal.background`, `terminal.foreground`
- `terminal.ansiBlack`, `terminal.ansiRed`, `terminal.ansiGreen`, `terminal.ansiYellow`
- `terminal.ansiBlue`, `terminal.ansiMagenta`, `terminal.ansiCyan`, `terminal.ansiWhite`
- `terminal.ansiBrightBlack`, `terminal.ansiBrightRed`, `terminal.ansiBrightGreen`, `terminal.ansiBrightYellow`
- `terminal.ansiBrightBlue`, `terminal.ansiBrightMagenta`, `terminal.ansiBrightCyan`, `terminal.ansiBrightWhite`
- `terminal.selectionBackground`, `terminal.selectionForeground`
- `terminalCursor.background`, `terminalCursor.foreground`
- `terminal.findMatchBackground`, `terminal.findMatchHighlightBackground`

#### Command Palette & Quick Input
- `quickInput.background`, `quickInput.foreground`
- `quickInputList.focusBackground`, `quickInputList.focusForeground`
- `quickInputTitle.background`
- `commandCenter.foreground`, `commandCenter.background`, `commandCenter.border`
- `commandCenter.activeForeground`, `commandCenter.activeBackground`, `commandCenter.activeBorder`

#### Notifications
- `notifications.background`, `notifications.foreground`, `notifications.border`
- `notificationCenterHeader.background`, `notificationCenterHeader.foreground`
- `notificationLink.foreground`
- `notificationsErrorIcon.foreground`, `notificationsWarningIcon.foreground`, `notificationsInfoIcon.foreground`

#### Scrollbar
- `scrollbar.shadow`
- `scrollbarSlider.background`, `scrollbarSlider.hoverBackground`, `scrollbarSlider.activeBackground`

#### Input Controls
- `input.background`, `input.foreground`, `input.border`
- `input.placeholderForeground`
- `inputOption.activeBackground`, `inputOption.activeBorder`, `inputOption.activeForeground`
- `inputValidation.errorBackground`, `inputValidation.errorBorder`, `inputValidation.errorForeground`
- `inputValidation.infoBackground`, `inputValidation.infoBorder`, `inputValidation.infoForeground`
- `inputValidation.warningBackground`, `inputValidation.warningBorder`, `inputValidation.warningForeground`

#### Buttons
- `button.background`, `button.foreground`, `button.hoverBackground`
- `button.secondaryBackground`, `button.secondaryForeground`, `button.secondaryHoverBackground`

#### Dropdowns
- `dropdown.background`, `dropdown.foreground`, `dropdown.border`
- `dropdown.listBackground`

#### Badges
- `badge.background`, `badge.foreground`

#### Progress Bar
- `progressBar.background`

#### Breadcrumbs
- `breadcrumb.foreground`, `breadcrumb.focusForeground`, `breadcrumb.activeSelectionForeground`
- `breadcrumbPicker.background`

#### Git Decorations
- `gitDecoration.addedResourceForeground`
- `gitDecoration.modifiedResourceForeground`
- `gitDecoration.deletedResourceForeground`
- `gitDecoration.renamedResourceForeground`
- `gitDecoration.untrackedResourceForeground`
- `gitDecoration.ignoredResourceForeground`
- `gitDecoration.conflictingResourceForeground`
- `gitDecoration.stageModifiedResourceForeground`
- `gitDecoration.stageDeletedResourceForeground`

#### Merge Conflicts
- `merge.currentHeaderBackground`, `merge.currentContentBackground`
- `merge.incomingHeaderBackground`, `merge.incomingContentBackground`
- `merge.commonHeaderBackground`, `merge.commonContentBackground`
- `merge.border`

#### Debug
- `debugToolBar.background`, `debugToolBar.border`
- `debugIcon.breakpointForeground`, `debugIcon.breakpointDisabledForeground`
- `debugIcon.startForeground`, `debugIcon.pauseForeground`, `debugIcon.stopForeground`
- `debugIcon.stepOverForeground`, `debugIcon.stepIntoForeground`, `debugIcon.stepOutForeground`
- `debugIcon.restartForeground`, `debugIcon.disconnectForeground`
- `debugConsole.infoForeground`, `debugConsole.warningForeground`, `debugConsole.errorForeground`
- `debugConsole.sourceForeground`
- `debugConsoleInputIcon.foreground`
- `debugTokenExpression.name`, `debugTokenExpression.value`, `debugTokenExpression.string`
- `debugTokenExpression.boolean`, `debugTokenExpression.number`, `debugTokenExpression.error`

#### Settings Editor
- `settings.headerForeground`
- `settings.modifiedItemIndicator`
- `settings.dropdownBackground`, `settings.dropdownForeground`, `settings.dropdownBorder`
- `settings.checkboxBackground`, `settings.checkboxForeground`, `settings.checkboxBorder`
- `settings.textInputBackground`, `settings.textInputForeground`, `settings.textInputBorder`
- `settings.numberInputBackground`, `settings.numberInputForeground`, `settings.numberInputBorder`
- `settings.focusedRowBackground`

#### Welcome Page
- `welcomePage.background`
- `welcomePage.tileBackground`, `welcomePage.tileHoverBackground`
- `walkThrough.embeddedEditorBackground`

#### Source Control
- `scm.providerBorder`

#### Keybinding
- `keybindingLabel.background`, `keybindingLabel.foreground`, `keybindingLabel.border`
- `keybindingLabel.bottomBorder`

#### Focused / Selections / Highlights
- `focusBorder`
- `foreground`
- `selection.background`
- `descriptionForeground`
- `errorForeground`
- `icon.foreground`
- `textLink.foreground`, `textLink.activeForeground`
- `textBlockQuote.background`, `textBlockQuote.border`
- `textCodeBlock.background`
- `textPreformat.foreground`
- `textSeparator.foreground`
- `widget.shadow`

#### Inlay Hints
- `editorInlayHint.background`, `editorInlayHint.foreground`
- `editorInlayHint.typeBackground`, `editorInlayHint.typeForeground`
- `editorInlayHint.parameterBackground`, `editorInlayHint.parameterForeground`

---

## 5. TOKEN / SYNTAX SCOPE COVERAGE

Use the `tokenColors` array with **TextMate scopes**. Organize sections with clear comments. Target both **broad scopes** (fallback) and **language-specific scopes** (precision).

### 5.1 Universal Scopes (apply to all languages)

```
comment, comment.line, comment.block, comment.block.documentation
string, string.quoted.single, string.quoted.double, string.quoted.triple
string.template, string.interpolated
string.regexp
constant.numeric, constant.numeric.integer, constant.numeric.float, constant.numeric.hex, constant.numeric.octal, constant.numeric.binary
constant.language (true, false, nil, null, None, undefined, iota)
constant.character, constant.character.escape
constant.other
variable, variable.other, variable.parameter, variable.other.readwrite
variable.other.constant, variable.other.enummember
variable.language (this, self, super)
entity.name.function, entity.name.method
entity.name.type, entity.name.class, entity.name.struct, entity.name.interface, entity.name.enum
entity.name.namespace, entity.name.module
entity.name.tag
entity.other.attribute-name
entity.other.inherited-class
keyword, keyword.control (if, else, for, while, return, switch, case, break, continue)
keyword.control.flow
keyword.control.import
keyword.operator, keyword.operator.assignment, keyword.operator.comparison, keyword.operator.arithmetic, keyword.operator.logical
keyword.operator.new
keyword.other
storage.type (func, class, struct, interface, enum, type, var, let, const, def, fn)
storage.modifier (public, private, protected, static, abstract, final, async, override, readonly)
support.function, support.function.builtin
support.type, support.type.builtin
support.class
support.constant
support.variable
punctuation.definition, punctuation.separator, punctuation.terminator
punctuation.definition.string, punctuation.definition.comment
punctuation.section.block, punctuation.section.parens, punctuation.section.brackets
meta.function-call
meta.definition.function
meta.definition.variable
meta.object-literal.key
meta.brace.round, meta.brace.square, meta.brace.curly
meta.return.type
meta.type.annotation
invalid, invalid.illegal, invalid.deprecated
markup.heading (h1-h6 with increasing visual weight)
markup.bold
markup.italic
markup.underline
markup.deleted
markup.inserted
markup.changed
markup.inline.raw, markup.fenced_code
markup.quote
markup.list
markup.link
```

### 5.2 Language-Specific Scopes

#### Go / Golang
```
source.go
keyword.go (func, type, struct, interface, map, chan, go, select, defer, range, package, import, return, var, const)
keyword.channel.go
keyword.function.go
entity.name.function.go
entity.name.type.go
storage.type.go (int, string, bool, byte, error, float64, etc.)
variable.other.go
support.function.builtin.go (make, len, cap, append, copy, delete, close, panic, recover, new, print, println)
string.quoted.double.go, string.quoted.raw.go (backtick strings)
constant.other.placeholder.go (fmt verbs: %s, %d, %v, etc.)
entity.name.package.go
keyword.import.go
entity.alias.import.go
comment.line.double-slash.go
entity.name.type.go (custom types)
keyword.struct.go, keyword.interface.go
meta.definition.method.go (receiver types)
```

#### Dart / Flutter
```
source.dart
keyword.control.dart (if, else, for, while, switch, case, break, continue, return, yield)
keyword.declaration.dart (class, enum, extension, mixin, typedef, abstract, implements, extends, with)
keyword.control.dart (async, await, sync, yield)
storage.type.dart (var, final, const, late, dynamic, void)
support.class.dart (Widget, State, BuildContext, StatefulWidget, StatelessWidget, Future, Stream)
entity.name.function.dart
entity.name.type.class.dart
variable.language.dart (this, super)
string.interpolated.dart (string interpolation $variable, ${expression})
constant.language.dart (true, false, null)
punctuation.definition.annotation.dart (@override, @required, @protected, @immutable, @visibleForTesting)
meta.declaration.dart
keyword.operator.dart
keyword.operator.cascade.dart (..)
keyword.control.new.dart
keyword.control.as.dart, keyword.control.is.dart
support.type.dart (int, double, String, bool, List, Map, Set, Future, Stream, Iterable)
```

#### TypeScript / JavaScript / TSX / JSX
```
source.ts, source.tsx, source.js, source.jsx
keyword.control.ts (if, else, for, while, return, switch, case, break, continue, throw, try, catch, finally)
keyword.control.import.ts, keyword.control.export.ts
keyword.control.flow.ts
storage.type.ts (let, const, var, function, class, interface, type, enum, namespace, module, declare)
storage.modifier.ts (async, await, readonly, public, private, protected, static, abstract, override)
entity.name.function.ts
entity.name.type.ts, entity.name.type.class.ts, entity.name.type.interface.ts, entity.name.type.enum.ts
entity.name.type.alias.ts
variable.other.readwrite.ts
variable.other.constant.ts
variable.language.ts (this, super, arguments)
support.type.primitive.ts (string, number, boolean, void, never, unknown, any, null, undefined, bigint, symbol)
meta.arrow.ts (arrow function =>)
meta.type.annotation.ts
string.template.ts, punctuation.definition.template-expression.begin.ts, punctuation.definition.template-expression.end.ts
keyword.operator.type.ts (as, is, keyof, typeof, infer, extends, readonly)
keyword.operator.ternary.ts
keyword.operator.spread.ts, keyword.operator.rest.ts
entity.name.tag.tsx (JSX tags)
entity.other.attribute-name.tsx (JSX attributes)
support.class.component.tsx (capitalized JSX components)
meta.jsx.children.tsx
punctuation.definition.tag.begin.tsx, punctuation.definition.tag.end.tsx
constant.language.ts (true, false, null, undefined, NaN, Infinity)
meta.object-literal.key.ts
meta.interface.ts
meta.type.parameters.ts (generics < >)
meta.decorator.ts (@decorators)
```

#### Python
```
source.python
keyword.control.python (if, elif, else, for, while, try, except, finally, with, as, return, yield, raise, pass, break, continue, assert, del)
keyword.control.import.python (import, from)
keyword.operator.logical.python (and, or, not, in, is)
storage.type.function.python (def, lambda)
storage.type.class.python (class)
storage.modifier.python (async, await)
entity.name.function.python
entity.name.function.decorator.python (@decorator)
entity.name.type.class.python
variable.parameter.python
variable.language.python (self, cls)
support.function.builtin.python (print, len, range, type, isinstance, enumerate, zip, map, filter, sorted, reversed, open, etc.)
support.type.python (int, str, float, bool, list, dict, tuple, set, bytes, None, type)
constant.language.python (True, False, None)
string.quoted.single.python, string.quoted.double.python, string.quoted.triple.python
storage.type.string.python (f-string prefix f, r, b, u)
meta.fstring.python
string.interpolated.python
meta.function.parameters.python
support.variable.magic.python (__init__, __str__, __repr__, __enter__, __exit__, __name__)
punctuation.definition.decorator.python
meta.function.decorator.python
variable.other.readwrite.python
keyword.operator.unpacking.python (*, **)
meta.type.annotation.python (type hints: -> return type, : param type)
```

#### Rust
```
source.rust
keyword.control.rust (if, else, for, while, loop, match, return, break, continue, fn, let, mut, const, static, type, struct, enum, impl, trait, pub, use, mod, crate, self, super, as, where, unsafe, async, await, move, ref, dyn)
entity.name.function.rust
entity.name.type.rust
entity.name.type.struct.rust, entity.name.type.enum.rust, entity.name.type.trait.rust
entity.name.lifetime.rust ('a, 'static)
storage.type.rust (i32, u64, f64, bool, str, String, Vec, Option, Result, Box, Rc, Arc, etc.)
storage.modifier.rust (mut, pub, unsafe, async, const, static)
keyword.operator.rust
variable.other.rust
entity.name.namespace.rust
support.function.rust, support.macro.rust
meta.macro.rust (macro_rules!, println!, vec!, format!, etc.)
meta.attribute.rust (#[derive], #[cfg], #[test])
constant.language.rust (true, false)
meta.generic.rust (generics < >)
keyword.operator.borrow.rust (&, &mut)
punctuation.definition.lifetime.rust
meta.impl.rust
```

#### Ruby
```
source.ruby
keyword.control.ruby (if, elsif, else, unless, while, until, for, do, end, begin, rescue, ensure, raise, return, yield, case, when, then, class, module, def)
entity.name.function.ruby, entity.name.type.class.ruby, entity.name.type.module.ruby
variable.other.ruby
variable.other.readwrite.instance.ruby (@instance)
variable.other.readwrite.class.ruby (@@class)
variable.other.readwrite.global.ruby ($global)
constant.other.symbol.ruby (:symbol)
string.interpolated.ruby (#{interpolation})
keyword.control.ruby (do, end, begin, rescue, ensure)
support.function.kernel.ruby (puts, gets, require, raise, attr_accessor, attr_reader, attr_writer)
punctuation.definition.variable.ruby
constant.language.ruby (true, false, nil)
entity.name.function.ruby
meta.function.method.with-arguments.ruby
variable.language.ruby (self)
storage.type.ruby (def, class, module)
keyword.operator.ruby
```

#### HTML
```
text.html
entity.name.tag.html
entity.other.attribute-name.html
string.quoted.double.html (attribute values)
punctuation.definition.tag.begin.html, punctuation.definition.tag.end.html
comment.block.html
entity.name.tag.structure.html (html, head, body, main, section, article, nav, header, footer, aside, div, span)
entity.name.tag.inline.html (a, strong, em, code, br, img, input)
entity.name.tag.block.html (p, h1-h6, ul, ol, li, table, tr, td, th, form)
entity.name.tag.metadata.html (meta, link, title, script, style)
support.class.html (id, class attributes)
invalid.illegal.bad-attribute-name.html
meta.tag.html
entity.name.tag.custom.html (web components)
```

#### CSS / SCSS
```
source.css, source.scss
entity.name.tag.css (element selectors)
entity.other.attribute-name.class.css (.class)
entity.other.attribute-name.id.css (#id)
entity.other.attribute-name.pseudo-class.css (:hover, :focus, :first-child)
entity.other.attribute-name.pseudo-element.css (::before, ::after)
support.type.property-name.css (property names)
support.constant.property-value.css (property values)
constant.numeric.css (numbers with units)
keyword.other.unit.css (px, em, rem, %, vh, vw)
support.function.css (calc, var, rgb, rgba, hsl, url)
variable.css (CSS custom properties --variable)
keyword.control.at-rule.css (@media, @import, @keyframes, @font-face)
punctuation.section.property-list.css ({ })
meta.property-value.css
meta.selector.css
constant.other.color.rgb-value.css (#hex colors)
support.constant.color.css (named colors)
string.quoted.single.css, string.quoted.double.css
keyword.operator.css (>, ~, +, *)
entity.name.function.scss (mixins)
variable.scss ($variable)
keyword.control.scss (@include, @extend, @mixin, @if, @else, @for, @each)
meta.at-rule.media.css
```

#### Markdown
```
text.html.markdown
markup.heading.1.markdown (style: bold, largest size, distinct color)
markup.heading.2.markdown (style: bold, slightly smaller)
markup.heading.3.markdown through markup.heading.6.markdown (progressively less prominent)
markup.bold.markdown (fontStyle: bold)
markup.italic.markdown (fontStyle: italic)
markup.strikethrough.markdown (fontStyle: strikethrough)
markup.inline.raw.markdown (inline code - distinct background hint)
markup.fenced_code.block.markdown (code block)
fenced_code.block.language (language identifier after ```)
markup.quote.markdown (blockquotes - italic, muted)
markup.list.numbered.markdown, markup.list.unnumbered.markdown
markup.underline.link.markdown (link URL)
string.other.link.title.markdown (link text)
string.other.link.description.markdown
meta.link.inline.markdown, meta.image.inline.markdown
punctuation.definition.heading.markdown
punctuation.definition.bold.markdown, punctuation.definition.italic.markdown
punctuation.definition.list.begin.markdown
meta.separator.markdown (horizontal rules)
```

#### JSON
```
source.json
support.type.property-name.json (keys - **make visually distinct from values**)
string.quoted.double.json (string values)
constant.numeric.json
constant.language.json (true, false, null)
punctuation.definition.string.begin.json, punctuation.definition.string.end.json
punctuation.separator.dictionary.key-value.json (:)
punctuation.separator.array.json (,)
punctuation.definition.dictionary.begin.json, punctuation.definition.dictionary.end.json ({ })
punctuation.definition.array.begin.json, punctuation.definition.array.end.json ([ ])
```

#### YAML
```
source.yaml
entity.name.tag.yaml (keys)
string.unquoted.plain.out.yaml, string.quoted.single.yaml, string.quoted.double.yaml
constant.numeric.yaml
constant.language.boolean.yaml (true, false, yes, no)
constant.language.null.yaml
keyword.control.flow.yaml (---, ...)
punctuation.definition.block.sequence.item.yaml (-)
punctuation.definition.mapping.yaml (:)
variable.other.alias.yaml (&anchor, *alias)
storage.type.tag-handle.yaml (!!str, !!int, etc.)
comment.line.number-sign.yaml
string.unquoted.block.yaml (multiline strings with | or >)
```

#### TOML
```
source.toml
support.type.property-name.toml (keys)
entity.name.section.toml ([section headers])
entity.name.array.toml ([[array tables]])
string.quoted.single.basic.toml, string.quoted.double.basic.toml
constant.numeric.toml, constant.numeric.date.toml
constant.language.boolean.toml
comment.line.number-sign.toml
```

#### Shell / Bash
```
source.shell
keyword.control.shell (if, then, else, elif, fi, for, in, do, done, while, until, case, esac, function, return, exit)
entity.name.function.shell
variable.other.shell ($VAR)
variable.other.bracket.shell (${VAR})
variable.other.special.shell ($0, $1, $@, $#, $?, $$)
string.quoted.double.shell, string.quoted.single.shell
string.interpolated.dollar.shell
support.function.builtin.shell (echo, cd, export, source, test, read, eval, exec, trap, set, unset, shift, wait)
keyword.operator.pipe.shell (|)
keyword.operator.redirect.shell (>, >>, <, 2>, &>)
keyword.operator.logical.shell (&&, ||)
keyword.operator.glob.shell (*, ?)
meta.scope.subshell.shell ($())
punctuation.definition.variable.shell
constant.other.option.shell (command flags like -r, --recursive)
comment.line.number-sign.shell
```

#### SQL
```
source.sql
keyword.other.DML.sql (SELECT, INSERT, UPDATE, DELETE, FROM, WHERE, JOIN, ON, GROUP BY, ORDER BY, HAVING, LIMIT, OFFSET, UNION, INTERSECT, EXCEPT)
keyword.other.DDL.sql (CREATE, ALTER, DROP, TRUNCATE, TABLE, INDEX, VIEW, DATABASE, SCHEMA)
keyword.other.sql (AS, IN, BETWEEN, LIKE, EXISTS, IS, NOT, NULL, AND, OR, DISTINCT, ALL, ANY, CASE, WHEN, THEN, ELSE, END)
storage.type.sql (INT, VARCHAR, TEXT, BOOLEAN, DATE, TIMESTAMP, FLOAT, DECIMAL, SERIAL, UUID)
support.function.sql (COUNT, SUM, AVG, MIN, MAX, COALESCE, CAST, CONVERT, NOW, UPPER, LOWER, LENGTH, TRIM, CONCAT)
constant.other.table-name.sql
entity.name.function.sql
string.quoted.single.sql
constant.numeric.sql
comment.line.double-dash.sql, comment.block.sql
keyword.other.alias.sql (AS)
keyword.operator.comparison.sql (=, <>, <, >, <=, >=)
keyword.operator.star.sql (*)
punctuation.section.scope.sql
```

#### GraphQL
```
source.graphql
keyword.type.graphql (type, input, interface, enum, union, scalar, schema, extend)
keyword.operation.graphql (query, mutation, subscription, fragment, on)
keyword.directive.graphql (@deprecated, @skip, @include)
entity.name.type.graphql
entity.name.function.graphql (field names)
entity.name.fragment.graphql
variable.graphql ($variable)
support.type.builtin.graphql (String, Int, Float, Boolean, ID)
constant.language.graphql (true, false, null)
punctuation.operation.graphql
comment.line.graphql
string.quoted.double.graphql
constant.numeric.graphql
keyword.operator.nulltype.graphql (!)
meta.arguments.graphql
```

#### Protocol Buffers (protobuf)
```
source.proto
keyword.other.proto (syntax, package, import, option, message, enum, service, rpc, returns, oneof, map, reserved, repeated, optional, required)
entity.name.type.proto (message names, enum names)
entity.name.function.proto (rpc method names)
storage.type.proto (int32, int64, uint32, string, bool, bytes, float, double, fixed32, sint32, etc.)
constant.numeric.proto
string.quoted.double.proto
comment.line.double-slash.proto, comment.block.proto
entity.name.class.proto
```

#### Dockerfile
```
source.dockerfile
keyword.other.special-method.dockerfile (FROM, RUN, CMD, LABEL, MAINTAINER, EXPOSE, ENV, ADD, COPY, ENTRYPOINT, VOLUME, USER, WORKDIR, ARG, ONBUILD, STOPSIGNAL, HEALTHCHECK, SHELL)
entity.name.image.dockerfile (image name after FROM)
keyword.operator.dockerfile
variable.other.dockerfile ($VAR, ${VAR})
string.quoted.double.dockerfile, string.quoted.single.dockerfile
comment.line.number-sign.dockerfile
keyword.control.dockerfile (AS)
constant.numeric.dockerfile
```

#### Vue (SFC)
```
source.vue
entity.name.tag.template.vue (template tags)
entity.name.tag.script.vue
entity.name.tag.style.vue
meta.directive.vue (v-if, v-for, v-bind, v-on, v-model, v-show, v-slot)
entity.other.attribute-name.vue (Vue-specific attributes)
punctuation.definition.directive.vue
variable.other.vue (ref, reactive, computed variables)
support.function.vue (defineComponent, defineProps, defineEmits, onMounted, watch, computed)
```

#### Svelte
```
source.svelte
keyword.control.svelte ({#if}, {#each}, {#await}, {:else}, {:then}, {:catch}, {/if}, {/each}, {/await})
entity.name.tag.svelte
entity.other.attribute-name.svelte
meta.special-tag.svelte (on:, bind:, class:, use:, transition:, animate:, in:, out:)
punctuation.definition.keyword.svelte
variable.other.svelte ($: reactive, $store)
entity.name.function.svelte
```

---

## 6. SEMANTIC TOKEN SUPPORT

In addition to TextMate scopes, provide **semantic token colors** for the VS Code semantic highlighting API. This gives more precise highlighting when language servers are active.

```jsonc
"semanticHighlighting": true,
"semanticTokenColors": {
  "namespace": "...",
  "type": "...",
  "type.defaultLibrary": "...",
  "class": "...",
  "class.defaultLibrary": "...",
  "interface": "...",
  "struct": "...",
  "enum": "...",
  "enumMember": "...",
  "typeParameter": "...",
  "function": "...",
  "function.defaultLibrary": "...",
  "method": "...",
  "macro": "...",
  "variable": "...",
  "variable.readonly": "...",
  "variable.readonly.defaultLibrary": "...",
  "variable.defaultLibrary": "...",
  "parameter": "...",
  "property": "...",
  "property.readonly": "...",
  "property.declaration": "...",
  "decorator": "...",
  "event": "...",
  "keyword": "...",
  "comment": "...",
  "string": "...",
  "number": "...",
  "regexp": "...",
  "operator": "...",
  "selfKeyword": "...",
  "builtinType": "...",
  "lifetime": "...",
  "boolean": "...",
  "formatSpecifier": "...",
  "escapeSequence": "...",
  "label": "...",
  "unresolvedReference": "...",
  "*.deprecated": { "strikethrough": true },
  "*.declaration": {},
  "*.definition": {},
  "*.modification": {},
  "*.async": { "fontStyle": "italic" }
}
```

---

## 7. FONT STYLE RULES

Apply font styles **sparingly** and with intent:

| Style | Usage |
|---|---|
| `italic` | Comments, `this`/`self`/`super`, storage modifiers (`async`, `abstract`, `override`, `static`), decorators/annotations, Markdown emphasis, type parameters |
| `bold` | Markdown headings, `markup.bold`, **nothing else** — overusing bold creates visual noise |
| `bold italic` | Only `markup.heading.1` |
| `underline` | Links only |
| `strikethrough` | Deprecated symbols only |
| *(no style)* | Everything else — clean and uniform |

---

## 8. TEST FILES

Create comprehensive test files for each language that exercise **every** scope listed above. Each file should include:
- A header comment explaining what to look for
- Examples of every token type (keywords, types, functions, strings, numbers, comments, operators, etc.)
- Edge cases: deeply nested generics, multiline strings, string interpolation, decorators, complex type annotations
- Real-world-ish code that looks natural, not just isolated tokens

---

## 9. EXTENSION PACKAGING

### `package.json`

```jsonc
{
  "name": "poikile-theme",
  "displayName": "Poikile",
  "description": "Four Stoic-inspired color themes — dark & light, warm & vivid. Named after the Stoa Poikile of ancient Athens.",
  "version": "0.1.0",
  "publisher": "jduartea",
  "license": "MIT",
  "engines": { "vscode": "^1.70.0" },
  "categories": ["Themes"],
  "keywords": ["dark", "light", "stoic", "warm", "vivid", "minimal", "calm", "muted", "theme"],
  "contributes": {
    "themes": [
      { "label": "Poikile - Ataraxia",   "uiTheme": "vs-dark", "path": "./themes/poikile-ataraxia.json" },
      { "label": "Poikile - Apatheia",    "uiTheme": "vs-dark", "path": "./themes/poikile-apatheia.json" },
      { "label": "Poikile - Euthymia",    "uiTheme": "vs",      "path": "./themes/poikile-euthymia.json" },
      { "label": "Poikile - Katalepsis",  "uiTheme": "vs",      "path": "./themes/poikile-katalepsis.json" }
    ]
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/jduartea/poikile-theme"
  },
  "icon": "icon.png"
}
```

---

## 10. RECOMMENDED VS CODE SETTINGS

Include a `recommended-settings.json` with settings that complement the theme:
- Font recommendations (ligature-capable monospace fonts)
- `editor.semanticHighlighting.enabled: true`
- `editor.bracketPairColorization.enabled: true`
- `editor.guides.bracketPairs: "active"`
- `editor.renderWhitespace: "boundary"`
- `editor.cursorBlinking: "smooth"`
- `editor.smoothScrolling: true`
- `workbench.colorCustomizations` overrides for fine-tuning

---

## 11. QUALITY CHECKLIST

Before delivering, verify:
- [ ] WCAG AA contrast (4.5:1) for ALL text tokens on `editor.background`
- [ ] Every color in the palette has ONE clear semantic purpose
- [ ] No two unrelated token types share the same color
- [ ] Comments are clearly less prominent than code
- [ ] Functions/methods are the most prominent code tokens
- [ ] Strings are instantly recognizable
- [ ] The UI chrome (sidebar, activity bar, status bar) recedes behind the editor
- [ ] Active tab is clearly distinguishable from inactive tabs
- [ ] Git diff colors are intuitive (green=added, red=removed, yellow=modified)
- [ ] Error/warning squiggles are visible and color-coded
- [ ] Terminal ANSI colors look good and are distinguishable
- [ ] Bracket pair colors are harmonious with the theme
- [ ] Selection highlight is visible on all background surfaces
- [ ] Search match highlighting is clear and stands out
- [ ] Markdown renders with actual bold, italic, and heading hierarchy
- [ ] JSON keys are visually distinct from values
- [ ] Semantic token highlighting is configured
- [ ] Inlay hints are subtle but readable

---

## 12. DELIVERABLES

Produce **all** of the following files:
1. `themes/poikile-ataraxia.json` — dark warm variant
2. `themes/poikile-apatheia.json` — dark vivid variant
3. `themes/poikile-euthymia.json` — light warm variant
4. `themes/poikile-katalepsis.json` — light vivid variant
5. `package.json` — extension manifest with all 4 variants
6. `README.md` — with palette swatches, philosophy, screenshots placeholder, install instructions
7. `recommended-settings.json`
8. All 21 test files in `test/`
9. `PALETTE.md` — a reference document listing every color per variant, hex codes, contrast ratios, and semantic roles
