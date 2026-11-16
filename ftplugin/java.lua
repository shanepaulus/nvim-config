-- Runs automatically when any *.java buffer opens (Neovim FileType autocmd).
-- Uses nvim-jdtls instead of the standard lspconfig pattern because jdtls
-- requires per-buffer workspace isolation.

local ok, jdtls = pcall(require, "jdtls")
if not ok then return end

-- ── 1. Detect JDK home ───────────────────────────────────────────────────────
-- Tries, in order: $JAVA_HOME, macOS's java_home tool, `java` on PATH.
-- No OS-specific path is ever assumed to exist — every candidate is verified
-- by resolve_jdk() before use, since a wrong guess here breaks jdtls silently.
--
-- An existing directory is not enough: Homebrew's `/opt/homebrew/opt/openjdk`
-- (the path `brew info openjdk` suggests for JAVA_HOME) is a wrapper holding
-- only bin/ symlinks — the real JDK lives under libexec/openjdk.jdk/Contents/Home.
-- Handing jdtls the wrapper makes it log "Missing system library" / "Unable to
-- locate JDK types": the project half-imports with bogus errors and
-- go-to-definition/implementation silently do nothing.
local function resolve_jdk(path)
  if not path or path == "" then return nil end
  for _, candidate in ipairs({ path, path .. "/libexec/openjdk.jdk/Contents/Home" }) do
    if vim.uv.fs_stat(candidate .. "/release") then
      return candidate
    end
  end
  return nil
end

local function get_java_home()
  local env_home = resolve_jdk(vim.env.JAVA_HOME)
  if env_home then
    return env_home
  end

  if vim.fn.has("mac") == 1 and vim.fn.executable("/usr/libexec/java_home") == 1 then
    local mac_home = vim.trim(vim.fn.system("/usr/libexec/java_home 2>/dev/null"))
    if vim.v.shell_error == 0 and resolve_jdk(mac_home) then
      return resolve_jdk(mac_home)
    end
  end

  if vim.fn.executable("java") == 1 then
    local result = vim.fn.system("java -XshowSettings:all -version 2>&1")
    local home = result:match("java%.home%s*=%s*(.-)%s*\n")
      or result:match("java%.home%s*=%s*(.-)%s*$")
    if resolve_jdk(home) then
      return resolve_jdk(home)
    end
  end

  return nil
end

-- Execution-environment name for the detected JDK (e.g. "JavaSE-26"), read from
-- its `release` file so the runtime label always matches the actual JDK.
local function jdk_runtime_name(home)
  local ok_read, lines = pcall(vim.fn.readfile, home .. "/release")
  if ok_read then
    for _, line in ipairs(lines) do
      local major = line:match('^JAVA_VERSION="1%.(%d+)') or line:match('^JAVA_VERSION="(%d+)')
      if major then return "JavaSE-" .. major end
    end
  end
  return "JavaSE-25"
end

