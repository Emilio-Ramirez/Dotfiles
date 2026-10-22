# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for development tools and utilities. The repository manages configurations for multiple tools across macOS:

- **Neovim**: Full IDE-like setup using LazyVim with plugins
- **Fish Shell**: Command-line shell with plugins and custom functions
- **Development Tools**: Git, SSH, GitHub CLI, and other utilities
- **System Tools**: macOS window managers (Yabai), terminal multiplexers, and UI tools

### Directory Structure

Key directories in this repository:

- `nvim/` - Neovim configuration (LazyVim-based)
  - `lua/config/` - Core settings (keymaps, options, autocmds, lazy.lua)
  - `lua/plugins/` - Plugin specifications and configurations
  - `init.lua` - Entry point
- `fish/` - Fish shell configuration and functions
- `Claude/` - Claude desktop integration (MCP servers config)
- `claude-code/` - Claude Code CLI configuration (mcp.json)
- `git/` - Git configuration
- Other directories: yabai, skhd, iterm2, llm, spicetify, etc.

### Git Repository Information

- **Remote**: `git@github.com-personal:Emilio-Ramirez/Dotfiles.git` (personal GitHub account)
- **Branch**: main
- **Type**: Dotfiles repository (symlinked to `~/.config`)

**Important**: Use SSH alias `github.com-personal` for all git operations (see global CLAUDE.md for SSH configuration details)

## Neovim Configuration

### Architecture

The Neovim setup is built on **LazyVim**, a modern Neovim configuration framework that provides:
- Lazy plugin loading for fast startup
- Preconfigured LSP, formatting, and debugging
- Multiple language support plugins
- Organized plugin structure using `lazy.nvim`

### Plugin Organization

**`lua/config/lazy.lua`** - Core configuration that:
1. Bootstraps `lazy.nvim` plugin manager
2. Imports LazyVim base plugins and extras
3. Enables language-specific LSP support for: TypeScript, Python, JSON, Markdown, Tailwind, C# (OmniSharp)
4. Includes formatting (Prettier) and debugging (DAP) extras
5. Disables unused runtime plugins for performance

**`lua/plugins/`** - Custom plugin specifications:
- `lazyvim.lua` - LazyVim theme configuration (using Catppuccin colorscheme)
- `catpuccin.lua` - Catppuccin theme setup
- `copilot.lua` - GitHub Copilot integration with auto-trigger and keybindings
- `codecompanion.lua` - CodeCompanion integration for chat-based AI assistance
- `simple_plugins.lua` - Additional plugins (LeetCode, Git blame, vim-surround, etc.)
- `terraform.lua` - Terraform language support
- `prisma.lua` - Prisma ORM support
- `test.lua` - Testing framework integration

### Key Keybindings

**AI/Code Completion** (defined in `lua/config/keymaps.lua`):
- `Ctrl+a` (normal/visual) - Open CodeCompanion Actions menu
- `\a` (normal/visual) - Toggle CodeCompanion Chat
- `ga` (visual) - Add selection to CodeCompanion Chat
- `Tab` - Accept GitHub Copilot suggestion
- `Ctrl+n/p` - Cycle through Copilot suggestions
- `Ctrl+e` - Dismiss Copilot suggestion
- `:cc` - Shortcut for CodeCompanion prompt

**Window Management** (defined in `lua/config/keymaps.lua`):
- Arrow keys - Resize windows (5 lines/columns per press)
- `jj` (insert) - Exit insert mode
- `Ctrl+/` (normal) - Open terminal in floating window

### Available Language Support

The LazyVim extras provide complete support for:
- **TypeScript/JavaScript** - Full LSP, formatting, debugging
- **Python** - LSP, formatting, debugging
- **JSON** - Schema validation and formatting
- **Markdown** - Markdown preview and formatting
- **Tailwind CSS** - Class name completion and intellisense
- **C# / .NET** - OmniSharp LSP support
- **Terraform** - HCL syntax and LSP (via custom terraform.lua)
- **Prisma** - ORM-specific syntax and formatting

### Plugin Management

**Updating plugins:**
```bash
# Inside Neovim, use the Lazy.nvim built-in command
:Lazy
```

Then navigate with arrow keys and press `u` to update, `x` to clean unused, `I` to install.

**Checking for plugin updates:**
The `checker` option in `lazy.lua` is enabled, so Lazy will automatically notify about updates on startup.

### Common Development Commands

**Open Neovim:**
```bash
nvim
# or for a specific file
nvim src/index.ts
```

**Running tests from Neovim:**
- Use the nvim-neotest integration (available in test.lua)
- Test framework varies by language (Jest for TypeScript, pytest for Python)
- Configuration provided by LazyVim extras

