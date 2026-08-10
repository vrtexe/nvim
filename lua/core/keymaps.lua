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
end
