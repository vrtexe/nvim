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
end
