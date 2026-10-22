return {
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      arg = "Leet",
      lang = "python3",
    },
  },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
  },
  {
    "preservim/nerdcommenter",
    event = "VeryLazy",
  },
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },
  -- Required for testing
  {
    "nvim-neotest/nvim-nio",
    event = "VeryLazy",
  },
  {
    "ruifm/gitlinker.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      mappings = "<leader>gy",
    },
  },
}
