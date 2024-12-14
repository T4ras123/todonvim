<div align="center">

# 📋 TodoNvim

*A minimal, blazingly fast task manager for Neovim*

</div>

## ⚡️ Why TodoNvim?

TodoNvim turns your Neovim into a powerful task management system without leaving your editor. Perfect for developers who live in their terminal.

## 🚀 Features

- 📝 Lightning-fast task management
- ✨ Intuitive keyboard controls
- 🎯 Focus mode with minimal UI
- 💾 Persistent JSON storage
- 🔄 Auto-sorting completed tasks
- 🎨 Beautiful floating window interface

## 📦 Installation

Using packer.nvim:

```lua
use {
  'T4ras123/todonvim',
  config = function()
    require('todonvim').setup({
      -- optional configuration
      window = {
        width = 50,
        border = 'rounded'
      }
    })
  end
}
```

## 🎮 Usage

Open TodoNvim:

```vim
:lua require('todonvim').open_popup()
```

Pro tip: Add this mapping to your config:

```lua
vim.keymap.set('n', '<leader>t', require('todonvim').open_popup, { noremap = true, silent = true })
```

### ⌨️ Default Keybindings

| Key | Action |
|-----|--------|
| `j/k` | Navigate tasks |
| `a` | Add new task |
| `e` | Edit selected task |
| `m` | Toggle completion |
| `D` | Delete task |
| `q` | Close window |

## ⚙️ Configuration

TodoNvim works out of the box, but you can customize it:

```lua
require('todonvim').setup({
  window = {
    width = 50,        -- popup width
    height = 'auto',   -- auto-adjusts to content
    border = 'rounded' -- or 'single', 'double', 'shadow'
  },
  highlights = {
    border = 'FloatBorder',
    selected = 'Visual',
    title = 'Title'
  },
  icons = {
    pending = '○',
    done = '✓'
  }
})
```

## 📄 Task Storage

Tasks are stored in `tasks.json` in your project root:

```json
[
  {"name": "Create awesome feature", "done": false},
  {"name": "Fix critical bug", "done": true}
]
```

## 🤝 Contributing

PRs welcome! Check out our [contribution guidelines](CONTRIBUTING.md).

## 📝 License

MIT © [Vover](LICENSE)
