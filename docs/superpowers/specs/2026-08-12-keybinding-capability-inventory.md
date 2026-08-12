# Keybinding Capability Inventory

**Date:** 2026-08-12
**Purpose:** Authoritative, docs-sourced list of every bindable capability in this
config — Neovim 0.12 core + all plugins. This is (a) the coverage checklist each
of the three schemes must satisfy, and (b) the backbone for `docs/keybindings.md`.
**Baseline:** Neovim **0.12.4** (ships the `gr*` LSP defaults + `grx` codelens).

Legend: **[cur]** = already bound in the current config · **[NEW]** = capability
we expose today's config does *not* bind · **[opt]** = optional / off by default.

---

## A. Neovim core (built-in — no plugin)

Source: `:help lsp-defaults`, `diagnostic-defaults`, `fold-commands`, `CTRL-W`,
`tabpage`, `motion`, `spell`, `pattern`, `repeat`, `quickfix`, `terminal`.

### LSP (`vim.lsp.buf.*`)
| Capability | Function | 0.12 default |
|---|---|---|
| Definition | `definition()` | (none — `<C-]>` via tagfunc) |
| Declaration | `declaration()` | (none) |
| Implementation | `implementation()` | `gri` |
| Type definition | `type_definition()` | `grt` |
| References | `references()` | `grr` |
| Hover | `hover()` | `K` (buffer-local) |
| Signature help | `signature_help()` | `<C-s>` (insert) |
| Rename | `rename()` | `grn` |
| Code action | `code_action()` | `gra` (n+v) |
| Format | `format()` | (none — `gq` via formatexpr) |
| Document symbols | `document_symbol()` | `gO` |
| **Incoming calls** [NEW] | `incoming_calls()` | (none) |
| **Outgoing calls** [NEW] | `outgoing_calls()` | (none) |
| **Workspace symbols** [NEW] | `workspace_symbol()` | (none) |
| **CodeLens run** [NEW] | `vim.lsp.codelens.run()` | `grx` |
| Inlay hints toggle [cur] | `vim.lsp.inlay_hint.enable(...)` | `<leader>uh` |

### Diagnostics (`vim.diagnostic.*`)
| Capability | Function | default |
|---|---|---|
| Next / prev | `jump({count=±1, float=true})` | `]d` / `[d` |
| **First / last** [NEW] | `jump({count=±math.huge})` | `]D` / `[D` |
| Float at cursor [NEW] | `open_float()` | `<C-w>d` |
| To loclist / qflist [NEW] | `setloclist()` / `setqflist()` | (none) |

### Quickfix / loclist [NEW]
`:cnext`/`:cprev`/`:copen` (bind `]q`/`[q`), `:lnext`/`:lprev`/`:lopen` (`]l`/`[l`).

### Windows/tabs [cur, partial]
`<C-w>` family (split/close/only/rotate/exchange/move `HJKL`/`T`), `gt`/`gT`,
`{count}gt`, `:tabnew`/`:tabclose`/`:tabonly`.

### Folds [cur, partial]
`zo zc za zR zM zr zm zj zk zv zx zi [z ]z` — full set (ufo overrides `zR/zM/zr/zm`).

### Motions/jumps (document, mostly unbound-by-design) [NEW to doc]
`<C-o>`/`<C-i>` jumplist, `<C-t>` tagstack, `<C-]>` tag jump, `gf`/`gF`/`gx`,
`` `` ``/`` `. ``, marks `m`/`` ` ``, `%`/matchit, `[(` `])` `[{` `]}`.

### Spell [NEW to doc]
`]s`/`[s` next/prev misspelling, `z=` suggest, `zg`/`zw` add/wrong, `zug`/`zuw` undo.

### Search [cur, partial]
`n`/`N`, `*`/`#`, `g*`/`g#`, `:nohlsearch` (`<Esc>` bound), `gn`/`gN` (e.g. `cgn`), `&`.

### Text objects & operators (for the how-to guide) [NEW to doc]
`iw/aw iW/aW is/as ip/ap i(/a( i{/a{ i[/a[ i</a< i"/a' it/at`; operators
`d c y v > < = gu/gU gc`; combos `ciw di( ya" dap vi{`.

### Registers / macros / repeat [NEW to doc]
`"{reg}` (incl. `"+` clipboard), `q…q` record, `@`/`@@`/`@:`, `.` dot-repeat, `:reg`.

### Terminal [cur, partial]
`:terminal`, `<C-\><C-n>` exit-to-normal, `<C-\><C-o>` one-shot-normal.

---

## B. LSP / coding plugins