local java_home = get_java_home()
if not java_home then
  -- WARN, not ERROR: vim.notify's default handler raises ERROR-level
  -- messages as a real Vim error when called from a ftplugin script (via
  -- nvim_echo's err=true), producing a stack trace instead of a clean message.
  vim.notify(
    "jdtls: no JDK found (checked $JAVA_HOME, /usr/libexec/java_home, `java` on PATH).\n"
      .. "Install a JDK and/or set $JAVA_HOME, then reopen this file.",
    vim.log.levels.WARN
  )
  return
end

-- ── 2. jdtls binary (installed by Mason) ─────────────────────────────────────
local mason_bin      = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

if vim.fn.executable(mason_bin) ~= 1 then
  vim.notify(
    "jdtls: not installed/executable at " .. mason_bin
      .. "\nMason may still be installing it — check `:Mason`, then reopen this file.",
    vim.log.levels.WARN
  )
  return
end


-- ── 4. DAP bundles (java-debug-adapter + vscode-java-test) ──────────────────
local bundles = {}

local debug_jar = vim.fn.glob(
  mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
  true
)
if debug_jar ~= "" then
  table.insert(bundles, debug_jar)
end

-- vscode-java-test (Mason's "java-test" package, currently pinned to 0.45.0)
-- is DISABLED: its com.microsoft.java.test.plugin bundle requires
-- org.objectweb.asm in range [9.9.0,9.10.0), but jdtls v1.60.0 ships
-- org.objectweb.asm 9.10.1 — outside that range, so OSGi can never resolve
-- the bundle. jdtls logs an
-- "org.osgi.framework.BundleException: Could not resolve module:
-- com.microsoft.java.test.plugin" every time it starts (i.e. on every Java
-- file opened), and the test-runner keymaps below were never functional
-- because of it. Re-enable once Mason picks up a java-test release whose
-- Require-Bundle range includes 9.10.1 (or jdtls downgrades asm).
local has_test_bundle = false
-- local test_jars = vim.fn.glob(
--   mason_packages .. "/java-test/extension/server/*.jar",
--   true, true
-- )
-- if type(test_jars) == "table" then
--   vim.list_extend(bundles, test_jars)
--   has_test_bundle = #test_jars > 0
-- end

-- ── 5. Lombok agent (bundled with Mason's jdtls package since v1.26.0) ──────
local lombok_jar = vim.fn.glob(mason_packages .. "/jdtls/lombok.jar", true)
local jvm_args = {}
if lombok_jar ~= "" then
  table.insert(jvm_args, "-javaagent:" .. lombok_jar)
end

-- ── 6. Build the cmd array ───────────────────────────────────────────────────
local cmd = { mason_bin }
for _, arg in ipairs(jvm_args) do
  table.insert(cmd, "--jvm-arg=" .. arg)
end

-- ── 7. jdtls config ──────────────────────────────────────────────────────────
-- jdtls.setup.find_root() returns the NEAREST ancestor holding any marker,
-- which is wrong for multi-module builds: for drobe/backend/src/... it stops
-- at drobe/backend (build.gradle.kts) instead of drobe/, where
-- settings.gradle.kts and gradle/libs.versions.toml actually live. jdtls then
-- tries to import the subproject as a standalone build, Gradle fails to
-- resolve `libs.*`, and every file comes back as
--   "<File>.java is a non-project file, only syntax errors are reported"
-- — no completion, no go-to-definition, just syntax highlighting.
--
-- Prefer the OUTERMOST root instead: the topmost settings.gradle(.kts) for
-- Gradle, the topmost pom.xml for Maven aggregator builds. The walk stops at
-- the enclosing git repo so an unrelated build file further up the filesystem
-- can never capture the project.
local function find_project_root()
  local file_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
  local dir = file_dir
  local function has(d, name)
    return vim.uv.fs_stat(d .. "/" .. name) ~= nil
  end

  local gradle_root, maven_root, nearest_build, git_root
  while true do
    if has(dir, "settings.gradle") or has(dir, "settings.gradle.kts") then
      gradle_root = dir -- keep overwriting while ascending: ends up outermost
    end
    if has(dir, "pom.xml") then
      maven_root = dir
    end
    if not nearest_build and (has(dir, "build.gradle") or has(dir, "build.gradle.kts")
        or has(dir, "pom.xml") or has(dir, "mvnw") or has(dir, "gradlew")) then
      nearest_build = dir
    end
    if has(dir, ".git") then
      git_root = dir
      break -- repo boundary
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end

  -- No marker at all: plain Java folder (no build tool, no git), e.g. an
  -- IntelliJ-only project whose source root lives in its .iml. Use the source
  -- root implied by the `package` line: for com/acme/Demo.java declaring
  -- `package com.acme;` that's two levels up. Rooting at the file's own folder
  -- makes jdtls flag every file with
  --   The declared package "com.acme" does not match the expected package ""
  local source_root = file_dir
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 50, false)) do
    local pkg = line:match("^%s*package%s+([%w_.]+)%s*;")
    if pkg then
      for _ in pkg:gmatch("[^.]+") do
        source_root = vim.fn.fnamemodify(source_root, ":h")
      end
      break
    end
  end
  return gradle_root or maven_root or nearest_build or git_root or source_root
end

local root_dir = find_project_root()

-- Per-project workspace cache. Keyed off root_dir rather than getcwd(): the
-- cwd depends on where nvim happened to be launched, so the same project
-- opened from two directories used to get two workspaces (re-indexing every
-- time), and two projects opened from the same cwd used to share one.
local workspace_dir = vim.fn.stdpath("cache")
  .. "/jdtls-workspace/"
  .. vim.fn.fnamemodify(root_dir, ":p:h:t")
vim.list_extend(cmd, { "-data", workspace_dir })

-- Gradle/Maven home: only set if explicitly configured via env var.
-- Neither install location is OS-portable to hardcode (Homebrew/SDKMAN paths
-- vary by machine) — omitting `home` lets jdtls fall back to project wrapper
-- scripts (gradlew/mvnw), which is correct for the vast majority of projects.
local gradle_home = vim.env.GRADLE_HOME
local maven_home  = vim.env.MAVEN_HOME

