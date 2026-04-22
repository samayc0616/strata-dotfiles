-- File: ~/.config/nvim/colors/monokai_pro.lua
-- Monokai Pro theme for Neovim
-- A lightweight implementation without the plugin overhead

-- Clear existing highlights
vim.cmd('hi clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end
vim.o.termguicolors = true
vim.g.colors_name = "monokai_pro"

-- Color Palette
local colors = {
  -- Pro filter colors
  bg          = "#2d2a2e",
  fg          = "#fcfcfa",
  red         = "#ff6188",
  orange      = "#fc9867",
  yellow      = "#ffd866",
  green       = "#a9dc76",
  blue        = "#78dce8",
  purple      = "#ab9df2",
  
  -- UI colors
  dark_bg     = "#221f22",
  light_bg    = "#403e41",
  gutter_fg   = "#727072",
  comment     = "#727072",
  selection   = "#444267",
  line_active = "#3a3a3c",
  
  -- Additional UI colors
  border      = "#5b595c",
  highlight   = "#ffd866",
  error       = "#ff6188",
  warning     = "#fc9867",
  info        = "#78dce8",
  hint        = "#a9dc76",
}

-- Helper function for highlight definition
local function hi(group, opts)
  local guifg = opts.fg or "NONE"
  local guibg = opts.bg or "NONE"
  local guisp = opts.sp or ""
  local gui = opts.style or "NONE"
  local blend = opts.blend or 0
  
  vim.cmd(string.format(
    "highlight %s guifg=%s guibg=%s gui=%s guisp=%s blend=%d",
    group, guifg, guibg, gui, guisp, blend
  ))
end

-- Editor UI
hi("Normal", { fg = colors.fg, bg = colors.bg })
hi("LineNr", { fg = colors.gutter_fg, bg = colors.bg })
hi("CursorLine", { bg = colors.line_active })
hi("CursorLineNr", { fg = colors.fg, bg = colors.line_active })
hi("SignColumn", { bg = colors.bg })
hi("ColorColumn", { bg = colors.light_bg })
hi("Cursor", { fg = colors.bg, bg = colors.fg })
hi("CursorColumn", { bg = colors.line_active })
hi("Visual", { bg = colors.selection })
hi("VisualNOS", { bg = colors.selection })
hi("Search", { fg = colors.bg, bg = colors.yellow })
hi("IncSearch", { fg = colors.bg, bg = colors.orange })
hi("WildMenu", { fg = colors.fg, bg = colors.selection })
hi("StatusLine", { fg = colors.fg, bg = colors.light_bg })
hi("StatusLineNC", { fg = colors.gutter_fg, bg = colors.dark_bg })
hi("VertSplit", { fg = colors.border, bg = colors.bg })
hi("TabLine", { fg = colors.gutter_fg, bg = colors.dark_bg })
hi("TabLineFill", { fg = colors.gutter_fg, bg = colors.dark_bg })
hi("TabLineSel", { fg = colors.fg, bg = colors.bg })
hi("Title", { fg = colors.yellow })
hi("SpecialKey", { fg = colors.blue })
hi("NonText", { fg = colors.gutter_fg })
hi("EndOfBuffer", { fg = colors.gutter_fg })
hi("Folded", { fg = colors.gutter_fg, bg = colors.dark_bg })
hi("FoldColumn", { fg = colors.gutter_fg, bg = colors.dark_bg })
hi("Conceal", { fg = colors.gutter_fg })
hi("Directory", { fg = colors.blue })
hi("MatchParen", { bg = colors.selection, style = "bold" })

-- Pmenu
hi("Pmenu", { fg = colors.fg, bg = colors.dark_bg })
hi("PmenuSel", { fg = colors.fg, bg = colors.selection })
hi("PmenuSbar", { bg = colors.dark_bg })
hi("PmenuThumb", { bg = colors.gutter_fg })

-- Diff
hi("DiffAdd", { fg = colors.green, bg = colors.dark_bg })
hi("DiffChange", { fg = colors.yellow, bg = colors.dark_bg })
hi("DiffDelete", { fg = colors.red, bg = colors.dark_bg })
hi("DiffText", { fg = colors.blue, bg = colors.dark_bg })

-- Messages
hi("ErrorMsg", { fg = colors.error })
hi("WarningMsg", { fg = colors.warning })
hi("MoreMsg", { fg = colors.info })
hi("Question", { fg = colors.green })

-- Diagnostics
hi("DiagnosticError", { fg = colors.error })
hi("DiagnosticWarn", { fg = colors.warning })
hi("DiagnosticInfo", { fg = colors.info })
hi("DiagnosticHint", { fg = colors.hint })
hi("DiagnosticUnderlineError", { sp = colors.error, style = "undercurl" })
hi("DiagnosticUnderlineWarn", { sp = colors.warning, style = "undercurl" })
hi("DiagnosticUnderlineInfo", { sp = colors.info, style = "undercurl" })
hi("DiagnosticUnderlineHint", { sp = colors.hint, style = "undercurl" })

-- Syntax
hi("Comment", { fg = colors.comment, style = "italic" })
hi("Constant", { fg = colors.purple })
hi("String", { fg = colors.yellow })
hi("Character", { fg = colors.yellow })
hi("Number", { fg = colors.purple })
hi("Boolean", { fg = colors.purple })
hi("Float", { fg = colors.purple })
hi("Identifier", { fg = colors.fg })
hi("Function", { fg = colors.green })
hi("Statement", { fg = colors.red })
hi("Conditional", { fg = colors.red, style = "italic" })
hi("Repeat", { fg = colors.red, style = "italic" })
hi("Label", { fg = colors.red, style = "italic" })
hi("Operator", { fg = colors.red })
hi("Keyword", { fg = colors.red, style = "italic" })
hi("Exception", { fg = colors.red, style = "italic" })
hi("PreProc", { fg = colors.red })
hi("Include", { fg = colors.red, style = "italic" })
hi("Define", { fg = colors.red })
hi("Macro", { fg = colors.red })
hi("PreCondit", { fg = colors.red })
hi("Type", { fg = colors.blue, style = "italic" })
hi("StorageClass", { fg = colors.red, style = "italic" })
hi("Structure", { fg = colors.red, style = "italic" })
hi("Typedef", { fg = colors.blue, style = "italic" })
hi("Special", { fg = colors.orange })
hi("SpecialChar", { fg = colors.orange })
hi("Tag", { fg = colors.red })
hi("Delimiter", { fg = colors.fg })
hi("SpecialComment", { fg = colors.comment, style = "italic" })
hi("Debug", { fg = colors.red })
hi("Underlined", { fg = colors.blue, style = "underline" })
hi("Error", { fg = colors.error })
hi("Todo", { fg = colors.yellow, bg = colors.bg, style = "bold,italic" })

-- LSP
hi("LspReferenceText", { bg = colors.selection })
hi("LspReferenceRead", { bg = colors.selection })
hi("LspReferenceWrite", { bg = colors.selection })

-- Git highlighting
hi("gitcommitComment", { fg = colors.comment, style = "italic" })
hi("gitcommitUntracked", { fg = colors.comment, style = "italic" })
hi("gitcommitDiscarded", { fg = colors.comment, style = "italic" })
hi("gitcommitSelected", { fg = colors.comment, style = "italic" })
hi("gitcommitHeader", { fg = colors.red })
hi("gitcommitSelectedType", { fg = colors.blue })
hi("gitcommitUnmergedType", { fg = colors.blue })
hi("gitcommitDiscardedType", { fg = colors.blue })
hi("gitcommitBranch", { fg = colors.purple, style = "bold" })
hi("gitcommitUntrackedFile", { fg = colors.yellow })
hi("gitcommitUnmergedFile", { fg = colors.warning, style = "bold" })
hi("gitcommitDiscardedFile", { fg = colors.error, style = "bold" })
hi("gitcommitSelectedFile", { fg = colors.green, style = "bold" })

-- gitgutter/gitsigns
hi("GitSignsAdd", { fg = colors.green })
hi("GitSignsChange", { fg = colors.yellow })
hi("GitSignsDelete", { fg = colors.red })

-- Telescope
hi("TelescopeSelection", { fg = colors.fg, bg = colors.selection })
hi("TelescopeMatching", { fg = colors.yellow, style = "bold" })
hi("TelescopeBorder", { fg = colors.border })

-- NvimTree
hi("NvimTreeNormal", { fg = colors.fg, bg = colors.dark_bg })
hi("NvimTreeFolderName", { fg = colors.blue })
hi("NvimTreeRootFolder", { fg = colors.red })
hi("NvimTreeFolderIcon", { fg = colors.blue })
hi("NvimTreeEmptyFolderName", { fg = colors.gutter_fg })
hi("NvimTreeOpenedFolderName", { fg = colors.blue })
hi("NvimTreeGitDirty", { fg = colors.warning })
hi("NvimTreeGitNew", { fg = colors.green })
hi("NvimTreeGitDeleted", { fg = colors.red })
hi("NvimTreeSpecialFile", { fg = colors.yellow, style = "underline" })
hi("NvimTreeIndentMarker", { fg = colors.gutter_fg })

-- WhichKey
hi("WhichKey", { fg = colors.yellow })
hi("WhichKeyGroup", { fg = colors.blue })
hi("WhichKeyDesc", { fg = colors.red })
hi("WhichKeySeperator", { fg = colors.gutter_fg })

-- TreeSitter
hi("@punctuation.bracket", { fg = colors.fg })
hi("@punctuation.delimiter", { fg = colors.fg })
hi("@tag", { fg = colors.red })
hi("@tag.attribute", { fg = colors.green, style = "italic" })
hi("@tag.delimiter", { fg = colors.fg })
hi("@function", { fg = colors.green })
hi("@function.builtin", { fg = colors.green })
hi("@variable", { fg = colors.fg })
hi("@variable.builtin", { fg = colors.fg })
hi("@keyword", { fg = colors.red, style = "italic" })
hi("@property", { fg = colors.fg })
hi("@constructor", { fg = colors.blue })
hi("@conditional", { fg = colors.red, style = "italic" })
hi("@repeat", { fg = colors.red, style = "italic" })
hi("@exception", { fg = colors.red, style = "italic" })
hi("@attribute", { fg = colors.blue })
hi("@include", { fg = colors.red, style = "italic" })
hi("@type", { fg = colors.blue, style = "italic" })

-- Terminal colors
vim.g.terminal_color_0 = colors.dark_bg    -- black
vim.g.terminal_color_1 = colors.red        -- red
vim.g.terminal_color_2 = colors.green      -- green
vim.g.terminal_color_3 = colors.yellow     -- yellow
vim.g.terminal_color_4 = colors.blue       -- blue
vim.g.terminal_color_5 = colors.purple     -- magenta
vim.g.terminal_color_6 = colors.blue       -- cyan
vim.g.terminal_color_7 = colors.fg         -- white
vim.g.terminal_color_8 = colors.gutter_fg  -- bright black
vim.g.terminal_color_9 = colors.red        -- bright red
vim.g.terminal_color_10 = colors.green     -- bright green
vim.g.terminal_color_11 = colors.yellow    -- bright yellow
vim.g.terminal_color_12 = colors.blue      -- bright blue
vim.g.terminal_color_13 = colors.purple    -- bright magenta
vim.g.terminal_color_14 = colors.blue      -- bright cyan
vim.g.terminal_color_15 = colors.fg        -- bright white

-- Return the color palette
return colors
