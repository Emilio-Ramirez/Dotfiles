return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<Tab>",      -- Tab to accept
        next = "<C-n>",       -- Ctrl+n to get next suggestion
        prev = "<C-p>",       -- Ctrl+p to get previous suggestion
        dismiss = "<C-e>",    -- Ctrl+e to dismiss suggestion
      },
    },
    panel = { enabled = true },
    filetypes = {
      markdown = true,
      help = true,
      javascript = true,
      ["*"] = true,
    },
  },
}
