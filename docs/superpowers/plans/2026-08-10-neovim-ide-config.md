# Neovim IDE Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an IDE-like Neovim config that keeps vanilla vim motions, mirrors the user's IntelliJ keymap for editor features, and runs correctly in two homes: standalone Ghostty (full IDE) and embedded in VS Code via `vscode-neovim` (editing engine only, no UI).

**Architecture:** A shared `lua/core/*` layer (options + keymaps, safe everywhere) always loads. `init.lua` then loads the terminal-only IDE layer (`lazy.nvim` + all plugins) **only when `vim.g.vscode` is nil**. Plugins are one-file-per-concern under `lua/plugins/`, auto-imported by lazy.

**Tech Stack:** Neovim 0.12, Lua, lazy.nvim, mason, native `vim.lsp`, blink.cmp, treesitter, telescope, nvim-dap, neotest, overseer.

## Global Constraints

- Neovim **0.12+** APIs allowed (`vim.lsp.enable`, `vim.lsp.config`, kitty keyboard protocol).
- **VS Code guard is the top invariant:** when `vim.g.vscode` is set, NO plugin/theme/UI loads. A regression reproduces the "unreadable text" bug.
- **Indent:** `shiftwidth=2`, `tabstop=2`, `expandtab`; Python overrides to 4 via ftplugin.
- **Line numbers:** absolute (`number`, no `relativenumber`).
- **Format on save: OFF.** Formatting is manual on `<C-A-l>` via conform.
- **Inline diagnostics REQUIRED:** gutter signs + end-of-line virtual text.
- **Theme:** softened `github_dark`; identifier treesitter groups tuned toward neutral foreground.
- **Clipboard:** `unnamedplus` (macOS pbcopy/pbpaste).
- **Leader:** `<Space>`; localleader `\`.
- Every plugin spec file returns a lazy table and must load without error headless.
- Commit after every task. Repo is `~/.config/nvim`.

### Standard verification (NETWORK-FREE; used by every task)

Real plugin/server installation is deferred to a single `:Lazy sync` at the very
end (done by the user/controller after all build tasks). **Per-task verification
must NOT hit the network** — never run `:Lazy sync`, `:Mason install`, or
`:TSUpdate` inside a task. Use only:

```bash
# A — plugin spec file is syntactically valid and returns a table (no lazy boot,
#     no network). Replace FILE with the file the task creates.
nvim --headless --noplugin -u NONE \
  "+lua local ok,r=pcall(dofile,'lua/plugins/FILE.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK')" "+qa"

# C — VS Code guard: core loads, lazy does NOT (network-free by design, since the
#     guard returns before requiring config.lazy)
nvim --headless --cmd "let g:vscode = 1" \
  "+lua assert(not package.loaded['lazy'], 'lazy must NOT load under vscode')" \
  "+lua assert(vim.g.mapleader, 'core must still load')" "+qa" && echo "GUARD-OK"