## Fish Shell Configuration

### Structure

- `config.fish` - Main shell configuration
- `completions/` - Auto-completion definitions for various tools
- `functions/` - Custom shell functions (tide prompt functions, nvm helpers, etc.)

### Key Features

- **Tide Prompt** - Modern, fast prompt with git info, docker status, and language indicators
- **Fisher** - Plugin manager for Fish
- **NVM Integration** - Node version manager integration
- **Git Integration** - Git status in prompt

### Sourcing Fish Configuration

Fish automatically sources `~/.config/fish/config.fish` on startup. Configurations in this repository use symlinks from `~/.config/fish` to the repo.

## Development Workflow

### Adding New Plugins to Neovim

1. Create a new file in `nvim/lua/plugins/` with a meaningful name (e.g., `myfeature.lua`)
2. Return a plugin specification table using Lazy.nvim syntax:
   ```lua
   return {
     "plugin-author/plugin-name",
     event = "VeryLazy",  -- or other lazy-loading events
     opts = { ... }        -- plugin options
   }
   ```
3. The plugin will be automatically loaded by Lazy.nvim (imported in `lazy.lua`)

### Modifying Keybindings

- Add new keybindings in `nvim/lua/config/keymaps.lua`
- Use `vim.keymap.set()` with proper mode specification (n, v, i, etc.)
- Add descriptive `desc` parameter for which-key integration

### Testing Neovim Configuration

After making changes:
```bash
# Start Neovim fresh (clears cache)
nvim

# Check for errors in startup
# Look at Messages with :messages
```

If Neovim fails to start, the issue is usually in the plugin specs or lazy.lua syntax.

## Important Security Notes

**CRITICAL - Exposed Credentials:**

The file `nvim/lua/plugins/codecompanion.lua` contains a hardcoded Anthropic API key. This is a security vulnerability and should be:
1. Revoked immediately at the Anthropic Console
2. Moved to environment variables (e.g., `ANTHROPIC_API_KEY`)
3. Added to `.gitignore`

The `.gitignore` already excludes `codecompanion.lua`, but the file is currently tracked in git history. Consider using `git filter-branch` or BFG to remove it from history.

**Safe Configuration Pattern:**

Instead of hardcoding API keys, use environment variables:
```lua
env = {
  api_key = os.getenv("ANTHROPIC_API_KEY"),
}
```

Then set in shell configuration or `.env` file (never commit .env).

## Helpful Patterns in This Codebase

### LazyVim Plugin Spec Format

All custom plugins follow this structure:
```lua
return {
  "author/plugin",
  event = "VeryLazy",           -- Lazy-load trigger
  dependencies = { ... },        -- Required plugins
  opts = { ... },                -- Plugin configuration
  cmd = "CommandName",           -- Load on command
  keys = { ... },                -- Load on keypress
  config = function(opts) ... end -- Custom setup
}
```

### Conditional Plugin Loading

Plugins can be lazy-loaded by:
- `event` - On specific events (VeryLazy, BufReadPost, etc.)
- `cmd` - When a specific command is used
- `keys` - When a keybinding is pressed
- Dependencies load before the requiring plugin

### Configuration Extras Pattern

LazyVim extras (like TypeScript, Python, etc.) are imported in `lazy.lua`:
```lua
{ import = "lazyvim.plugins.extras.lang.typescript" }
```

This automatically includes LSP, debugging, formatting, and testing for that language.

## Common Tasks

### Updating All Dotfiles to Latest Versions

```bash
cd /Users/emilio/.config
git pull origin main
git push origin main
```

### Checking Git Status

```bash
cd /Users/emilio/.config
git status
git diff
```

### Verifying SSH Configuration

Before pushing changes, verify SSH connectivity:
```bash
ssh -T git@github.com-personal
# Should output: Hi Emilio-Ramirez!
```

### Symlink Management

Dotfiles are typically symlinked from the home directory:
```bash
# Example for Neovim
ln -s /Users/emilio/.config/nvim ~/.config/nvim

# Example for Fish
ln -s /Users/emilio/.config/fish ~/.config/fish
```

## Notes on File Modifications

- Changes to `nvim/lua/config/` affect Neovim immediately on next restart
- Changes to `fish/` configuration require `source ~/.config/fish/config.fish` or a new shell
- Plugin changes require restarting Neovim and running `:Lazy` if needed
- Always commit configuration changes with clear messages documenting what changed

## References

- [LazyVim Documentation](https://www.lazyvim.org/)
- [Lazy.nvim Plugin Manager](https://github.com/folke/lazy.nvim)
- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Catppuccin Theme](https://github.com/catppuccin/nvim)
