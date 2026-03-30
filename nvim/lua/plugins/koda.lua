return {
  -- add koda colorscheme
  {
    "oskarnurm/koda.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      overrides = function(colors)
        return {
          -- Transparent backgrounds for sidebars
          NeoTreeNormal = { bg = "NONE" },
          NeoTreeNormalNC = { bg = "NONE" },
          NeoTreeEndOfBuffer = { bg = "NONE" },
          NeoTreeWinSeparator = { bg = "NONE" },
          -- Float windows
          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          -- Status line
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
        }
      end,
    },
  },

  -- Configure LazyVim to load koda
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "koda",
    },
  },
}