local config = {
  cmd = cmd,

  root_dir = root_dir,

  capabilities = require("cmp_nvim_lsp").default_capabilities(),

  settings = {
    java = {
      home = java_home,
      eclipse = { downloadSources = true },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = jdk_runtime_name(java_home),
            path = java_home,
          },
        },
      },
      maven = {
        downloadSources  = true,
        updateSnapshots  = true,
        defaultMojoExecutionAction = "warn",
      },
      gradle = {
        enabled = true,
        home    = gradle_home,
      },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens      = { enabled = true },
      references = { includeDecompiledSources = true },
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
      format = {
        enabled = true,
        settings = {
          -- Per-project formatter XML takes precedence; falls back to Google style
          url     = vim.fn.glob(root_dir .. "/eclipse-formatter.xml"),
          profile = "GoogleStyle",
        },
      },
      signatureHelp = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
        },
        filteredTypes = {
          "com.sun.*", "io.micrometer.shaded.*",
          "java.awt.*", "jdk.*", "sun.*",
        },
        guessMethodArguments = true,
      },
      sources = {
        organizeImports = {
          starThreshold       = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        hashCodeEquals = { useJava7Objects = true },
        useBlocks = true,
      },
      import = {
        gradle = {
          enabled = true,
          home    = gradle_home,
        },
        maven = {
          enabled = true,
          home    = maven_home,
        },
        exclusions = {
          "**/node_modules/**", "**/.metadata/**",
          "**/archetype-resources/**", "**/META-INF/maven/**",
        },
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(client, bufnr)
    -- Register DAP capabilities with jdtls
    if #bundles > 0 then
      require("jdtls").setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end

    local map = function(lhs, rhs, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Java: " .. desc })
    end

    -- Shared LSP keymaps (Ctrl+B, ⌘B, ⌥⌘B, Alt+F7, ...) come from the LspAttach
    -- autocmd in lua/plugins/lsp.lua, which covers jdtls too. Java-only extras below.

    -- ── Java-specific IntelliJ keymaps ─────────────────────────────────────────
    local action = function(kind)
      return function()
        vim.lsp.buf.code_action({ context = { only = { kind } }, apply = true })
      end
    end
    local function nmap_v(lhs, rhs, desc)
      map(lhs, rhs, desc)
      map(lhs, rhs, desc, "v")
    end
    local function nmap_i(lhs, rhs, desc)
      map(lhs, rhs, desc)
      map(lhs, rhs, desc, "i")
    end

    -- IntelliJ: Alt+Insert → Generate (constructors, getters, toString, etc.)
    -- jdtls has no standalone `generate()` function (that name only exists
    -- under `jdtls.tests`, for generating test scaffolding) — its "generate"
    -- actions are LSP source code actions, so this opens that menu.
    nmap_i("<A-Insert>", function()
      vim.lsp.buf.code_action({ context = { only = { "source.generate", "source.overrideMethods" } } })
    end, "Generate (Alt+Insert)")

    -- IntelliJ: Ctrl+I → Implement Methods (all abstract ones, IntelliJ's
    -- default selection) · Ctrl+O → Override Methods (pick one).
    -- Ctrl+I is only distinct from Tab in terminals with the kitty keyboard
    -- protocol (Ghostty); elsewhere this would shadow Tab in Java buffers.
    local function override_methods(implement)
      local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
      params.context = { diagnostics = {} }
      client:request("java/listOverridableMethods", params, function(err, result)
        local methods = vim.tbl_filter(function(m)
          return not implement or m.unimplemented
        end, (not err and result and result.methods) or {})
        if #methods == 0 then
          vim.notify(implement and "No methods to implement" or "No methods to override")
          return
        end
        local add = function(selected)
          client:request("java/addOverridableMethods",
            { context = params, overridableMethods = selected },
            function(err2, edit)
              if edit then vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding) end
              if err2 then vim.notify(err2.message, vim.log.levels.WARN) end
            end, bufnr)
        end
        if implement then return add(methods) end
        vim.ui.select(methods, {
          prompt = "Override Method",
          format_item = function(m)
            return string.format("%s(%s)  %s", m.name, table.concat(m.parameters, ", "), m.declaringClass)
          end,
        }, function(m) if m then add({ m }) end end)
      end, bufnr)
    end
    nmap_i("<C-i>", function() override_methods(true) end,  "Implement methods (Ctrl+I)")
    nmap_i("<C-o>", function() override_methods(false) end, "Override methods (Ctrl+O)")

    -- IntelliJ: Ctrl+Alt+O → Optimize imports
    nmap_i("<C-A-o>", jdtls.organize_imports, "Optimize imports (Ctrl+Alt+O)")

    -- IntelliJ refactorings. jdtls.extract_* read the selection from the '< '>
    -- marks, which are only set once visual mode is left.
    local extract = function(fn)
      return function()
        local visual = vim.fn.mode() ~= "n"
        if visual then vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false) end
        fn(visual)
      end
    end
    nmap_v("<C-A-v>", extract(jdtls.extract_variable), "Introduce variable (Ctrl+Alt+V)")
    nmap_v("<C-A-m>", extract(jdtls.extract_method),   "Extract method (Ctrl+Alt+M)")
    nmap_v("<C-A-c>", extract(jdtls.extract_constant), "Introduce constant (Ctrl+Alt+C)")
    nmap_v("<C-A-f>", action("refactor.extract.field"),       "Introduce field (Ctrl+Alt+F)")
    nmap_v("<C-A-p>", action("refactor.introduce.parameter"), "Introduce parameter (Ctrl+Alt+P)")
    nmap_v("<C-A-n>", action("refactor.inline"),              "Inline (Ctrl+Alt+N)")
    map("<F6>",       action("refactor.move"),                "Move (F6)")
    map("<C-F6>",     action("refactor.change.signature"),    "Change signature (Ctrl+F6)")

    -- Extract refactorings, <leader>j aliases
    nmap_v("<leader>jv", extract(jdtls.extract_variable), "Extract variable")
    nmap_v("<leader>jm", extract(jdtls.extract_method),   "Extract method")
    map("<leader>jc", extract(jdtls.extract_constant), "Extract constant")

    -- IntelliJ: Ctrl+U → Go to super method
    map("<C-u>", jdtls.super_implementation, "Go to super method (Ctrl+U)")

    -- IntelliJ: Ctrl+Shift+T → Go to test (Foo.java ↔ FooTest.java).
    -- jdtls.tests.goto_subjects needs the disabled java-test bundle (see above).
    nmap_i("<C-S-t>", function()
      local name = vim.fn.expand("%:t:r")
      local target = (name:match("^(.+)Tests?$") or (name .. "Test")) .. ".java"
      local found = vim.fs.find(target, { path = root_dir, type = "file", limit = 1 })[1]
      if found then
        vim.cmd.edit(vim.fn.fnameescape(found))
      else
        vim.notify("Go to test: no " .. target .. " under " .. root_dir)
      end
    end, "Go to test (Ctrl+Shift+T)")

    -- IntelliJ run/debug: Ctrl+Shift+F10 → run this file's main() ·
    -- Shift+F10 → rerun the last run · Shift+F9 → debug (last, or this file).
    -- Runs go through nvim-dap (java-debug bundle); output shows in the dap
    -- REPL, IntelliJ's Run window (Alt+4).
    local function run_this_class(debug)
      local pkg
      for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)) do
        pkg = line:match("^%s*package%s+([%w_.]+)%s*;")
        if pkg then break end
      end
      local main = (pkg and (pkg .. ".") or "") .. vim.fn.expand("%:t:r")
      local overrides = { noDebug = not debug, console = "internalConsole" }
      require("jdtls.dap").fetch_main_configs({ config_overrides = overrides }, function(configs)
        vim.schedule(function()
          for _, cfg in ipairs(configs) do
            if cfg.mainClass == main then
              vim.g.java_last_run = cfg
              require("dap").run(cfg)
              if not debug then require("dap").repl.open() end
              return
            end
          end
          vim.notify("No main() method in " .. main, vim.log.levels.WARN)
        end)
      end)
    end
    local function rerun(debug)
      local last = vim.g.java_last_run
      if not last then return run_this_class(debug) end
      require("dap").run(vim.tbl_extend("force", last, { noDebug = not debug }))
      if not debug then require("dap").repl.open() end
    end
    if #bundles > 0 then
      map("<C-S-F10>", function() run_this_class(false) end, "Run this class (Ctrl+Shift+F10)")
      map("<S-F10>",   function() rerun(false) end,          "Run (Shift+F10)")
      map("<S-F9>",    function() rerun(true) end,           "Debug (Shift+F9)")
    end

    -- Test running (requires vscode-java-test bundle — currently disabled,
    -- see has_test_bundle comment above)
    if has_test_bundle then
      local dap = require("jdtls.dap")
      map("<leader>jt", function() dap.test_nearest_method() end,  "Test nearest method")
      map("<leader>jT", function() dap.test_class() end,           "Test class")
    end

    -- Update project config when build files change
    map("<leader>ju", jdtls.update_project_config, "Update project config")
  end,
}

-- start_or_attach is idempotent: reattaches to existing server for the same project
local start_ok, start_err = pcall(function() require("jdtls").start_or_attach(config) end)
if not start_ok then
  vim.notify("jdtls: failed to start — " .. tostring(start_err), vim.log.levels.WARN)
end
