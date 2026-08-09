# VS Code Keybindings

This document maps IntelliJ IDEA editor verbs to their native VS Code command equivalents, enabling consistent keybindings between Neovim (with IntelliJ keymap) and VS Code.

## Verb-to-Command Mapping

| IntelliJ Verb | VS Code Command | Description |
|---|---|---|
| `rename` | `editor.action.rename` | Rename symbol |
| `references` | `references-view.findReferences` | Show all references |
| `code action` | `editor.action.quickFix` | Quick fix / code action |
| `go-to-def` | `editor.action.revealDefinition` | Go to definition |
| `run test` | `testing.runAtCursor` | Run test at cursor |

## VS Code Configuration

To use these keybindings in VS Code, add entries to your `keybindings.json` file (accessible via Command Palette: "Preferences: Open Keyboard Shortcuts (JSON)") that map to these commands:

```json
[
  {
    "key": "cmd+shift+r",
    "command": "editor.action.rename",
    "when": "editorTextFocus && !editorReadonly"
  },
  {
    "key": "cmd+b",
    "command": "references-view.findReferences",
    "when": "editorTextFocus"
  },
  {
    "key": "cmd+.",
    "command": "editor.action.quickFix",
    "when": "editorTextFocus && !editorReadonly"
  },
  {
    "key": "cmd+down",
    "command": "editor.action.revealDefinition",
    "when": "editorTextFocus"
  },
  {
    "key": "cmd+shift+t",
    "command": "testing.runAtCursor",
    "when": "editorTextFocus"
  }
]
```

## Notes

- Adjust the `key` values above to match your preferred keybindings
- The `when` conditions ensure commands only execute in appropriate contexts
- This mapping allows Neovim users to maintain consistent muscle memory across both editors
