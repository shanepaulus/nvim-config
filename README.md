# nvim-config

A full IntelliJ-like Neovim IDE configuration. Built to make the transition from IntelliJ/JetBrains as seamless as possible — IntelliJ keyboard shortcuts work in both Normal and Insert mode, and the custom `shane_paulus` colorscheme is converted from the original IntelliJ theme.

## Features

- IntelliJ keyboard shortcuts (Ctrl+B, Alt+Enter, Shift+F6, Ctrl+D, etc.)
- Custom `shane_paulus` dark colorscheme (ported from IntelliJ)
- Java LSP via `nvim-jdtls` (Lombok, DAP debugging, test runner, code generation)
- LSP for Go, Python, TypeScript, Vue, HTML, CSS, Tailwind, JSON, YAML, XML, Lua, Bash, C#/.NET (`roslyn_ls`, requires the .NET SDK on `PATH`)
- Auto-closing/renaming HTML/JSX/Vue tags via `nvim-ts-autotag`
- Telescope fuzzy finder (Ctrl+Shift+N, Ctrl+Shift+F, Ctrl+E)
- neo-tree file explorer (Alt+1)
- DAP debugging with UI (F5/F8/F7/F9)
- Auto-formatting via conform.nvim
- Git integration via gitsigns + lazygit
- Completion via nvim-cmp + LuaSnip
- Claude Code agent mode via claudecode.nvim (live diffs, selection context, `<leader>c*`)

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
| `node` + `npm` | TypeScript / Vue language servers | [nodejs.org](https://nodejs.org) / `brew install node` |
| `dotnet` (.NET SDK) | C# / `roslyn_ls` — optional; the server is only installed when `dotnet` is on `PATH` | `curl -fsSL https://dot.net/v1/dotnet-install.sh \| bash -s -- --channel LTS` (installs to `~/.dotnet`, no root) |
| `xclip` / `wl-clipboard` | system clipboard (Linux only — macOS uses built-in `pbcopy`) | `apt install xclip` (X11) / `apt install wl-clipboard` (Wayland) |
| `claude` | Claude Code agent mode (`<leader>cc`) | [install](https://docs.claude.com/claude-code) |
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
| `Ctrl+Shift+F` (or `Ctrl+F`) | Live grep (search in files) — both bound to the same action, see note below |
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
| `Ctrl+Q` | Close buffer |
| `Alt+J / Alt+K` | Move line down / up |
| `Ctrl+Alt+W` | Toggle whitespace visibility |
| `Shift+Alt+Enter/Up/Down/Left/Right` | Cycle alternatives (true↔false, &&↔\|\|, etc.) |

### Panels

| Key | Action |
|-----|--------|
| `Alt+1` | Toggle file explorer (neo-tree) |
| `Alt+4` | Toggle terminal panel (opens at the bottom, remembers last tab) |
| `<N>Alt+4` | Jump to/create terminal tab N (type the digit first in Normal mode, e.g. `2` then `Alt+4`) |

### Terminal Tabs (IntelliJ-style)

The terminal panel opens as a horizontal split at the bottom of the window, with numbered tabs — same on macOS and Linux, since none of these are Cmd-based chords.

| Key | Action |
|-----|--------|
| `Alt+T` | New terminal tab |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Next / previous terminal tab (while focused in a terminal) |
| `Ctrl+F4` | Close current terminal tab |
| `Ctrl+Up` / `Ctrl+Down` | Resize terminal panel height |

`Ctrl+Alt+T` was deliberately avoided for "new tab" — it's Cinnamon's (and some other Linux DEs') global "open terminal" shortcut and never reaches Neovim.

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

### macOS (Ghostty)

On macOS the config additionally registers Cmd-based shortcuts mirroring the **stock macOS IntelliJ keymap**, alongside all the Ctrl/Alt bindings above. Neovim ≥ 0.10 receives ⌘ chords from Ghostty via the kitty keyboard protocol as the `D-` (super) modifier.

| Key | Action |
|-----|--------|
| `⌘S` | Save |
| `⌘Z` / `⇧⌘Z` | Undo / Redo |
| `⌘A` | Select all |
| `⌘C` (visual) / `⌘V` | Copy / paste clipboard |
| `⌘D` | Duplicate line |
| `⌘⌫` | Delete line |
| `⌘/` | Toggle comment |
| `⌘L` | Go to line number |
| `⌘[` / `⌘]` | Jump back / forward |
| `⌘W` | Close buffer |
| `⌘B` / `⌥⌘B` | Go to definition / implementation |
| `⌘Y` | Hover documentation (quick definition) |
| `⇧⌘O` | Find file by name |
| `⌘E` | Recent files |
| `⇧⌘F` | Live grep (search in files) |
| `⌥⌘O` | Workspace symbols |
| `⌥⌘L` | Format file |
| `⌘1` | Toggle file explorer |
| `⌘F2` | Debug: stop |

Required `~/.config/ghostty/config` on the Mac — Option must act as Alt (for `Alt+J/K`, `Alt+1`, `Alt+4`, `Alt+T`, `Alt+Enter`, `Alt+F7`), and Ghostty's own ⌘ bindings must be released for the chords Neovim needs:

```
macos-option-as-alt = true

# Release Ghostty defaults that collide with the IntelliJ-style maps
keybind = super+d=unbind                 # new split
keybind = super+w=unbind                 # close surface
keybind = super+a=unbind                 # select all
keybind = super+left_bracket=unbind      # previous split
keybind = super+right_bracket=unbind     # next split
keybind = super+physical:one=unbind      # goto tab 1 (frees ⌘1)
```

Check the exact defaults on your Ghostty version with `ghostty +list-keybinds --default` — any ⌘ chord left unbound passes through to Neovim automatically. `⌘C`/`⌘V` need no unbinding: Ghostty's copy only fires when a terminal selection exists, and its paste works in Neovim via bracketed paste.

Testing note: the Cmd maps are gated on `has("mac")`; set `NVIM_MAC_KEYS=1` to force-register them on Linux (see `lua/config/util.lua`).

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
Without the Kitty keyboard protocol (or an equivalent CSI-u mode), a terminal can't distinguish e.g. `Ctrl+Shift+F` from `Ctrl+F` at the protocol level — both send the identical byte — so most default Linux terminals (GNOME Terminal, xterm, etc.) deliver the plain, un-shifted combo to Neovim instead. Terminals known to send the full combo correctly: WezTerm, Alacritty, Kitty.

Where this bites, the fix used in this config is to bind the same action to both the "real" IntelliJ chord and its Shift-stripped fallback (e.g. `Ctrl+Shift+F` and `Ctrl+F` both trigger live grep; `Ctrl+Shift+N` and `Ctrl+P` both trigger find-file) so it works everywhere regardless of terminal capability. If you hit a shortcut in this README that doesn't have a fallback yet and isn't working, that's the same root cause — either switch to a terminal with full keyboard-protocol support, or add a `<C-x>`-style fallback mapping next to the `<C-S-x>` one in the relevant `lua/plugins/*.lua` file.

**Global search (`Ctrl+Shift+F`/`Ctrl+F`) does nothing, but find-file (`Ctrl+P`) works fine:**
This is a missing `ripgrep` install, not a keybinding problem. `find_files` (`Ctrl+P`) falls back through `rg` → `fd` → plain `find`, and `find` is always present on Linux — so it silently keeps working even without `rg`. `live_grep` has no such fallback; it hard-requires `rg` and just does nothing without it. Check with:
```bash
rg --version
```
If that fails, install it (`fd` is optional — only speeds up/improves `find_files`, not required):
```bash
sudo apt install ripgrep fd-find   # Debian/Ubuntu/Mint
brew install ripgrep fd            # macOS
```
No restart or config change needed after installing — Telescope picks it up on the next search.

**Yanking in Neovim doesn't reach the system clipboard (paste into another app gives the wrong text):**
`opt.clipboard = "unnamedplus"` does not talk to the OS by itself — it delegates to an external
provider, and on Linux none of them ship with Neovim. Without `xclip`/`xsel` (X11) or `wl-clipboard`
(Wayland) every yank stays inside Neovim and nothing warns you at startup. macOS is unaffected:
`pbcopy`/`pbpaste` are always present. Check with:
```
:checkhealth vim.provider
```
A `clipboard: No provider` line is the confirmation. Install one:
```bash
sudo apt install xclip          # X11 (echo $XDG_SESSION_TYPE == x11)
sudo apt install wl-clipboard   # Wayland
```
As a safety net, `lua/config/options.lua` falls back to OSC 52 when no provider is found, so copying
still works over SSH or on a bare box — the terminal itself carries the yank. That fallback is
copy-only: pasting reads Neovim's own register, because an OSC 52 clipboard *read* makes most
terminals prompt (or hang) on every `p`. Installing a real provider restores true two-way sync and
disables the fallback automatically.

**Java completion returns nothing (`this.` shows no fields/methods), but the file still highlights:**
Check the diagnostics on line 1 of the file — the giveaway is:
```
<File>.java is a non-project file, only syntax errors are reported
```
jdtls attached but never imported the build, so it has no classpath and no semantic model: syntax
highlighting keeps working while completion, go-to-definition and find-usages all come back empty.
The usual cause is jdtls rooting itself at a **submodule** instead of the real build root — a Gradle
subproject whose `build.gradle(.kts)` resolves `libs.*` from a root `gradle/libs.versions.toml`
cannot be configured standalone. `ftplugin/java.lua` picks the outermost `settings.gradle(.kts)`
(Gradle) or `pom.xml` (Maven aggregator), bounded by the enclosing git repo, so this should resolve
itself. Confirm which root it chose:
```
:lua =vim.lsp.get_clients({ bufnr = 0 })[1].root_dir
```
It must be the directory holding `settings.gradle(.kts)` / the parent `pom.xml`, not the submodule.
If a stale workspace is cached from a previous bad root, clear it and reopen:
```bash
rm -rf ~/.cache/nvim/jdtls-workspace/<project-name>
```
Importing a Gradle/Maven project also makes jdtls write Eclipse metadata (`.project`, `.classpath`,
`.settings/`, `bin/`) into the project — add those to the project's `.gitignore`.

**Completion works but auto-import doesn't (or Vue files get no completion at all):**
Run the suite — it drives a real Neovim per language, types an unimported symbol, confirms the
completion and asserts the import statement actually landed:
```bash
./tests/autoimport.sh            # everything available
./tests/autoimport.sh vue java   # just these
```
A missing toolchain reports SKIP, never FAIL. Two things this has caught:

- **Vue: `ts_ls` attaches but answers nothing.** `vue_ls` runs in hybrid mode and handles only the
  template/style blocks; TypeScript comes from `ts_ls`. Plain `tsserver` cannot parse a single-file
  component, so unless it loads `@vue/typescript-plugin` it returns no completions, no auto-imports
  and no types for `.vue` buffers — while `:LspInfo` still shows both servers happily attached,
  which makes it read as a completion bug rather than a missing plugin.
- **Python: pyright has no library index.** Stock pyright only auto-imports symbols from files it
  has already parsed, so `Path` never offers `from pathlib import Path`. The index that makes this
  work in Pylance is closed-source, so this config uses **basedpyright**, the drop-in fork that
  ships one.

**C#: `roslyn_ls` answers completion requests with a stale, truncated list.**
Immediately after a keystroke, `roslyn_ls` returns a *truncated* completion list but marks it
`isIncomplete = false` — nvim-cmp takes that as authoritative, caches the slice and never
re-queries, so the menu stays empty for anything past a couple of characters even though the
symbol exists. Measured, identical request, same buffer text, two timings:
```
+60ms   items=545   isIncomplete=false   StringBuilder absent   <- stale, falsely "complete"
+2000ms items=1000  isIncomplete=true    StringBuilder present
```
The settle time varies with project size and machine — a single fixed delay (250ms, 500ms, 800ms
were each tried) is not reliable. `lua/plugins/completion.lua` works around this for `cs` buffers
only: on every keystroke it re-issues `cmp.complete()` on a short retry ladder (400/1000/2000ms),
stopping as soon as the menu has entries. Every other language's server reports `isIncomplete`
honestly and needs none of this. Covered by `./tests/autoimport.sh cs` (requires the .NET SDK —
see the dependency table above).

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
        ├── claude.lua        # claudecode.nvim: Claude Code agent mode (<leader>c*)
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
