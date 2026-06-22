# nvim-config

A full IntelliJ-like Neovim IDE configuration. Built to make the transition from IntelliJ/JetBrains as seamless as possible — IntelliJ keyboard shortcuts work in both Normal and Insert mode, and the custom `shane_paulus` colorscheme is converted from the original IntelliJ theme.

## Features

- IntelliJ keyboard shortcuts (Ctrl+B, Alt+Enter, Shift+F6, Ctrl+D, etc.)
- Custom `shane_paulus` dark colorscheme (ported from IntelliJ)
- Java LSP via `nvim-jdtls` (Lombok, DAP debugging, test runner, code generation)
- LSP for Go, Python, TypeScript, HTML, CSS, Tailwind, JSON, YAML, XML, Lua, Bash
- Telescope fuzzy finder (Ctrl+Shift+N, Ctrl+Shift+F, Ctrl+E)
- neo-tree file explorer (Alt+1)
- DAP debugging with UI (F5/F8/F7/F9)
- Auto-formatting via conform.nvim
- Git integration via gitsigns + lazygit
- Completion via nvim-cmp + LuaSnip

## Requirements

### Neovim

Version **0.11+** is required (the config uses `vim.lsp.config` / `vim.lsp.enable` — the native 0.11 API).

```bash
# Ubuntu/Debian — install from the Neovim PPA or download the appimage
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update && sudo apt install neovim

# macOS
brew install neovim
```

### System dependencies

These need to be on your `PATH`:

