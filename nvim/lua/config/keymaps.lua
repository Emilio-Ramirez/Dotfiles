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
