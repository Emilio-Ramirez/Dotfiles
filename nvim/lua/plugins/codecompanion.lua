return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    strategies = {
      chat = {
        adapter = "ollama", -- Changed from ollama to anthropic
      },
      inline = {
        adapter = "ollama", -- Also set for inline assistance
      },
    },
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "your_api_key",
          },
        })
      end,
    },
    log_level = "DEBUG", -- or "TRACE"
  },
}
