# Ghostty ↔ Neovim key forwarding

Terminal apps receive *bytes*, not key events. macOS + the terminal swallow `Cmd`
before nvim sees it, so `Cmd`-based shortcuts only reach nvim if Ghostty is told
to forward them. This file is that config. **Everything here is optional** — every
Cmd shortcut has a `<leader>`/Ctrl fallback that works with zero setup (see bottom).

Add the following to `~/.config/ghostty/config`, then fully quit & reopen Ghostty
(or reload the config).

## 1. Option key → Alt (needed for Alt+Enter, Alt+F7, Alt+↑/↓)

```
macos-option-as-alt = true
```

This makes `Option` send `Alt` (`<M-...>`), so the IntelliJ-style `Alt+Enter`
(code action), `Alt+F7` (find references), and `Alt+↑/↓` (move line) reach nvim.

## 2. Forward specific Cmd chords (CSI-u sequences nvim decodes to `<D-...>`)

Neovim 0.12 speaks the kitty keyboard protocol, so a CSI-u byte sequence carrying
the `super` (Cmd) modifier decodes to a `<D-...>` mapping. These lines make Ghostty
emit those sequences:

```
# Cmd+Shift+N  -> ESC[110;10u -> <D-N> -> Telescope find_files
keybind = cmd+shift+n=csi:110;10u

# Cmd+/        -> ESC[47;9u   -> <D-/> -> toggle comment
keybind = cmd+slash=csi:47;9u
```

`csi:X` makes Ghostty emit `ESC [ X`. The CSI-u form is `<keycode> ; <modifier> u`,
where modifier = `1 + shift(1) + alt(2) + ctrl(4) + super/Cmd(8)`. So Cmd+/ =
`1+8 = 9`; Cmd+Shift+N = `1+1+8 = 10`. (Ghostty normalizes `cmd` to `super`
internally — both spellings validate.) The nvim side is already wired:
`<D-N>`/`<D-n>` in `lua/plugins/navigation.lua`, `<D-/>` in `lua/core/keymaps.lua`.
Validate any config change with `ghostty +show-config`.

> If a chord doesn't trigger after reload, your Ghostty/nvim build may decode the
> modifier slightly differently — press it and check `:messages`, then adjust the
> keycode/modifier, or just use the fallback below. The fallbacks always work.

## 3. Add more Cmd chords (optional, same pattern)

Pick the keycode (lowercase unicode codepoint) and modifier, add a `keybind`, and
add the matching `<D-...>` map in nvim. Example:

```
# Cmd+P -> file lookup (keycode 'p'=112, Cmd=9); then map <D-p> in navigation.lua
keybind = cmd+p=csi:112;9u
```
(Keep comments on their own line — Ghostty reads everything after `=` as the value.)

## Fallbacks that always work (no Ghostty config)

| Action | Cmd shortcut (needs forwarding) | Always-works fallback |
|---|---|---|
| Find files | `Cmd+Shift+N` | `<Space>ff` (or `<Space><Space>`) |
| Toggle comment | `Cmd+/` | `Ctrl+/` (`<C-_>`) — works in Ghostty now |
| Code action | `Alt+Enter` | `gr`-family / which-key |
| Find references | `Alt+F7` | `gr` |

`which-key` (press `<Space>` and pause) lists every leader binding live.