| Tool | Purpose | Install |
|------|---------|---------|
| `git` | plugin manager | system package |
| `fd` | telescope file search | `cargo install fd-find` or [release](https://github.com/sharkdp/fd/releases) |
| `fzf` | fuzzy matching | `brew install fzf` / `apt install fzf` |
| `lazygit` | git UI (Alt+G) | [release](https://github.com/jesseduffield/lazygit/releases) |
| `ripgrep` | live grep | `brew install ripgrep` / `apt install ripgrep` |
| A [Nerd Font](https://www.nerdfonts.com/) | icons in the UI | set as your terminal font |

### Java (if you work with Java projects)

- **JDK 17+** on your `PATH` — `jdtls` will auto-detect it via `java -XshowSettings:all`
- If detection fails, the config falls back to `/usr/lib/jvm/java-25-openjdk-amd64` — edit `ftplugin/java.lua` to match your JDK path
- **Gradle** is expected at `/opt/gradle` — change `java.gradle.home` in `ftplugin/java.lua` if yours is elsewhere
- **Maven** is expected at `/opt/maven` — change `java.import.maven.home` similarly

> Mason installs `jdtls`, `java-debug-adapter`, and `java-test` automatically on first launch — you don't need to install them manually.

## Installation

```bash
# 1. Back up any existing config
mv ~/.config/nvim ~/.config/nvim.bak   # skip if you have nothing to save

# 2. Clone this repo as your Neovim config
git clone https://github.com/shanepaulus/nvim-config ~/.config/nvim

# 3. Launch Neovim — lazy.nvim bootstraps itself and installs all plugins
nvim
```

On the **first launch**:
1. `lazy.nvim` clones and installs all plugins (~1-2 min)
2. `mason-tool-installer` downloads LSP servers and formatters (~5-10 min)
3. **Restart Neovim** after Mason finishes
4. Open a Java file — `jdtls` indexes your project on first open (15-60s)

## Updating

```bash
# Pull latest config changes
cd ~/.config/nvim && git pull

# Inside Neovim, update plugins
:Lazy update

# Update Mason-managed LSP servers/tools
:MasonUpdate
```

## Key Bindings

### Navigation (IntelliJ-style)

| Key | Action |
|-----|--------|
| `Ctrl+B` | Go to definition |
| `Ctrl+Alt+B` | Go to implementation |
| `Alt+F7` | Find usages |
| `Ctrl+Shift+I` | Hover documentation |
| `Alt+Enter` | Code action / quick fix |
| `Shift+F6` | Rename symbol |
| `Ctrl+F12` | File structure |
| `Ctrl+Shift+O` | Workspace symbols |
| `Ctrl+Shift+N` | Find file by name |
| `Ctrl+Shift+F` | Live grep (search in files) |
| `Ctrl+E` | Recent files |
| `Ctrl+G` | Go to line number |
| `Alt+Left / Alt+Right` | Jump back / forward |
| `Ctrl+Tab / Ctrl+Shift+Tab` | Next / previous buffer |
| `Ctrl+F4` | Close buffer |

### Editor

| Key | Action |
|-----|--------|
| `Ctrl+S` | Save |
| `Ctrl+Z` | Undo |
| `Ctrl+Y` / `Ctrl+Shift+Z` | Redo |
| `Ctrl+D` | Duplicate line |
| `Ctrl+Shift+D` | Delete line |
| `Ctrl+/` | Toggle comment |
| `Ctrl+A` | Select all |
| `Ctrl+C` (visual) | Copy to clipboard |
| `Ctrl+V` | Paste from clipboard |
| `Ctrl+Q` | Visual block mode |
| `Alt+J / Alt+K` | Move line down / up |
| `Ctrl+Alt+W` | Toggle whitespace visibility |
| `Shift+Alt+Enter/Up/Down/Left/Right` | Cycle alternatives (true↔false, &&↔\|\|, etc.) |

### Panels

| Key | Action |
|-----|--------|
| `Alt+1` | Toggle file explorer (neo-tree) |
| `Alt+4` | Toggle terminal |

### Debugging (DAP)

| Key | Action |
|-----|--------|
| `F9` | Toggle breakpoint |
| `F5` | Continue |
| `F8` | Step over |
| `F7` | Step into |
| `Shift+F8` | Step out |

### Java-specific

| Key | Action |
|-----|--------|
| `Shift+F10` | Run nearest test |
| `Shift+F9` | Debug nearest test |
| `Alt+Insert` | Generate code (constructors, getters, etc.) |
| `Ctrl+Alt+O` | Organize imports |
| `<leader>jv` | Extract variable |
| `<leader>jm` | Extract method |
| `<leader>jc` | Extract constant |

### File Explorer (neo-tree, when focused)

| Key | Action |
|-----|--------|
| `Enter` or `l` | Open file / expand folder |
| `h` | Collapse folder |
| `a` | New file |
| `A` | New directory |
| `d` | Delete |
| `r` | Rename |
| `R` | Refresh |
| `I` | Toggle gitignored files |
| `?` | Show all keys |

## Troubleshooting

**Colors look wrong:**
```
:set termguicolors
```
If that fixes it, ensure your terminal supports 24-bit color (most modern terminals do).

**LSP not starting:**
```
:checkhealth vim.lsp
:LspInfo
```

**jdtls failing on Java files:**
```
# Check if Mason installed jdtls correctly
:echo glob(stdpath('data')..'/mason/packages/jdtls/bin/jdtls')

# If lombok line errors: check if lombok.jar exists
:echo glob(stdpath('data')..'/mason/packages/jdtls/lombok.jar')
```

**Wrong error line numbers after editing config:**
```bash
rm -rf ~/.cache/nvim/luac
```
Then restart Neovim. Stale bytecode cache.

**Ctrl+Shift / Ctrl+Alt shortcuts not working in terminal:**
Some terminal emulators don't pass these key combinations through to Neovim. Check your terminal's key binding settings. Known to work well: WezTerm, Alacritty, Kitty.

## Adding Vue Support

Vue LSP (`volar`) is commented out because the lspconfig server name can vary by mason-lspconfig version. To add it:

1. Check the current valid name: `:h mason-lspconfig-server-map` inside Neovim
2. Uncomment and correct the name in `lua/plugins/lsp.lua` (both `ensure_installed` and `vim.lsp.enable`)

## Structure

```
~/.config/nvim/
├── init.lua                  # Entry point: lazy.nvim bootstrap
├── colors/
│   └── shane_paulus.lua      # Custom colorscheme (IntelliJ port)
├── ftplugin/
│   └── java.lua              # Java LSP via nvim-jdtls (per-buffer)
└── lua/
    ├── config/
    │   ├── autocmds.lua      # Filetype overrides, yank highlight
    │   ├── keymaps.lua       # Global IntelliJ-style keymaps
    │   └── options.lua       # Editor options
    └── plugins/
        ├── aerial.lua        # Code structure outline (Ctrl+F12 fallback)
        ├── completion.lua    # nvim-cmp + LuaSnip
        ├── dap.lua           # Debug adapter + UI
        ├── editor.lua        # autopairs, surround, multi-cursor, comments
        ├── formatter.lua     # conform.nvim (google-java-format, prettier, etc.)
        ├── git.lua           # gitsigns + lazygit
        ├── lsp.lua           # Mason + lspconfig (all non-Java LSPs)
        ├── neo-tree.lua      # File explorer
        ├── telescope.lua     # Fuzzy finder
        ├── terminal.lua      # toggleterm
        ├── treesitter.lua    # Syntax + textobjects
        ├── trouble.lua       # Diagnostics panel
        ├── ui.lua            # Colorscheme, lualine, bufferline, noice
        └── which-key.lua     # Key hint popups
```