```

`SPEC-OK` / `GUARD-OK` printed = pass. Any Lua error = fail.

---

## Phase 0 — Repo & harness

### Task 0: Initialize git and the healthcheck script

**Files:**
- Create: `.gitignore`
- Create: `scripts/healthcheck.sh`
- Modify: (init git in `~/.config/nvim`)

**Interfaces:**
- Produces: `scripts/healthcheck.sh` — runs verifications A and C above; exit non-zero on failure. Later tasks call `bash scripts/healthcheck.sh`.

- [ ] **Step 1: Init git and ignore lazy/mason state**

```bash
cd ~/.config/nvim
git init
```

`.gitignore`:
```gitignore
# Neovim runtime state we don't version
plugin/
.luarc.json
*.log
# SDD scratch (ledger, briefs, review packages)
.superpowers/
# Keep lazy-lock.json tracked (reproducibility); ignore everything else transient
```

- [ ] **Step 2: Write the healthcheck script**

`scripts/healthcheck.sh` (network-free; validates every plugin spec + the guard):
```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== spec files return tables =="
for f in lua/plugins/*.lua; do
  nvim --headless --noplugin -u NONE \
    "+lua local ok,r=pcall(dofile,'$f'); assert(ok and type(r)=='table', '$f: '..tostring(r))" "+qa" \
    && echo "SPEC-OK $f"
done
echo "== vscode guard: core loads, lazy does not =="
nvim --headless --cmd "let g:vscode = 1" \
  "+lua assert(not package.loaded['lazy'], 'lazy loaded under vscode')" \
  "+lua assert(vim.g.mapleader, 'core did not load')" "+qa"
echo "GUARD-OK"
```

- [ ] **Step 3: Verify script runs (config still bare, should pass A/C once core exists)**

Run: `chmod +x scripts/healthcheck.sh` — deferred full run until Task 3.
Expected: file executable.

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "chore: init git repo + healthcheck harness"
```

---

## Phase 1 — Shared core (loads in BOTH homes)

### Task 1: Core options

**Files:**
- Modify: `lua/core/options.lua`
- Create: `after/ftplugin/python.lua`

**Interfaces:**
- Produces: sets `vim.g.mapleader`/`maplocalleader`, `clipboard`, indent, numbers, diagnostics config. Consumed by every later task (leader especially).

- [ ] **Step 1: Write options**

`lua/core/options.lua`:
```lua
-- Leaders must be set before lazy/keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.opt
o.clipboard = "unnamedplus"        -- macOS system clipboard
o.number = true                    -- absolute line numbers (user preference)
o.relativenumber = false
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true
o.wrap = false
o.signcolumn = "yes"               -- stable gutter for diagnostics/git
o.termguicolors = true
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.splitright = true
o.splitbelow = true
o.scrolloff = 6
o.updatetime = 250
o.timeoutlen = 400                 -- which-key popup delay

-- Inline diagnostics: gutter signs + end-of-line virtual text (REQUIRED)
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
```

`after/ftplugin/python.lua`:
```lua
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
```

- [ ] **Step 2: Verify headless**

Run: `nvim --headless "+lua assert(vim.o.shiftwidth==2 and vim.g.mapleader==' ')" "+qa" && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(core): options, clipboard, diagnostics, python ftplugin"
```

### Task 2: Shared keymaps (VS Code-safe)

**Files:**
- Modify: `lua/core/keymaps.lua`

**Interfaces:**
- Consumes: leader from Task 1.
- Produces: motion-safe maps only; NO LSP/plugin maps here (those live with their plugin).

- [ ] **Step 1: Write shared keymaps**

`lua/core/keymaps.lua`:
```lua
local map = vim.keymap.set

-- Reflex copy/paste that does NOT shadow vim motions
map("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
map("i", "<C-v>", "<C-r>+", { desc = "Paste from system clipboard" })
map("v", "<C-v>", '"+p', { desc = "Paste over selection" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Move lines (works everywhere, matches IDE alt-shift-arrow habit)
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
```

- [ ] **Step 2: Verify headless (also under vscode)**

Run: `nvim --headless --cmd "let g:vscode=1" "+qa" 2>&1 | grep -i error && echo FAIL || echo OK`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(core): shared vscode-safe keymaps"
```

### Task 3: init.lua with the VS Code guard + lazy bootstrap

**Files:**
- Modify: `init.lua`
- Create: `lua/config/lazy.lua`

**Interfaces:**
- Consumes: `core` (Tasks 1–2).
- Produces: `require("config.lazy")` bootstraps lazy and imports `lua/plugins/`. Guard: plugins load only when `vim.g.vscode` is nil.

- [ ] **Step 1: Write init.lua**

`init.lua`:
```lua
require("core")            -- options + keymaps (both homes)

if not vim.g.vscode then   -- TERMINAL HOME ONLY
  require("config.lazy")
end
```

Ensure `lua/core/init.lua` requires both:
```lua
require("core.options")
require("core.keymaps")
```

- [ ] **Step 2: Write lazy bootstrap**

`lua/config/lazy.lua`:
```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "github_dark" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
```

Create an empty `lua/plugins/init.lua` returning `{}` so the import never errors before plugins exist:
```lua
return {}
```

- [ ] **Step 3: Verify both homes (network-free)**

Run: `bash scripts/healthcheck.sh`
Expected: `SPEC-OK lua/plugins/init.lua` then `GUARD-OK`. Do NOT boot lazy here (no
network in tasks); the real first `:Lazy sync` happens once after all build tasks.

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: init.lua vscode guard + lazy.nvim bootstrap"
```

---

## Phase 2 — Theme & core UI (terminal only)

### Task 4: Theme (softened github_dark) + devicons

**Files:**
- Create: `lua/plugins/ui.lua`

**Interfaces:**
- Produces: colorscheme `github_dark` applied with identifier overrides; `nvim-web-devicons` available to all UI plugins.

- [ ] **Step 1: Write theme spec with white-tuned identifiers**

`lua/plugins/ui.lua`:
```lua
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "projekt0n/github-nvim-theme",
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = { styles = { comments = "italic", keywords = "NONE" } },
      })
      vim.cmd.colorscheme("github_dark")
      -- Darcula/Dracula-style: push identifiers toward neutral foreground
      local fg = "#c9d1d9"
      for _, g in ipairs({ "@variable", "@property", "@field", "@parameter",
                           "@variable.member", "@variable.parameter" }) do
        vim.api.nvim_set_hl(0, g, { fg = fg })
      end
    end,
  },
}
```

- [ ] **Step 2: Verify spec structure (network-free)**

Run: `nvim --headless --noplugin -u NONE "+lua local ok,r=pcall(dofile,'lua/plugins/ui.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK')" "+qa"`
Expected: `SPEC-OK`. (Colorscheme actually applying is verified in the final real `:Lazy sync`.)

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(ui): softened github_dark theme + devicons"
```

### Task 5: Statusline, bufferline tabs, which-key, breadcrumbs

**Files:**
- Create: `lua/plugins/ui_extra.lua`

**Interfaces:**
- Consumes: devicons (Task 4), nvim-navic attaches via LSP (Task 8) but degrades gracefully if absent.
- Produces: `lualine`, `bufferline` (file tabs), `which-key` (leader popup), `barbecue` + `navic` (breadcrumbs).

- [ ] **Step 1: Write spec**

`lua/plugins/ui_extra.lua`:
```lua
return {
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    opts = { options = { theme = "auto", globalstatus = true } } },

  { "akinsho/bufferline.nvim", event = "VeryLazy",
    opts = { options = { diagnostics = "nvim_lsp", separator_style = "slant" } },
    keys = {
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer/tab" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer/tab" },
    } },

  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },

  { "utilyre/barbecue.nvim", event = "VeryLazy",
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    opts = { attach_navic = true } },
}
```

- [ ] **Step 2: Verify (network-free)**

Run: `nvim --headless --noplugin -u NONE "+lua local ok,r=pcall(dofile,'lua/plugins/ui_extra.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK')" "+qa"`
Expected: `SPEC-OK`

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(ui): lualine, bufferline tabs, which-key, breadcrumbs"
```

---

## Phase 3 — Editing intelligence

### Task 6: Treesitter + rainbow + indent guides + illuminate

**Files:**
- Create: `lua/plugins/treesitter.lua`

**Interfaces:**
- Produces: syntax + navic-feeding symbols for the languages in scope.

- [ ] **Step 1: Write spec**

`lua/plugins/treesitter.lua`:
```lua
return {
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "yaml",
        "markdown", "html", "css", "javascript", "typescript", "tsx",
        "svelte", "sql", "dockerfile", "go", "gomod", "rust", "c", "cpp",
        "java", "kotlin" },
      highlight = { enable = true },
      indent = { enable = true },
    } },
  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },
  { "lukas-krecan/indent-blankline.nvim", name = "ibl", main = "ibl",
    event = "BufReadPost", opts = {} },
  { "RRethy/vim-illuminate", event = "BufReadPost" },
}
```

- [ ] **Step 2: Verify (network-free)**

Run: `nvim --headless --noplugin -u NONE "+lua local ok,r=pcall(dofile,'lua/plugins/treesitter.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK')" "+qa"`
Expected: `SPEC-OK`. (Parsers actually install in the final real `:Lazy sync` + `:TSUpdate`.)

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(edit): treesitter parsers, rainbow, indent guides, illuminate"
```

### Task 7: Completion (blink.cmp) + autopairs + surround + multi-cursor

**Files:**
- Create: `lua/plugins/completion.lua`
- Create: `lua/plugins/editor.lua`

**Interfaces:**
- Produces: `Ctrl+Space` completion trigger; arrows+Enter selection; autopairs; `nvim-surround`; `vim-visual-multi` (`Ctrl+N`). blink exposes `capabilities` for LSP (Task 8) via `require("blink.cmp").get_lsp_capabilities()`.

- [ ] **Step 1: Write completion spec**

`lua/plugins/completion.lua`:
```lua
return {
  { "saghen/blink.cmp", version = "*", event = "InsertEnter",
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      completion = { documentation = { auto_show = true } },
    } },
}
```

- [ ] **Step 2: Write editor extras spec**

`lua/plugins/editor.lua`:
```lua
return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },
  { "mg979/vim-visual-multi", event = "BufReadPost" },  -- Ctrl+N multi-cursor
  { "folke/todo-comments.nvim", event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
}
```

- [ ] **Step 3: Verify (network-free) — both files**

Run:
```bash
for f in completion editor; do
  nvim --headless --noplugin -u NONE \
    "+lua local ok,r=pcall(dofile,'lua/plugins/$f.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK $f')" "+qa"
done
```
Expected: `SPEC-OK completion` and `SPEC-OK editor`.

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat(edit): blink.cmp completion, autopairs, surround, multi-cursor, todo"
```

---

## Phase 4 — LSP & formatting

### Task 8: Mason + native LSP + IntelliJ keymaps + conform + lint + fidget

**Files:**
- Create: `lua/plugins/lsp.lua`

**Interfaces:**
- Consumes: blink capabilities (Task 7), navic (Task 5).
- Produces: LSP servers enabled via `vim.lsp.enable`; on-attach binds the IntelliJ keymap table; conform on `<C-A-l>`; nvim-lint; fidget progress.

- [ ] **Step 1: Write LSP spec**

`lua/plugins/lsp.lua`:
```lua
return {
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  { "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "SmiteshP/nvim-navic",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local servers = { "lua_ls", "ts_ls", "svelte", "tailwindcss", "html",
        "cssls", "jsonls", "eslint", "gopls", "clangd",
        "kotlin_language_server", "dockerls", "sqls" }
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = servers })

      local caps = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = caps })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, b)
          end
          local function m(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = b, desc = desc })
          end
          m("gd", vim.lsp.buf.definition, "Go to definition")
          m("<F4>", vim.lsp.buf.definition, "Go to definition")
          m("gi", vim.lsp.buf.implementation, "Go to implementation")
          m("gr", vim.lsp.buf.references, "Find references")
          m("<A-F7>", vim.lsp.buf.references, "Find references")
          m("K", vim.lsp.buf.hover, "Hover docs")
          m("<S-F6>", vim.lsp.buf.rename, "Rename")
          m("<A-CR>", vim.lsp.buf.code_action, "Code action")
          m("<C-A-o>", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } }, apply = true })
          end, "Organize imports")
        end,
      })

      for _, s in ipairs(servers) do vim.lsp.enable(s) end
    end,
  },

  { "stevearc/conform.nvim", event = "BufWritePre",
    keys = { { "<C-A-l>", function() require("conform").format({ lsp_fallback = true }) end,
              mode = { "n", "v" }, desc = "Reformat (IntelliJ)" } },
    opts = {
      format_on_save = false,   -- user preference: OFF
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettier" }, css = { "prettier" }, html = { "prettier" },
        json = { "prettier" }, go = { "gofmt" }, rust = { "rustfmt" },
      },
    } },

  { "mfussenegger/nvim-lint", event = "BufReadPost",
    config = function()
      require("lint").linters_by_ft = { javascript = { "eslint_d" },
        typescript = { "eslint_d" }, dockerfile = { "hadolint" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function() require("lint").try_lint() end })
    end },
}
```

- [ ] **Step 2: Verify (network-free)**

Run: `nvim --headless --noplugin -u NONE "+lua local ok,r=pcall(dofile,'lua/plugins/lsp.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK')" "+qa"`
Expected: `SPEC-OK`. (Real server install + attach is verified in the final `:Lazy sync`/`:Mason` smoke test, not here — no network in tasks.)

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(lsp): mason + native lsp, IntelliJ keymaps, conform, lint, fidget"
```

### Task 9: Language specials — Java (jdtls) + Rust (rustaceanvim)

**Files:**
- Create: `lua/plugins/lang.lua`
- Create: `ftplugin/java.lua`

**Interfaces:**
- Consumes: mason (Task 8) to install `jdtls`, `codelldb`.
- Produces: jdtls attaches on Java buffers; rustaceanvim owns rust-analyzer (do NOT also enable it in Task 8 — it is not in that list).

- [ ] **Step 1: Write spec**

`lua/plugins/lang.lua`:
```lua
return {
  { "mfussenegger/nvim-jdtls", ft = "java" },      -- driven by ftplugin/java.lua
  { "mrcjkb/rustaceanvim", version = "^5", lazy = false, ft = "rust" },
}
```

`ftplugin/java.lua`:
```lua
local ok, jdtls = pcall(require, "jdtls")
if not ok then return end
local root = vim.fs.root(0, { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" })
if not root then return end
local mason = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local ws = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:h:t")
jdtls.start_or_attach({
  cmd = { mason .. "/bin/jdtls", "-data", ws },
  root_dir = root,
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
```

- [ ] **Step 2: Verify (network-free)**

Run: `nvim --headless --noplugin -u NONE "+lua local ok,r=pcall(dofile,'lua/plugins/lang.lua'); assert(ok and type(r)=='table', tostring(r)); print('SPEC-OK')" "+qa"`
Expected: `SPEC-OK`. (jdtls/codelldb install in the final real sync.)

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat(lang): nvim-jdtls (Java) + rustaceanvim (Rust)"
```

---

## Phase 5 — Diagnostics UX & navigation

### Task 10: Trouble (Problems panel)

**Files:**
- Create: `lua/plugins/diagnostics.lua`

- [ ] **Step 1: Write spec**

`lua/plugins/diagnostics.lua`:
```lua
return {
  { "folke/trouble.nvim", cmd = "Trouble", opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Problems (all)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Problems (buffer)" },
    } },
}
```

- [ ] **Step 2: Verify** — Run standard verification A. Expected `OK`.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(diag): trouble.nvim problems panel"`

### Task 11: Telescope + aerial + harpoon + flash + project.nvim + dashboard

**Files:**
- Create: `lua/plugins/navigation.lua`

**Interfaces:**
- Produces: file lookup, search-everywhere, recent files, outline, harpoon marks, flash jump, projects picker, start screen.

- [ ] **Step 1: Write spec**

`lua/plugins/navigation.lua`:
```lua
return {
  { "nvim-telescope/telescope.nvim", cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader><leader>", "<cmd>Telescope find_files<cr>", desc = "Search everywhere" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    },
    config = function()
      require("telescope").setup({})
      pcall(require("telescope").load_extension, "projects")
    end },

  { "stevearc/aerial.nvim", cmd = "AerialToggle", opts = {},
    keys = { { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Outline" } } },

  { "ThePrimeagen/harpoon", branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<leader>hh", function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon menu" },
    },
    config = function() require("harpoon"):setup() end },

  { "folke/flash.nvim", event = "VeryLazy",
    keys = { { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" } } },

  { "ahmedkhalf/project.nvim", event = "VeryLazy", main = "project_nvim", opts = {} },

  { "nvimdev/dashboard-nvim", event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { theme = "hyper", config = { project = { enable = true } } } },
}
```

- [ ] **Step 2: Verify** — Run verification A. Expected `OK`.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(nav): telescope, aerial, harpoon, flash, projects, dashboard"`

### Task 12: File tree (neo-tree)

**Files:**
- Create: `lua/plugins/tree.lua`

- [ ] **Step 1: Write spec**

`lua/plugins/tree.lua`:
```lua
return {
  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x", cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim" },
    keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File explorer" } },
    opts = { filesystem = { follow_current_file = { enabled = true } } } },
}
```

- [ ] **Step 2: Verify** — verification A. Expected `OK`.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(nav): neo-tree file explorer"`

---

## Phase 6 — Git

### Task 13: gitsigns + lazygit + diffview

**Files:**
- Create: `lua/plugins/git.lua`

- [ ] **Step 1: Write spec**

`lua/plugins/git.lua`:
```lua
return {
  { "lewis6991/gitsigns.nvim", event = "BufReadPre",
    opts = { current_line_blame = true },  -- inline blame like GitLens
    keys = {
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line" },
      { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
      { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev hunk" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk" },
    } },
  { "kdheepak/lazygit.nvim", cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } } },
  { "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = { { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" } } },
}
```

- [ ] **Step 2: Verify** — verification A. Expected `OK`. (Requires `lazygit` binary via brew — note in WALKTHROUGH.)
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(git): gitsigns blame, lazygit, diffview"`

---

## Phase 7 — Debug, run & test

### Task 14: nvim-dap suite

**Files:**
- Create: `lua/plugins/debug.lua`

**Interfaces:**
- Produces: breakpoints + stepping bound to F-keys; dap-ui auto-opens.

- [ ] **Step 1: Write spec**

`lua/plugins/debug.lua`:
```lua
return {
  { "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "jay-babu/mason-nvim-dap.nvim", opts = { ensure_installed = { "codelldb", "delve" } } },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<F8>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F7>", function() require("dap").step_into() end, desc = "Step into" },
      { "<S-F8>", function() require("dap").step_out() end, desc = "Step out" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
    end },
}
```

- [ ] **Step 2: Verify** — verification A. Expected `OK`.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(debug): nvim-dap + dap-ui + mason-dap"`

### Task 15: neotest + overseer (run/test/build configs)

**Files:**
- Create: `lua/plugins/run.lua`

**Interfaces:**
- Produces: `<leader>t*` test running, `<leader>rr` task running.

- [ ] **Step 1: Write spec**

`lua/plugins/run.lua`:
```lua
return {
  { "nvim-neotest/neotest",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest", "nvim-neotest/neotest-go", "mrcjkb/rustaceanvim" },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Test nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-go"),
          require("rustaceanvim.neotest"),
        },
      })
    end },

  { "stevearc/overseer.nvim", cmd = { "OverseerRun", "OverseerToggle" },
    keys = {
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Run task/build" },
      { "<leader>rl", "<cmd>OverseerToggle<cr>", desc = "Task list" },
    }, opts = {} },
}
```

- [ ] **Step 2: Verify** — verification A. Expected `OK`.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(run): neotest + overseer"`

---

## Phase 8 — Terminal, sessions, AI

### Task 16: toggleterm + persistence

**Files:**
- Create: `lua/plugins/shell.lua`

- [ ] **Step 1: Write spec**

`lua/plugins/shell.lua`:
```lua
return {
  { "akinsho/toggleterm.nvim", cmd = "ToggleTerm",
    keys = { { "<C-\\>", "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Terminal" } },
    opts = { direction = "horizontal", size = 15 } },
  { "folke/persistence.nvim", event = "BufReadPre", opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
    } },
}
```

- [ ] **Step 2: Verify** — verification A. Expected `OK`.
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(shell): toggleterm + persistence sessions"`

### Task 17: Copilot

**Files:**
- Create: `lua/plugins/ai.lua`

- [ ] **Step 1: Write spec**

`lua/plugins/ai.lua`:
```lua
return {
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter",
    opts = {
      suggestion = { auto_trigger = true,
        keymap = { accept = "<C-l>", next = "<C-]>", dismiss = "<C-e>" } },
      panel = { enabled = false },
    } },
}
```

- [ ] **Step 2: Verify** — verification A. Expected `OK`. (User runs `:Copilot auth` once — note in WALKTHROUGH.)
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat(ai): copilot.lua inline suggestions"`

---

## Phase 9 — Deliverable docs (after everything above verifies)

### Task 18: Ghostty + VS Code keymap snippets

**Files:**
- Create: `docs/ghostty-keybinds.md`
- Create: `docs/vscode-keybindings.md`

**Interfaces:**
- Produces: copy-paste config so `Cmd+Shift+N` (file lookup) and the IntelliJ verbs work in Ghostty and match in VS Code.

- [ ] **Step 1: Write Ghostty snippet doc**

`docs/ghostty-keybinds.md` — include in `~/.config/ghostty/config`:
```
macos-option-as-alt = true
keybind = cmd+shift+n=text:\x1b[110;9u
keybind = cmd+e=text:\x1b[101;9u
```
And the matching nvim maps to add to `lua/core/keymaps.lua` behind `if not vim.g.vscode` (or a terminal-only file):
```lua
-- decode the CSI-u sequences Ghostty forwards for Cmd combos
vim.keymap.set("n", "<C-S-n>", "<cmd>Telescope find_files<cr>", { desc = "File lookup (Cmd+Shift+N)" })
```
(Document that the exact escape mapping depends on Ghostty version; the `<leader>ff` fallback always works.)

- [ ] **Step 2: Write VS Code keybindings doc**

`docs/vscode-keybindings.md` — entries mirroring IntelliJ verbs to VS Code commands (rename → `editor.action.rename`, references → `references-view.findReferences`, code action → `editor.action.quickFix`, go-to-def → `editor.action.revealDefinition`, run test → `testing.runAtCursor`), so both homes match.

- [ ] **Step 3: Commit** — `git add -A && git commit -m "docs: ghostty + vscode keybinding snippets"`

### Task 19: WALKTHROUGH.md (post-verification, reflects real behavior)

**Files:**
- Create: `WALKTHROUGH.md`

**Interfaces:**
- Consumes: the verified bindings from all prior tasks. Do NOT write until a manual smoke test in real Ghostty confirms each step.

- [ ] **Step 1: Manual smoke test in real Ghostty**

Open a sample project and confirm each flow works: open project (dashboard/`<leader>fr`), file lookup (`<leader>ff`), edit + completion (`Ctrl+Space`, arrows, Enter), reformat (`Ctrl+Alt+L`), run test (`<leader>tt`), run build (`<leader>rr`), debug breakpoint (`<leader>db`, `F8`), layout (`<leader>e`, `<leader>o`, `<C-\>`), git (`<leader>gg`, `<leader>gb`), commit/push via lazygit.

- [ ] **Step 2: Write the walkthrough**

`WALKTHROUGH.md` covering, as a numbered end-to-end story with the exact keys confirmed in Step 1:
1. Open a project (dashboard recent projects / `<leader>fr`).
2. Navigate: file lookup `<leader>ff`, grep `<leader>fg`, outline `<leader>o`, harpoon `<leader>ha`/`<leader>hh`.
3. Open buffers/tabs and cycle (`<S-l>`/`<S-h>`), file tree `<leader>e`.
4. Edit with completion (`Ctrl+Space`, arrows, Enter), multi-cursor `Ctrl+N`, surround.
5. Reformat `Ctrl+Alt+L`; fix diagnostics via `Alt+Enter`, Problems `<leader>xx`.
6. Run/test/build: `<leader>tt`, `<leader>tf`, `<leader>rr`; debug `<leader>db` + `F7/F8/Shift+F8`.
7. Layout: splits, terminal `<C-\>`, sessions `<leader>qs`.
8. Git: hunks `]c`/`[c`, blame `<leader>gb`, full UI `<leader>gg` (stage/commit/push), history `<leader>gh`.
9. First-run notes: `:Lazy sync`, `:Mason`, `:Copilot auth`, install `lazygit`/`ripgrep`/`fd` via brew.

- [ ] **Step 3: Commit** — `git add -A && git commit -m "docs: end-to-end WALKTHROUGH"`

---

## Notes for the implementer

- **Order matters** only where interfaces are consumed: Task 7 (blink) before Task 8 (LSP capabilities); Task 5 (navic) before Task 8 (navic.attach). Everything else is independent.
- **External binaries** (installed via brew, not this repo): `lazygit`, `ripgrep`, `fd`, `node` (for prettier/eslint_d), language toolchains. The config must not error when they're absent — it degrades.
- Keep `lazy-lock.json` committed after `:Lazy sync` for reproducibility.
- If a plugin's `main`/module name has changed upstream, prefer the current name from its README (use context7 docs) over what's written here.
