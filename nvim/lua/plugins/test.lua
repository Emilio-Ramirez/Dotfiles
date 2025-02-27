return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest", -- Add this for Vitest support
    },
    opts = function(_, opts)
      -- Add the vitest adapter to your config
      table.insert(
        opts.adapters,
        require("neotest-vitest")({
          -- Optional configuration
          vitestCommand = "npx vitest",
          -- You can also pass environment variables if needed
          env = {
            CI = true,
          },
        })
      )
    end,
  },
}
