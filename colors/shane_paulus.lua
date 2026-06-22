-- Shane Paulus Theme for Neovim
-- Converted from ~/.config/JetBrains/IntelliJIdea2025.3/colors/Shane_Paulus_Theme.icls
-- Original: dark theme, custom palette based on Monokai-inspired colors

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "shane_paulus"
vim.o.background  = "dark"

local c = {
  -- Base
  bg        = "#222222",  -- TEXT.BACKGROUND (editor)
  bg_float  = "#272822",  -- CONSOLE_BACKGROUND (floats, popups, terminal)
  bg_gutter = "#26292B",  -- GUTTER_BACKGROUND (sign column, line numbers)
  bg_line   = "#3C3F41",  -- CARET_ROW_COLOR (cursor line)
  bg_sel    = "#4B6EAE",  -- SELECTION_BACKGROUND
  fg_sel    = "#999697",  -- SELECTION_FOREGROUND
  fg        = "#cfbfad",  -- DEFAULT_IDENTIFIER / main code text
  fg_text   = "#f7c070",  -- TEXT foreground (plain prose / active tab)
  fg_dim    = "#808080",  -- NOT_USED_ELEMENT (dimmed / unused)

  -- Syntax
  comment   = "#ffffff",  -- DEFAULT_LINE_COMMENT (white — intentional)
  keyword   = "#ff007f",  -- DEFAULT_KEYWORD / JAVA_KEYWORD
  string    = "#ece47e",  -- DEFAULT_STRING
  number    = "#c48cff",  -- DEFAULT_NUMBER
  func      = "#a7ec21",  -- DEFAULT_FUNCTION_DECLARATION
  type_     = "#52e3f6",  -- CLASS_NAME / DEFAULT_CLASS_NAME
  param     = "#20c9fb",  -- PARAMETER_ATTRIBUTES
  constant  = "#8380fe",  -- DEFAULT_CONSTANT
  operator  = "#ff007f",  -- DEFAULT_OPERATION_SIGN (same as keyword)
  bracket   = "#f9faf4",  -- DEFAULT_BRACKETS / DEFAULT_PARENTHS
  doc_tag   = "#d9e577",  -- JAVA_DOC_TAG
  property  = "#9876aa",  -- Instance property reference

  -- Line numbers / gutter
  ln_num    = "#cfbfad",  -- LINE_NUMBERS_COLOR

  -- Cursor
  caret     = "#F1F1F1",

  -- Diagnostics
  error_fg  = "#bc3f3c",  -- ERRORS_ATTRIBUTES
  warn_fg   = "#f49810",  -- GENERIC_SERVER_ERROR_OR_WARNING
  info_fg   = "#aeae80",  -- INFO_ATTRIBUTES
  hint_fg   = "#aeae80",

  -- Diff / Git
  diff_add  = "#294436",  -- DIFF_INSERTED.BACKGROUND
  diff_del  = "#484a4a",  -- DIFF_DELETED.BACKGROUND
  diff_mod  = "#385570",  -- DIFF_MODIFIED.BACKGROUND
  git_add   = "#629755",  -- FILESTATUS_ADDED
  git_mod   = "#6897BB",  -- FILESTATUS_MODIFIED
  git_del   = "#6C6C6C",  -- FILESTATUS_DELETED

  -- Special
  match_br  = "#ff8647",  -- MATCHED_BRACE_ATTRIBUTES
  bg_break  = "#3a2323",  -- BREAKPOINT_ATTRIBUTES
  bg_exec   = "#2d6099",  -- EXECUTIONPOINT_ATTRIBUTES
  todo      = "#a8c023",  -- TODO_DEFAULT_ATTRIBUTES
  bad_char  = "#ff0000",  -- BAD_CHARACTER
  folded_bg = "#1e5c7a",  -- approximated from FOLDED_TEXT
  folded_fg = "#808080",
  indent    = "#2D3032",  -- INDENT_GUIDE
  indent_sel = "#FBFDE3", -- SELECTED_INDENT_GUIDE
}

