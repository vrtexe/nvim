return {
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter",
    opts = {
      -- Copilot inline completions disabled for now.
      -- To re-enable: set suggestion.enabled = true and auto_trigger = true.
      suggestion = { enabled = false, auto_trigger = false,
        keymap = { accept = "<C-l>", next = "<C-]>", dismiss = "<C-e>" } },
      panel = { enabled = false },
    } },
}
