return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      -- brighter text so it stays readable on a transparent background
      on_colors = function(c)
        c.fg = "#ffffff"
        c.fg_dark = "#e6e9f5"
        c.fg_gutter = "#8a93c4"
        c.comment = "#9aa5ce"
        c.dark3 = "#9aa5ce"
        c.dark5 = "#c0caf5"
      end,
    },
  },
}
