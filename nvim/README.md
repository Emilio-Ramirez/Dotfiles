# 💤 LazyVim

## GitHub Copilot Configuration

### Initial Setup

- Run `:Copilot auth` in Neovim to authenticate with GitHub
- Configuration file: [copilot.lua](./lua/plugins/copilot.lua)
- Automatically triggered on `BufReadPost` and `BufNewFile` events

### Key Features

- Auto-trigger enabled with 75ms debounce
- Enabled for all filetypes including markdown and help
- Full integration with LazyVim

### Keybindings

- `Tab` - Accept suggestion
- `Ctrl+n` - Next suggestion
- `Ctrl+p` - Previous suggestion
- `Ctrl+e` - Dismiss suggestion

## Code Companion Integration

### Available Backends

1. **GitHub Copilot**

   - Uses standard Copilot authentication
   - No additional configuration needed

2. **Anthropic Claude**

   - Requires API key from [Anthropic Console](https://console.anthropic.com/settings/billing)
   - Configuration in [codecompanion.lua](./lua/plugins/codecompanion.lua)

3. **Deepseek (via Ollama)**
   - Installation: `brew cask install ollama`
   - Model setup: `ollama run deepseek-coder-v2:16b`
   - Verify running status: `ollama ps`

### Keybindings

- `Ctrl-a` (normal/visual mode) - CodeCompanionActions
- `\a` (normal/visual mode) - Toggle CodeCompanionChat
- `ga` (visual mode) - Add to CodeCompanionChat
- Command `:cc` - Shortcut for CodeCompanion prompt

### Model Details (Deepseek)

- Base model: DeepSeek-Coder-V2-Instruct
- Size: ~10.36GB
- Context length: 128k tokens
- Quantization: Q4_K_M
- Framework: llama.cpp
