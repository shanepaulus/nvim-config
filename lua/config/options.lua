local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.cmdheight = 1
opt.pumheight = 10
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.list = false

-- Indentation (4 spaces — IntelliJ default)
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Files & history
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.backup = false
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300

-- Splits (IntelliJ-like panel placement)
opt.splitbelow = true
opt.splitright = true

-- System clipboard — makes y/p work like IntelliJ Ctrl+C/Ctrl+V
opt.clipboard = "unnamedplus"

-- Full mouse support
opt.mouse = "a"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Misc
opt.conceallevel = 0
opt.fileencoding = "utf-8"
opt.writebackup = false
opt.shortmess:append("c")
opt.isfname:append("@-@")