local function hi(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

-- ── Base editor ──────────────────────────────────────────────────────────────
hi("Normal",           { fg = c.fg,      bg = c.bg })
hi("NormalNC",         { fg = c.fg,      bg = c.bg })
hi("NormalFloat",      { fg = c.fg,      bg = c.bg_float })
hi("FloatBorder",      { fg = c.ln_num,  bg = c.bg_float })
hi("FloatTitle",       { fg = c.fg_text, bg = c.bg_float, bold = true })
hi("ColorColumn",      {                  bg = c.bg_gutter })
hi("Conceal",          { fg = c.fg_dim })
hi("Cursor",           { fg = c.bg,      bg = c.caret })
hi("lCursor",          { fg = c.bg,      bg = c.caret })
hi("CursorIM",         { fg = c.bg,      bg = c.caret })
hi("CursorLine",       {                  bg = c.bg_line })
hi("CursorLineNr",     { fg = c.fg_text, bg = c.bg_gutter, bold = true })
hi("CursorColumn",     {                  bg = c.bg_line })
hi("LineNr",           { fg = c.ln_num,  bg = c.bg_gutter })
hi("SignColumn",       {                  bg = c.bg_gutter })
hi("FoldColumn",       { fg = c.fg_dim,  bg = c.bg_gutter })
hi("Folded",           { fg = c.folded_fg, bg = c.folded_bg })
hi("EndOfBuffer",      { fg = c.bg_gutter })
hi("VertSplit",        { fg = c.bg_gutter, bg = c.bg_gutter })
hi("WinSeparator",     { fg = c.bg_gutter })

-- ── Selection & search ───────────────────────────────────────────────────────
hi("Visual",           { fg = c.fg_sel,  bg = c.bg_sel })
hi("VisualNOS",        { fg = c.fg_sel,  bg = c.bg_sel })
hi("Search",           { fg = c.bg,      bg = "#d8d8d8" })
hi("IncSearch",        { fg = c.bg,      bg = c.fg_text })
hi("CurSearch",        { fg = c.bg,      bg = c.fg_text })
hi("Substitute",       { fg = c.bg,      bg = c.func })
hi("MatchParen",       { fg = c.match_br, bold = true })

-- ── Status / tab line ────────────────────────────────────────────────────────
hi("StatusLine",       { fg = c.fg,      bg = c.bg_gutter })
hi("StatusLineNC",     { fg = c.fg_dim,  bg = c.bg_gutter })
hi("TabLine",          { fg = c.ln_num,  bg = c.bg_gutter })
hi("TabLineFill",      {                  bg = c.bg_gutter })
hi("TabLineSel",       { fg = c.fg_text, bg = c.bg, bold = true })
hi("WinBar",           { fg = c.fg,      bg = c.bg })
hi("WinBarNC",         { fg = c.fg_dim,  bg = c.bg })

-- ── Popup menu (completion) ──────────────────────────────────────────────────
hi("Pmenu",            { fg = c.fg,      bg = c.bg_float })
hi("PmenuSel",         { fg = c.bg,      bg = c.fg_text, bold = true })
hi("PmenuSbar",        {                  bg = c.bg_gutter })
hi("PmenuThumb",       {                  bg = c.ln_num })
hi("PmenuKind",        { fg = c.type_ })
hi("PmenuKindSel",     { fg = c.bg,      bg = c.fg_text })
hi("PmenuExtra",       { fg = c.fg_dim })

-- ── Messaging ────────────────────────────────────────────────────────────────
hi("ModeMsg",          { fg = c.fg_text, bold = true })
hi("MsgArea",          { fg = c.fg })
hi("MoreMsg",          { fg = c.func })
hi("ErrorMsg",         { fg = c.error_fg })
hi("WarningMsg",       { fg = c.warn_fg })
hi("Question",         { fg = c.func })
hi("Title",            { fg = c.func,    bold = true })
hi("Directory",        { fg = c.type_ })

-- ── Whitespace / special chars ───────────────────────────────────────────────
hi("NonText",          { fg = "#505050" })  -- WHITESPACES
hi("Whitespace",       { fg = "#505050" })
hi("SpecialKey",       { fg = "#505050" })
hi("SpellBad",         { undercurl = true, sp = c.error_fg })
hi("SpellCap",         { undercurl = true, sp = c.warn_fg })
hi("SpellRare",        { undercurl = true, sp = c.info_fg })
hi("SpellLocal",       { undercurl = true, sp = c.info_fg })

-- ── Diff ─────────────────────────────────────────────────────────────────────
hi("DiffAdd",          {                  bg = c.diff_add })
hi("DiffChange",       {                  bg = c.diff_mod })
hi("DiffDelete",       {                  bg = c.diff_del })
hi("DiffText",         {                  bg = "#415F69" })
hi("Added",            { fg = c.git_add })
hi("Changed",          { fg = c.git_mod })
hi("Removed",          { fg = c.git_del })

-- ── Classic syntax groups ────────────────────────────────────────────────────
hi("Comment",          { fg = c.comment })
hi("SpecialComment",   { fg = c.doc_tag })
hi("Constant",         { fg = c.constant })
hi("String",           { fg = c.string })
hi("Character",        { fg = c.string })
hi("Number",           { fg = c.number })
hi("Float",            { fg = c.number })
hi("Boolean",          { fg = c.keyword, bold = true })
hi("Identifier",       { fg = c.fg })
hi("Function",         { fg = c.func })
hi("Statement",        { fg = c.keyword, bold = true })
hi("Conditional",      { fg = c.keyword, bold = true })
hi("Repeat",           { fg = c.keyword, bold = true })
hi("Label",            { fg = c.keyword })
hi("Keyword",          { fg = c.keyword, bold = true })
hi("Exception",        { fg = c.keyword, bold = true })
hi("Operator",         { fg = c.operator })
hi("PreProc",          { fg = c.keyword })
hi("Include",          { fg = c.keyword })
hi("Define",           { fg = c.keyword })
hi("Macro",            { fg = c.keyword })
hi("PreCondit",        { fg = c.keyword })
hi("Type",             { fg = c.type_,   bold = true })
hi("StorageClass",     { fg = c.keyword, bold = true })
hi("Structure",        { fg = c.type_,   bold = true })
hi("Typedef",          { fg = c.type_,   bold = true })
hi("Special",          { fg = c.number })
hi("SpecialChar",      { fg = c.number })
hi("Tag",              { fg = c.bracket })
hi("Delimiter",        { fg = c.bracket })
hi("Underlined",       { underline = true })
hi("Bold",             { bold = true })
hi("Italic",           { italic = true })
hi("Ignore",           { fg = c.fg_dim })
hi("Error",            { fg = c.error_fg })
hi("Todo",             { fg = c.todo,    bold = true })
hi("Debug",            { fg = c.warn_fg })

-- ── TreeSitter (Neovim 0.8+ @-groups) ───────────────────────────────────────
-- Comments
hi("@comment",                    { fg = c.comment })
hi("@comment.documentation",      { fg = c.comment })

-- Keywords
hi("@keyword",                    { fg = c.keyword, bold = true })
hi("@keyword.function",           { fg = c.keyword, bold = true })
hi("@keyword.operator",           { fg = c.keyword })
hi("@keyword.return",             { fg = c.keyword, bold = true })
hi("@keyword.import",             { fg = c.keyword, bold = true })
hi("@keyword.modifier",           { fg = c.keyword, bold = true })
hi("@keyword.repeat",             { fg = c.keyword, bold = true })
hi("@keyword.conditional",        { fg = c.keyword, bold = true })
hi("@keyword.exception",          { fg = c.keyword, bold = true })

-- Strings
hi("@string",                     { fg = c.string })
hi("@string.escape",              { fg = c.number })
hi("@string.special",             { fg = c.number })
hi("@string.regex",               { fg = c.string })
hi("@string.documentation",       { fg = c.comment })

-- Numbers / literals
hi("@number",                     { fg = c.number })
hi("@number.float",               { fg = c.number })
hi("@boolean",                    { fg = c.keyword, bold = true })
hi("@character",                  { fg = c.string })

-- Functions
hi("@function",                   { fg = c.func })
hi("@function.call",              { fg = c.func })
hi("@function.builtin",           { fg = c.func })
hi("@function.method",            { fg = c.func })
hi("@function.method.call",       { fg = c.func })
hi("@constructor",                { fg = "#a5e12e" })  -- CONSTRUCTOR_CALL_ATTRIBUTES

-- Types
hi("@type",                       { fg = c.type_, bold = true })
hi("@type.builtin",               { fg = c.type_ })
hi("@type.definition",            { fg = c.type_, bold = true })
hi("@type.qualifier",             { fg = c.keyword })

-- Variables & identifiers
hi("@variable",                   { fg = c.fg })
hi("@variable.builtin",           { fg = c.keyword })
hi("@variable.member",            { fg = c.fg })  -- instance fields
hi("@variable.parameter",         { fg = c.param })
hi("@variable.parameter.builtin", { fg = c.param })

-- Properties & fields
hi("@property",                   { fg = c.property })

-- Constants
hi("@constant",                   { fg = c.constant })
hi("@constant.builtin",           { fg = c.keyword, bold = true })
hi("@constant.macro",             { fg = c.constant })

-- Operators & punctuation
hi("@operator",                   { fg = c.operator })
hi("@punctuation.delimiter",      { fg = c.operator })
hi("@punctuation.bracket",        { fg = c.bracket })
hi("@punctuation.special",        { fg = c.operator })

-- Namespaces / modules
hi("@namespace",                  { fg = c.type_ })
hi("@module",                     { fg = c.type_ })
hi("@module.builtin",             { fg = c.type_ })

-- Annotations / attributes (Java @Override, etc.)
hi("@attribute",                  { fg = c.comment })
hi("@attribute.builtin",          { fg = c.comment })

-- Tags (HTML/XML)
hi("@tag",                        { fg = c.bracket })
hi("@tag.builtin",                { fg = c.type_ })
hi("@tag.attribute",              { fg = c.fg })
hi("@tag.delimiter",              { fg = c.bracket })

-- Markup
hi("@markup.heading",             { fg = c.func, bold = true })
hi("@markup.raw",                 { fg = c.string })
hi("@markup.link",                { fg = c.type_, underline = true })
hi("@markup.link.label",          { fg = c.type_ })
hi("@markup.link.url",            { fg = c.type_, underline = true })
hi("@markup.italic",              { fg = c.fg, italic = true })
hi("@markup.strong",              { fg = c.fg, bold = true })
hi("@markup.strikethrough",       { fg = c.fg_dim, strikethrough = true })
hi("@markup.list",                { fg = c.keyword })

-- Doc comments
hi("@comment.note",               { fg = c.doc_tag })
hi("@comment.warning",            { fg = c.warn_fg })
hi("@comment.error",              { fg = c.error_fg })
hi("@comment.todo",               { fg = c.todo, bold = true })

-- Errors (treesitter parse errors)
hi("@error",                      { fg = c.bad_char })

-- ── LSP semantic token highlights ────────────────────────────────────────────
hi("@lsp.type.class",             { fg = c.type_, bold = true })
hi("@lsp.type.interface",         { fg = c.type_, bold = true })
hi("@lsp.type.enum",              { fg = c.comment })
hi("@lsp.type.enumMember",        { fg = c.constant })
hi("@lsp.type.struct",            { fg = c.type_, bold = true })
hi("@lsp.type.function",          { fg = c.func })
hi("@lsp.type.method",            { fg = c.func })
hi("@lsp.type.decorator",         { fg = c.comment })
hi("@lsp.type.namespace",         { fg = c.type_ })
hi("@lsp.type.parameter",         { fg = c.param })
hi("@lsp.type.variable",          { fg = c.fg })
hi("@lsp.type.property",          { fg = c.property })
hi("@lsp.type.keyword",           { fg = c.keyword, bold = true })
hi("@lsp.type.comment",           { fg = c.comment })
hi("@lsp.type.string",            { fg = c.string })
hi("@lsp.type.number",            { fg = c.number })
hi("@lsp.type.operator",          { fg = c.operator })
hi("@lsp.type.typeParameter",     { fg = c.type_, bold = true })
hi("@lsp.mod.deprecated",         { strikethrough = true })
hi("@lsp.mod.readonly",           { fg = c.constant })
hi("@lsp.mod.static",             { fg = c.fg })
hi("@lsp.mod.abstract",           { fg = c.comment })

-- ── LSP diagnostics ──────────────────────────────────────────────────────────
hi("DiagnosticError",             { fg = c.error_fg })
hi("DiagnosticWarn",              { fg = c.warn_fg })
hi("DiagnosticInfo",              { fg = c.info_fg })
hi("DiagnosticHint",              { fg = c.hint_fg })
hi("DiagnosticOk",                { fg = c.func })
hi("DiagnosticVirtualTextError",  { fg = c.error_fg })
hi("DiagnosticVirtualTextWarn",   { fg = c.warn_fg })
hi("DiagnosticVirtualTextInfo",   { fg = c.info_fg })
hi("DiagnosticVirtualTextHint",   { fg = c.hint_fg })
hi("DiagnosticUnderlineError",    { undercurl = true, sp = c.error_fg })
hi("DiagnosticUnderlineWarn",     { undercurl = true, sp = c.warn_fg })
hi("DiagnosticUnderlineInfo",     { undercurl = true, sp = c.info_fg })
hi("DiagnosticUnderlineHint",     { undercurl = true, sp = c.hint_fg })
hi("DiagnosticFloatingError",     { fg = c.error_fg, bg = c.bg_float })
hi("DiagnosticFloatingWarn",      { fg = c.warn_fg,  bg = c.bg_float })
hi("DiagnosticFloatingInfo",      { fg = c.info_fg,  bg = c.bg_float })
hi("DiagnosticFloatingHint",      { fg = c.hint_fg,  bg = c.bg_float })
hi("DiagnosticSignError",         { fg = c.error_fg, bg = c.bg_gutter })
hi("DiagnosticSignWarn",          { fg = c.warn_fg,  bg = c.bg_gutter })
hi("DiagnosticSignInfo",          { fg = c.info_fg,  bg = c.bg_gutter })
hi("DiagnosticSignHint",          { fg = c.hint_fg,  bg = c.bg_gutter })

-- ── DAP debugger ─────────────────────────────────────────────────────────────
hi("DapBreakpoint",               { fg = c.error_fg, bg = c.bg_gutter })
hi("DapBreakpointCondition",      { fg = c.warn_fg,  bg = c.bg_gutter })
hi("DapLogPoint",                 { fg = c.info_fg,  bg = c.bg_gutter })
hi("DapStopped",                  { fg = c.func,     bg = c.bg_gutter })
hi("DapStoppedLine",              {                   bg = c.bg_exec })
hi("DapBreakpointRejected",       { fg = c.fg_dim,   bg = c.bg_gutter })

-- ── Git signs (gitsigns.nvim) ────────────────────────────────────────────────
hi("GitSignsAdd",                 { fg = c.git_add, bg = c.bg_gutter })
hi("GitSignsChange",              { fg = c.git_mod, bg = c.bg_gutter })
hi("GitSignsDelete",              { fg = c.git_del, bg = c.bg_gutter })
hi("GitSignsAddLn",               {                  bg = c.diff_add })
hi("GitSignsChangeLn",            {                  bg = c.diff_mod })
hi("GitSignsDeleteLn",            {                  bg = c.diff_del })

-- ── Telescope ────────────────────────────────────────────────────────────────
hi("TelescopeNormal",             { fg = c.fg,      bg = c.bg_float })
hi("TelescopeBorder",             { fg = c.ln_num,  bg = c.bg_float })
hi("TelescopeTitle",              { fg = c.fg_text, bg = c.bg_float, bold = true })
hi("TelescopePromptNormal",       { fg = c.fg,      bg = c.bg_gutter })
hi("TelescopePromptBorder",       { fg = c.ln_num,  bg = c.bg_gutter })
hi("TelescopePromptTitle",        { fg = c.func,    bg = c.bg_gutter, bold = true })
hi("TelescopePreviewNormal",      { fg = c.fg,      bg = c.bg })
hi("TelescopePreviewBorder",      { fg = c.ln_num,  bg = c.bg })
hi("TelescopeResultsNormal",      { fg = c.fg,      bg = c.bg_float })
hi("TelescopeResultsBorder",      { fg = c.ln_num,  bg = c.bg_float })
hi("TelescopeSelection",          { fg = c.fg_text, bg = c.bg_line })
hi("TelescopeSelectionCaret",     { fg = c.func })
hi("TelescopeMatching",           { fg = c.func,    bold = true })
hi("TelescopeMultiSelection",     { fg = c.type_ })

-- ── Neo-tree ─────────────────────────────────────────────────────────────────
hi("NeoTreeNormal",               { fg = c.fg,      bg = c.bg_gutter })
hi("NeoTreeNormalNC",             { fg = c.fg,      bg = c.bg_gutter })
hi("NeoTreeEndOfBuffer",          { fg = c.bg_gutter, bg = c.bg_gutter })
hi("NeoTreeRootName",             { fg = c.func,    bold = true })
hi("NeoTreeDirectoryName",        { fg = c.type_ })
hi("NeoTreeDirectoryIcon",        { fg = c.type_ })
hi("NeoTreeFileName",             { fg = c.fg })
hi("NeoTreeFileIcon",             { fg = c.fg })
hi("NeoTreeFileNameOpened",       { fg = c.fg_text })
hi("NeoTreeIndentMarker",         { fg = c.indent })
hi("NeoTreeExpander",             { fg = c.ln_num })
hi("NeoTreeSymbolicLinkTarget",   { fg = c.type_, italic = true })
hi("NeoTreeWindowsHidden",        { fg = c.fg_dim })
hi("NeoTreeDotfile",              { fg = c.fg_dim })
hi("NeoTreeGitAdded",             { fg = c.git_add })
hi("NeoTreeGitConflict",          { fg = c.error_fg })
hi("NeoTreeGitDeleted",           { fg = c.git_del })
hi("NeoTreeGitIgnored",           { fg = c.fg_dim })
hi("NeoTreeGitModified",          { fg = c.git_mod })
hi("NeoTreeGitUnstaged",          { fg = c.warn_fg })
hi("NeoTreeGitUntracked",         { fg = c.fg_text })
hi("NeoTreeGitStaged",            { fg = c.git_add })
hi("NeoTreeCursorLine",           {                  bg = c.bg_line })

-- ── Bufferline ───────────────────────────────────────────────────────────────
hi("BufferLineFill",              {                  bg = c.bg_gutter })
hi("BufferLineBackground",        { fg = c.ln_num,   bg = c.bg_gutter })
hi("BufferLineBufferSelected",    { fg = c.fg_text,  bg = c.bg, bold = true })
hi("BufferLineBufferVisible",     { fg = c.fg_dim,   bg = c.bg_gutter })
hi("BufferLineSeparator",         { fg = c.bg_gutter, bg = c.bg_gutter })
hi("BufferLineSeparatorSelected", { fg = c.bg_gutter, bg = c.bg })
hi("BufferLineSeparatorVisible",  { fg = c.bg_gutter, bg = c.bg_gutter })
hi("BufferLineIndicatorSelected", { fg = c.func,     bg = c.bg })
hi("BufferLineCloseButton",       { fg = c.ln_num,   bg = c.bg_gutter })
hi("BufferLineCloseButtonSelected", { fg = c.error_fg, bg = c.bg })
hi("BufferLineModified",          { fg = c.git_mod,  bg = c.bg_gutter })
hi("BufferLineModifiedSelected",  { fg = c.git_mod,  bg = c.bg })
hi("BufferLineError",             { fg = c.error_fg, bg = c.bg_gutter })
hi("BufferLineErrorSelected",     { fg = c.error_fg, bg = c.bg, bold = true })
hi("BufferLineWarning",           { fg = c.warn_fg,  bg = c.bg_gutter })
hi("BufferLineWarningSelected",   { fg = c.warn_fg,  bg = c.bg, bold = true })
hi("BufferLineTab",               { fg = c.ln_num,   bg = c.bg_gutter })
hi("BufferLineTabSelected",       { fg = c.fg_text,  bg = c.bg, bold = true })
hi("BufferLineTabClose",          { fg = c.ln_num,   bg = c.bg_gutter })

-- ── Indent blankline (v3) ────────────────────────────────────────────────────
hi("IblIndent",                   { fg = c.indent })
hi("IblScope",                    { fg = c.indent_sel })
hi("IblWhitespace",               { fg = c.indent })

-- ── Which-key ────────────────────────────────────────────────────────────────
hi("WhichKey",                    { fg = c.func })
hi("WhichKeyGroup",               { fg = c.type_ })
hi("WhichKeyDesc",                { fg = c.fg })
hi("WhichKeySeperator",           { fg = c.fg_dim })
hi("WhichKeyFloat",               {                  bg = c.bg_float })
hi("WhichKeyBorder",              { fg = c.ln_num,   bg = c.bg_float })
hi("WhichKeyValue",               { fg = c.fg_dim })

-- ── Noice ────────────────────────────────────────────────────────────────────
hi("NoiceCmdline",                { fg = c.fg,       bg = c.bg_gutter })
hi("NoiceCmdlineIcon",            { fg = c.func })
hi("NoiceCmdlinePopup",           { fg = c.fg,       bg = c.bg_float })
hi("NoiceCmdlinePopupBorder",     { fg = c.ln_num,   bg = c.bg_float })
hi("NoiceCmdlinePopupTitle",      { fg = c.fg_text,  bold = true })
hi("NoiceConfirm",                { fg = c.fg,       bg = c.bg_float })
hi("NoiceConfirmBorder",          { fg = c.ln_num,   bg = c.bg_float })
hi("NoicePopup",                  { fg = c.fg,       bg = c.bg_float })
hi("NoicePopupBorder",            { fg = c.ln_num,   bg = c.bg_float })
hi("NoiceMini",                   { fg = c.fg,       bg = c.bg_gutter })
hi("NoiceFormatProgressTodo",     {                   bg = c.bg_gutter })
hi("NoiceFormatProgressDone",     { fg = c.func,     bg = c.bg_gutter })

-- ── Trouble (diagnostics panel) ──────────────────────────────────────────────
hi("TroubleNormal",               { fg = c.fg,       bg = c.bg_gutter })
hi("TroubleText",                 { fg = c.fg })
hi("TroubleError",                { fg = c.error_fg })
hi("TroubleWarning",              { fg = c.warn_fg })
hi("TroubleInformation",          { fg = c.info_fg })
hi("TroubleHint",                 { fg = c.hint_fg })
hi("TroubleCode",                 { fg = c.fg_dim })
hi("TroubleSource",               { fg = c.fg_dim })
hi("TroubleFile",                 { fg = c.type_ })
hi("TroubleLocation",             { fg = c.ln_num })
hi("TroubleCount",                { fg = c.number,   bold = true })

-- ── nvim-cmp completion menu ─────────────────────────────────────────────────
hi("CmpItemAbbr",                 { fg = c.fg })
hi("CmpItemAbbrDeprecated",       { fg = c.fg_dim,   strikethrough = true })
hi("CmpItemAbbrMatch",            { fg = c.func,     bold = true })
hi("CmpItemAbbrMatchFuzzy",       { fg = c.func })
hi("CmpItemKind",                 { fg = c.type_ })
hi("CmpItemMenu",                 { fg = c.fg_dim })
hi("CmpItemKindFunction",         { fg = c.func })
hi("CmpItemKindMethod",           { fg = c.func })
hi("CmpItemKindConstructor",      { fg = "#a5e12e" })
hi("CmpItemKindClass",            { fg = c.type_ })
hi("CmpItemKindInterface",        { fg = c.type_ })
hi("CmpItemKindEnum",             { fg = c.comment })
hi("CmpItemKindEnumMember",       { fg = c.constant })
hi("CmpItemKindKeyword",          { fg = c.keyword })
hi("CmpItemKindVariable",         { fg = c.fg })
hi("CmpItemKindField",            { fg = c.fg })
hi("CmpItemKindProperty",         { fg = c.property })
hi("CmpItemKindConstant",         { fg = c.constant })
hi("CmpItemKindSnippet",          { fg = c.string })
hi("CmpItemKindText",             { fg = c.fg })
hi("CmpItemKindModule",           { fg = c.type_ })
hi("CmpItemKindUnit",             { fg = c.number })
hi("CmpItemKindFile",             { fg = c.fg })
hi("CmpItemKindFolder",           { fg = c.type_ })
hi("CmpItemKindColor",            { fg = c.string })
hi("CmpItemKindReference",        { fg = c.fg })
hi("CmpItemKindOperator",         { fg = c.operator })
hi("CmpItemKindTypeParameter",    { fg = c.type_ })
hi("CmpGhostText",                { fg = c.fg_dim, italic = true })

-- ── Aerial (code outline) ────────────────────────────────────────────────────
hi("AerialNormal",                { fg = c.fg,       bg = c.bg_gutter })
hi("AerialLine",                  {                   bg = c.bg_line })
hi("AerialLineNC",                {                   bg = c.bg_gutter })
hi("AerialFunctionIcon",          { fg = c.func })
hi("AerialClassIcon",             { fg = c.type_ })
hi("AerialMethodIcon",            { fg = c.func })

-- ── Mason ────────────────────────────────────────────────────────────────────
hi("MasonNormal",                 { fg = c.fg,       bg = c.bg_float })
hi("MasonHeader",                 { fg = c.bg,       bg = c.func, bold = true })
hi("MasonHeaderSecondary",        { fg = c.bg,       bg = c.type_, bold = true })
hi("MasonHighlight",              { fg = c.func })
hi("MasonHighlightBlock",         { fg = c.bg,       bg = c.func })
hi("MasonHighlightBlockBold",     { fg = c.bg,       bg = c.func, bold = true })
hi("MasonHighlightSecondary",     { fg = c.type_ })
hi("MasonHighlightBlockSecondary",        { fg = c.bg, bg = c.type_ })
hi("MasonHighlightBlockBoldSecondary",    { fg = c.bg, bg = c.type_, bold = true })
hi("MasonMuted",                  { fg = c.fg_dim })
hi("MasonMutedBlock",             { fg = c.bg,       bg = c.fg_dim })
hi("MasonError",                  { fg = c.error_fg })

-- ── Lazygit (terminal window — sets bg to match) ─────────────────────────────
hi("LazyGitFloat",                { fg = c.fg,       bg = c.bg_float })
hi("LazyGitBorder",               { fg = c.ln_num,   bg = c.bg_float })

-- ── Terminal colors (for :terminal / toggleterm) ─────────────────────────────
vim.g.terminal_color_0  = "#222222"  -- black
vim.g.terminal_color_1  = "#bc3f3c"  -- red
vim.g.terminal_color_2  = "#a7ec21"  -- green
vim.g.terminal_color_3  = "#ece47e"  -- yellow
vim.g.terminal_color_4  = "#52e3f6"  -- blue
vim.g.terminal_color_5  = "#ff007f"  -- magenta
vim.g.terminal_color_6  = "#20c9fb"  -- cyan
vim.g.terminal_color_7  = "#cfbfad"  -- white
vim.g.terminal_color_8  = "#26292B"  -- bright black
vim.g.terminal_color_9  = "#ff6b68"  -- bright red
vim.g.terminal_color_10 = "#a5e12e"  -- bright green
vim.g.terminal_color_11 = "#d9e577"  -- bright yellow
vim.g.terminal_color_12 = "#5394ec"  -- bright blue
vim.g.terminal_color_13 = "#c48cff"  -- bright magenta
vim.g.terminal_color_14 = "#52e3f6"  -- bright cyan
vim.g.terminal_color_15 = "#ffffff"  -- bright white
