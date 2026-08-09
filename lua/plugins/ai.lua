return {
  { "zbirenbaum/copilot.lua",
    enabled = false,  -- fully disabled: won't load, no keychain/auth prompt.
                      -- To re-enable Copilot: set enabled = true (and run :Copilot auth).
    cmd = "Copilot", event = "InsertEnter",
    opts = {
      -- Copilot inline completions disabled for now.
      -- To re-enable: set suggestion.enabled = true and auto_trigger = true.
      suggestion = { enabled = false, auto_trigger = false,
        keymap = { accept = "<C-l>", next = "<C-]>", dismiss = "<C-e>" } },
      panel = { enabled = false },
    } },
}
