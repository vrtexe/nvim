-- Universal, idiom-neutral bindings present in ALL modes (spec §5).
-- Personality verbs (goto-def, rename, find, etc.) live in the overlays.
return {
  name = "base",
  maps = {
    -- Pane navigation (no <C-w> prefix), normal + terminal
    { "n", "<C-h>", "<C-w>h", "Go to left pane" },
    { "n", "<C-j>", "<C-w>j", "Go to lower pane" },
    { "n", "<C-k>", "<C-w>k", "Go to upper pane" },
    { "n", "<C-l>", "<C-w>l", "Go to right pane" },
    { "t", "<C-h>", "<C-\\><C-n><C-w>h", "Go to left pane" },
    { "t", "<C-j>", "<C-\\><C-n><C-w>j", "Go to lower pane" },
    { "t", "<C-k>", "<C-\\><C-n><C-w>k", "Go to upper pane" },
    { "t", "<C-l>", "<C-\\><C-n><C-w>l", "Go to right pane" },

    -- System clipboard reflexes (don't shadow vim motions)
    { "v", "<C-c>", '"+y', "Copy to system clipboard" },
    { "i", "<C-v>", "<C-r>+", "Paste from system clipboard" },
    { "v", "<C-v>", '"+p', "Paste over selection" },

    -- Clear search highlight
    { "n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight" },

    -- Save
    { "n", "<C-s>", "<cmd>silent! write<cr>", "Save file" },
    { "i", "<C-s>", "<C-o><cmd>silent! write<cr>", "Save file" },

    -- Move lines
    { "n", "<A-Down>", "<cmd>m .+1<cr>==", "Move line down" },
    { "n", "<A-Up>", "<cmd>m .-2<cr>==", "Move line up" },
    { "v", "<A-Down>", ":m '>+1<cr>gv=gv", "Move selection down" },
    { "v", "<A-Up>", ":m '<-2<cr>gv=gv", "Move selection up" },

    -- Buffer cycle
    { "n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
    { "n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Prev buffer" },

    -- Terminal (toggleterm)
    { { "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<cr>", "Toggle terminal" },
    { { "n", "t" }, "<M-t>", "<cmd>ToggleTerm direction=float<cr>", "Float terminal" },
    { { "n", "t" }, "<M-1>", "<cmd>1ToggleTerm direction=horizontal<cr>", "Terminal 1" },
    { { "n", "t" }, "<M-2>", "<cmd>2ToggleTerm direction=horizontal<cr>", "Terminal 2" },
    { { "n", "t" }, "<M-3>", "<cmd>3ToggleTerm direction=horizontal<cr>", "Terminal 3" },
    { { "n", "t" }, "<M-F12>", "<cmd>ToggleTerm<cr>", "Terminal (Option+F12)" },

    -- Flash jump
    { { "n", "x", "o" }, "s", function() require("flash").jump() end, "Flash jump" },
    { { "n", "x", "o" }, "S", function() require("flash").treesitter() end, "Flash treesitter" },

    -- Window / split management (<leader>w tree)
    { "n", "<leader>wv", "<C-w>v", "Split vertical" },
    { "n", "<leader>ws", "<C-w>s", "Split horizontal" },
    { "n", "<leader>wh", "<C-w>h", "Go to left window" },
    { "n", "<leader>wj", "<C-w>j", "Go to lower window" },
    { "n", "<leader>wk", "<C-w>k", "Go to upper window" },
    { "n", "<leader>wl", "<C-w>l", "Go to right window" },
    { "n", "<leader>wc", "<C-w>c", "Close window" },
    { "n", "<leader>wo", "<C-w>o", "Only (close others)" },
    { "n", "<leader>w=", "<C-w>=", "Equalize windows" },
    { "n", "<leader>wt", "<cmd>tabnew<cr>", "New editor group (tab)" },
    { "n", "<leader>wn", "gt", "Next group" },
    { "n", "<leader>wp", "gT", "Prev group" },

    -- UI toggles (<leader>u tree)
    { "n", "<leader>ut", "<cmd>ThemeToggle<cr>", "Toggle theme (dark/light)" },
    {
      "n",
      "<leader>uh",
      function()
        local on = vim.lsp.inlay_hint.is_enabled()
        vim.lsp.inlay_hint.enable(not on)
        vim.notify("Inlay hints " .. (on and "off" or "on"), vim.log.levels.INFO)
      end,
      "Toggle inlay hints",
    },
    { "n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", "Toggle markdown render" },
    { "n", "<leader>un", function() require("snacks").notifier.hide() end, "Dismiss notifications" },
    { "n", "<leader>nh", function() require("snacks").notifier.show_history() end, "Notification history" },

    -- Session (<leader>q tree)
    { "n", "<leader>qs", function() require("persistence").load() end, "Restore session (cwd)" },
    { "n", "<leader>ql", function() require("persistence").load({ last = true }) end, "Restore last session" },
    { "n", "<leader>qd", function() require("persistence").stop() end, "Don't save session" },

    -- Comment reflexes for terminals that send Ctrl+/ variants (native gcc/gc stay)
    { "n", "<C-_>", "gcc", "Toggle comment", opts = { remap = true } },
    { "x", "<C-_>", "gc", "Toggle comment", opts = { remap = true } },
    { "n", "<D-/>", "gcc", "Toggle comment", opts = { remap = true } },
    { "x", "<D-/>", "gc", "Toggle comment", opts = { remap = true } },
  },
  lsp = {},
  groups = {
    { "<leader>w", group = "window" },
    { "<leader>u", group = "ui" },
    { "<leader>q", group = "session/quit" },
    { "<leader>n", group = "notifications" },
  },
}
