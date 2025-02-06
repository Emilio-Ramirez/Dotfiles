-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- See he name of the file in top righ  corner
vim.opt.winbar = "%=%m %f"

-- Use jj to escape insert mode
vim.keymap.set("i", "jj", "<ESC>", { silent = true })

-- adjust windows size wih arrows keys
vim.keymap.set("n", "<right>", "<c-w>5>", { silent = true })
vim.keymap.set("n", "<left>", "<c-w>5<", { silent = true })
vim.keymap.set("n", "<up>", "<c-w>5+", { silent = true })
vim.keymap.set("n", "<down>", "<c-w>5-", { silent = true })

local Util = require("lazyvim.util")

vim.keymap.set("n", "<C-/>", function()
  Util.terminal(nil, { border = "rounded" })
end, { desc = "Terminal (root dir )" })

-- Code Companion keymaps
vim.keymap.set(
  { "n", "v" },
  "<C-a>",
  "<cmd>CodeCompanionActions<cr>",
  { noremap = true, silent = true, desc = "Code Companion Actions" }
)
vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>a",
  "<cmd>CodeCompanionChat Toggle<cr>",
  { noremap = true, silent = true, desc = "Toggle Code Companion Chat" }
)
vim.keymap.set(
  "v",
  "ga",
  "<cmd>CodeCompanionChat Add<cr>",
  { noremap = true, silent = true, desc = "Add to Code Companion Chat" }
)

-- Command abbreviation for Code Companion
vim.cmd([[cnoreabbrev cc CodeCompanion]])
