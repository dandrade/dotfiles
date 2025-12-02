return {
  -- add kanagawa
  {
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
      theme = "wave",
      background = {
        dark = "wave",
        light = "lotus",
      },
      overrides = function(colors)
        return {
          -- Transparent backgrounds for sidebars
          NeoTreeNormal = { bg = "NONE" },
          NeoTreeNormalNC = { bg = "NONE" },
          NeoTreeEndOfBuffer = { bg = "NONE" },
          NeoTreeWinSeparator = { bg = "NONE", fg = colors.palette.sumiInk4 },
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

  -- Configure LazyVim to load kanagawa
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-wave",
    },
  },
}