- **nvim-lspconfig** — wiring only; verbs are `vim.lsp.buf.*` (see §A).
- **blink.cmp** (completion) [cur]: preset keys — `<C-space>` show/docs, `<C-e>`
  hide, `<C-y>` accept, `<C-p>`/`<C-n>` select, `<C-b>`/`<C-f>` scroll docs,
  `<Tab>`/`<S-Tab>` snippet jump, `<C-k>` signature. Distinct **[NEW]** actions:
  `accept` (vs select_and_accept), `cancel` (revert ghost-text).
- **conform.nvim** (format) [cur]: `require("conform").format(...)` — **no default
  `:Format` command**; we own the keymap. Format-on-save via autocmd.
- **nvim-lint** [cur]: `require("lint").try_lint()` — usually an autocmd; **[opt]**
  bind manual re-lint.
- **aerial.nvim** (outline) [cur]: `:AerialToggle`; **[NEW]** `{`/`}` next/prev
  symbol + `[[`/`]]` parent motion (bind globally), `:AerialNavToggle` popup.
- **glance.nvim** (peek) [cur]: `Glance references|definitions|implementations|
  type_definitions`; in-peek `<C-q>`→quickfix [NEW to doc].
- **trouble.nvim** [cur, partial]: `diagnostics`, `symbols`, `lsp`, `loclist`,
  `qflist`, **[NEW]** `lsp_incoming_calls`/`lsp_outgoing_calls`, `todo`.
- **todo-comments.nvim** [NEW]: `jump_next()`/`jump_prev()` (`]t`/`[t`),
  `:TodoTrouble`, `:TodoQuickFix`.
- **nvim-navic + barbecue** — breadcrumbs, display-only; only bindable action is
  `barbecue.ui.navigate(i)` [opt].
- **lazydev.nvim** — no keybindings.

---

## C. Navigation / find

- **snacks.picker** [cur, heavily under-bound]: `files`, `grep`, `recent`,
  `buffers`, `projects` are bound; **[NEW]**: `smart()`, `resume()`,
  `grep_word()`, `command_history()`, `lsp_symbols()`, `lsp_definitions/
  references/implementations()`, `diagnostics()`, `keymaps()`, `help()`,
  `commands()`, and the `git_*` family (`git_status/log/log_file/branches/
  diff/stash`), `highlights()`.
- **snacks.notifier** [cur]: `show_history()`, `hide()`. **snacks.explorer()** [opt]
  (alt to neo-tree). **snacks.terminal** [cur via toggleterm instead].
- **flash.nvim** [cur, partial]: `s` jump bound; **[NEW]** `S` treesitter,
  `r` remote (o), `R` treesitter_search, `<C-s>` toggle-in-search.
- **harpoon** (harpoon2) [cur, partial]: add + menu bound; **[NEW]** `select(1..4)`,
  `next()`/`prev()`. ⚠ plugin's default slot keys are `<C-h/j/k/l>` — **collide
  with base pane-nav**; we must assign different keys (see design §Conflicts).
- **neo-tree** [cur]: `:Neotree toggle/focus/reveal`; **[NEW]** sources
  `buffers`, `git_status`, `document_symbols`.
- **project.nvim** [cur]: switching via `Snacks.picker.projects()` (Telescope
  switcher unused). `:ProjectRoot` [opt].
- **telescope** — `enabled=false`; superseded by snacks.picker. Not bound.

---

## D. Git

- **gitsigns** [cur, partial]: stage/reset/preview/blame/stage-buffer + `]c`/`[c`
  bound; **[NEW]**: `preview_hunk_inline()`, `undo_stage_hunk()`, `reset_buffer()`,
  `diffthis('~')`, `toggle_current_line_blame()`, `toggle_word_diff()`,
  `toggle_deleted()`, full-file `blame()`, `setqflist('all')`, and the **`ih`
  hunk text-object** (o+x modes).
- **diffview** [cur, partial]: `:DiffviewOpen`, `:DiffviewFileHistory %` bound;
  **[NEW]**: rev/range diff args, `:DiffviewToggleFiles`, in-view conflict keys
  (`[x`/`]x`, `<leader>co`/`<leader>ct`).
- **lazygit** [cur]: `:LazyGit`; **[NEW]** `:LazyGitCurrentFile`, `:LazyGitFilter`.

---

## E. Run / test / debug

- **nvim-dap** [cur, partial]: breakpoint/continue/step bound; **[NEW]**:
  `set_breakpoint(cond)`, `run_to_cursor()`, `terminate()`, `restart()`,
  `run_last()`, `repl.toggle()`, and `dap.ui.widgets.hover()`/`preview()`.
