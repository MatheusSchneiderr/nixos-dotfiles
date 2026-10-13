-- ported from the actual Visual Studio IDE dark theme, via
-- https://github.com/nikeee/visual-studio-dark (Sublime Text port)
---@type Base46Table
local M = {}

M.base_30 = {
  white = "#DCDCDC",
  black = "#1E1E1E",
  darker_black = "#181818",
  black2 = "#252526",
  one_bg = "#252526",
  one_bg2 = "#2D2D30",
  one_bg3 = "#333337",
  grey = "#6A6A6A",
  grey_fg = "#65A253",
  grey_fg2 = "#808080",
  light_grey = "#9B9B9B",
  red = "#FF3333",
  baby_pink = "#D09F88",
  pink = "#D2A4DB",
  line = "#3E3E42",
  green = "#65A253",
  vibrant_green = "#A6E22E",
  nord_blue = "#5E9BD0",
  blue = "#569CD6",
  yellow = "#DCDBAD",
  sun = "#D7BA7D",
  purple = "#D2A4DB",
  dark_purple = "#9B72CB",
  teal = "#68C5B1",
  orange = "#D09F88",
  cyan = "#A3DADB",
  statusline_bg = "#181818",
  lightbg = "#2D2D30",
  pmenu_bg = "#D2A4DB",
  folder_bg = "#569CD6",
}

M.base_16 = {
  base00 = "#1E1E1E",
  base01 = "#252526",
  base02 = "#2D2D30",
  base03 = "#3E3E42",
  base04 = "#9B9B9B",
  base05 = "#DCDCDC",
  base06 = "#D4D4D4",
  base07 = "#FFFFFF",
  base08 = "#5E9BD0",
  base09 = "#B9CDAB",
  base0A = "#68C5B1",
  base0B = "#D09F88",
  base0C = "#A3DADB",
  base0D = "#DCDBAD",
  base0E = "#D2A4DB",
  base0F = "#649BCF",
}

M.polish_hl = {
  treesitter = {
    ["@keyword"] = { fg = M.base_30.blue },
    ["@keyword.modifier"] = { fg = M.base_30.blue },
    ["@keyword.type"] = { fg = M.base_30.blue },
    ["@keyword.import"] = { fg = M.base_30.blue },
    ["@keyword.conditional"] = { fg = M.base_30.purple },
    ["@keyword.repeat"] = { fg = M.base_30.purple },
    ["@keyword.return"] = { fg = M.base_30.purple },
    ["@keyword.exception"] = { fg = M.base_30.purple },
    ["@keyword.operator"] = { fg = M.base_30.purple },
    ["@type"] = { fg = M.base_30.teal },
    ["@type.builtin"] = { fg = M.base_30.nord_blue },
    ["@constant.builtin"] = { fg = M.base_30.blue },
    ["@constructor"] = { fg = M.base_30.teal },
    ["@function"] = { fg = M.base_30.teal },
    ["@function.call"] = { fg = M.base_30.yellow },
    ["@function.builtin"] = { fg = M.base_30.teal },
    ["@function.method"] = { fg = M.base_30.teal },
    ["@function.method.call"] = { fg = M.base_30.yellow },
    ["@string"] = { fg = M.base_30.orange },
    ["@number"] = { fg = "#B9CDAB" },
    ["@comment"] = { fg = M.base_30.grey_fg, italic = true },
    ["@comment.documentation"] = { fg = "#608B4E" },
    ["@variable.parameter"] = { fg = M.base_30.cyan },
    ["@property"] = { fg = M.base_30.white },
    ["@namespace"] = { fg = M.base_30.teal },
  },

  nvdash = {
    NvDashAscii = { fg = M.base_30.purple, bg = M.base_30.black },
  },

  telescope = {
    TelescopeMatching = { fg = M.base_30.purple, bg = M.base_30.one_bg2 },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "vscode_dark")

return M
