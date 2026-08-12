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

-- Comment toggle (built-in `gc`). Terminal only — in VS Code, VS Code owns Cmd+/.
-- Ctrl+/ arrives as <C-_> in most terminals; <C-/> covers terminals that send it
-- literally (Ghostty w/ kitty protocol); <D-/> is Cmd+/ if Ghostty forwards Cmd.
if not vim.g.vscode then
  for _, lhs in ipairs({ "<C-_>", "<C-/>", "<D-/>" }) do
    map("n", lhs, "gcc", { remap = true, desc = "Toggle comment" })
    map("x", lhs, "gc", { remap = true, desc = "Toggle comment" })
  end

  -- Direct pane navigation (no <C-w> prefix) — the standard, seamless way.
  map("n", "<C-h>", "<C-w>h", { desc = "Go to left pane" })
  map("n", "<C-j>", "<C-w>j", { desc = "Go to lower pane" })
  map("n", "<C-k>", "<C-w>k", { desc = "Go to upper pane" })
  map("n", "<C-l>", "<C-w>l", { desc = "Go to right pane" })
  -- Same from inside a terminal: exit terminal-mode, then move
  map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left pane" })
  map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to lower pane" })
  map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to upper pane" })
  map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right pane" })

  -- Window/split layout under <leader>w (friendlier than the <C-w> prefix;
  -- shown grouped in which-key). The <C-w> defaults keep working too.
  map("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })
  map("n", "<leader>ws", "<C-w>s", { desc = "Split horizontal" })
  map("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
  map("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
  map("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
  map("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
  map("n", "<leader>wc", "<C-w>c", { desc = "Close window" })
  map("n", "<leader>wo", "<C-w>o", { desc = "Only (close others)" })
  map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })
  -- Editor groups = tab pages: create / next / prev / close
  map("n", "<leader>wt", "<cmd>tabnew<cr>", { desc = "New editor group (tab page)" })
  map("n", "<leader>wn", "gt", { remap = true, desc = "Next group" })
  map("n", "<leader>wp", "gT", { remap = true, desc = "Prev group" })

  -- Tool-window focus (VS Code/IntelliJ style): jump straight to a panel.
  map("n", "<leader>1", "<cmd>Neotree focus<cr>", { desc = "Focus file explorer" })
  map("n", "<leader>2", function()
    -- Jump to a visible terminal window in this tab page; else open one.
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
    vim.cmd("ToggleTerm")
  end, { desc = "Focus terminal" })
  -- <leader>3: back to the editor — focus a real file window (skip sidebars/
  -- terminals/panels). Prefers the window you came from, else the first file window.
  map("n", "<leader>3", function()
    local prev = vim.fn.win_getid(vim.fn.winnr("#"))
    if prev ~= 0 and vim.api.nvim_win_is_valid(prev) and vim.bo[vim.api.nvim_win_get_buf(prev)].buftype == "" then
      vim.api.nvim_set_current_win(prev)
      return
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end, { desc = "Focus editor (current file)" })
  map("n", "<leader>4", "<cmd>OverseerToggle<cr>", { desc = "Focus task runner (overseer)" })
  map("n", "<leader>5", function()
    require("dap") -- load nvim-dap first so its config has run dapui.setup()
    require("dapui").toggle()
  end, { desc = "Focus debug UI" })
  map("n", "<leader>6", "<cmd>AerialToggle<cr>", { desc = "Focus outline (aerial)" })
  map("n", "<leader>7", function() require("neotest").summary.toggle() end, { desc = "Focus tests (neotest)" })
  map("n", "<leader>8", function()
    local lib = require("diffview.lib")
    if lib.get_current_view() then
      vim.cmd("DiffviewClose")
    else
      vim.cmd("DiffviewOpen")
    end
  end, { desc = "Focus source control (diffview)" })

  -- Toggle inlay hints (inferred types / param names) globally
  map("n", "<leader>uh", function()
    local on = vim.lsp.inlay_hint.is_enabled()
    vim.lsp.inlay_hint.enable(not on)
    vim.notify("Inlay hints " .. (on and "off" or "on"), vim.log.levels.INFO)
  end, { desc = "Toggle inlay hints" })
end