- **nvim-dap-ui** [cur, partial]: toggle bound; **[NEW]** `eval()` (n+v).
- **mason-nvim-dap** — bridge only, no keys.
- **neotest** [cur, partial]: run-nearest/file/summary bound; **[NEW]**:
  `run({strategy='dap'})` debug-nearest, `run({suite=true})`, `run_last()`,
  `stop()`, `output.open()`, `output_panel.toggle()`, `jump.next/prev({status=
  'failed'})`, `watch.toggle()`.
- **neotest-go / neotest-jest** — adapters, no keys.
- **overseer** [cur, partial]: run/toggle bound; **[NEW]**: `:OverseerRunCmd`,
  `:OverseerQuickAction`, `:OverseerTaskAction`, bundles.

---

## F. Editing / text

- **nvim-surround** [cur — NOTE: spec previously mis-named this "mini.surround"]:
  `ys{motion}{char}`, `yss`, `S` (visual), `ds`, `cs`, insert `<C-g>s`. Dot-repeat.
- **mini.ai** [cur]: extended `a`/`i` objects — `f` function-call, `a` argument,
  `t` tag, `q` quote, `?` prompt, `an`/`in` next, `al`/`il` last, `g[`/`g]` edges.
- **mini.splitjoin** [cur]: `gS` toggle split/join.
- **mini.bufremove** [cur]: `delete()` (`<leader>bd`), `wipeout()` [opt].
- **nvim-ufo** [cur, partial]: `zR`/`zM` bound; **[NEW]** `openFoldsExceptKinds`
  (`zr`), `closeFoldsWith` (`zm`), **`peekFoldedLinesUnderCursor()`** (bind on `K`
  with hover fallback).
- **vim-visual-multi** [NEW — currently unbound]: `<C-n>` select-next,
  `<C-Down>`/`<C-Up>` add cursor, `\\A` select-all-occurrences, `n`/`N`/`[`/`]`/
  `q`/`Q` in VM mode, `<Tab>` cursor/extend toggle.
- **treesitter incremental selection** [opt — not configured]: if enabled, use
  **safe keys off the `gr*` namespace** (README defaults `grn/grc/grm` collide
  with LSP `grn`). Proposed: `<C-space>` init/expand, `<BS>` shrink.
- **nvim-autopairs** — automatic; only `<M-e>` fast-wrap [opt]. **nvim-ts-autotag**
  — automatic, no keys.
- **grug-far** [cur]: `require("grug-far").open()`; **[NEW]** `with_visual_selection()`,
  `:GrugFarWithin`. In-buffer keys are `<localleader>`-prefixed — **localleader
  must be set** (document prominently).

---

## G. UI / misc

- **bufferline** [cur, partial]: `<S-l>`/`<S-h>` cycle bound; **[NEW]**
  `:BufferLineMoveNext/Prev`, `TogglePin`, `Pick`, `PickClose`, `GoToBuffer N`.
- **toggleterm** [cur, partial]: toggle + numbered bound; **[NEW]** `TermExec`,
  `ToggleTermSendCurrentLine`/`SendVisualSelection`, `ToggleTermToggleAll`.
- **persistence** [cur, partial]: `load()` bound; **[NEW]** `load({last=true})`,
  `select()`, `stop()`.
- **vim-illuminate** [NEW]: `goto_next_reference`/`goto_prev_reference`. ⚠ plugin
  suggests `]]`/`[[` which collide with native section/aerial-parent motion —
  bind **`]r`/`[r`** instead (design §Conflicts).
- **copilot.lua** [cur]: accept `<C-l>` (insert), next `<C-]>`, dismiss `<C-e>`.
  Plugin default is `<M-l>`; our insert-mode `<C-l>` does **not** collide with
  normal-mode pane-nav `<C-l>`.
- **render-markdown** [NEW]: `:RenderMarkdown toggle` (`<leader>um`) [opt].
- **neoscroll** — auto-remaps `<C-d/u/f/b>`, `zz` etc. (animated); no new binds.
- **which-key, lualine, fidget, smear-cursor, rainbow-delimiters,
  indent-blankline, devicons, scope, dashboard** — display-only / automatic;
  no user keybindings (dashboard has in-buffer menu keys only).
- **claudecode** [cur]: `:ClaudeCode*` command family (already bound `<leader>a*`).

---

## Coverage note

Each scheme (classic / consistent / editor) must provide a binding for every
**[cur]** capability and SHOULD expose the high-value **[NEW]** ones
(snacks git/lsp pickers, gitsigns toggles + `ih`, dap hover/eval, neotest
debug-nearest + output-panel + jump-failed, ufo peek, todo nav, illuminate
reference-nav, multicursor, incoming/outgoing calls, workspace symbols). **[opt]**
capabilities are documented but bound only where they fit the scheme's budget.
