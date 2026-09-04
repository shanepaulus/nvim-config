-- Runs automatically when any *.java buffer opens (Neovim FileType autocmd).
-- Uses nvim-jdtls instead of the standard lspconfig pattern because jdtls
-- requires per-buffer workspace isolation.

local ok, jdtls = pcall(require, "jdtls")
if not ok then return end

-- ── 1. Detect JDK home ───────────────────────────────────────────────────────
-- Tries, in order: $JAVA_HOME, macOS's java_home tool, `java` on PATH.
-- No OS-specific path is ever assumed to exist — every candidate is verified
-- with isdirectory() before use, since a wrong guess here breaks jdtls silently.
local function get_java_home()
  local env_home = vim.env.JAVA_HOME
  if env_home and env_home ~= "" and vim.fn.isdirectory(env_home) == 1 then
    return env_home
  end

  if vim.fn.has("mac") == 1 and vim.fn.executable("/usr/libexec/java_home") == 1 then
    local mac_home = vim.trim(vim.fn.system("/usr/libexec/java_home 2>/dev/null"))
    if vim.v.shell_error == 0 and mac_home ~= "" and vim.fn.isdirectory(mac_home) == 1 then
      return mac_home
    end
  end

  if vim.fn.executable("java") == 1 then
    local result = vim.fn.system("java -XshowSettings:all -version 2>&1")
    local home = result:match("java%.home%s*=%s*(.-)%s*\n")
      or result:match("java%.home%s*=%s*(.-)%s*$")
    if home and vim.fn.isdirectory(home) == 1 then
      return home
    end
  end

  return nil
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
  local dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
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

  return gradle_root or maven_root or nearest_build or git_root
end

local root_dir = find_project_root()
if not root_dir then
  vim.notify(
    "jdtls: no project root found (looked for build.gradle(.kts)/pom.xml/.git/mvnw/gradlew).\n"
      .. "Not starting jdtls for a standalone file.",
    vim.log.levels.WARN
  )
  return
end

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
            name = "JavaSE-25",
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

    -- ── LSP keymaps (same as other LSPs, set here for Java buffers) ───────────
    local tb = require("telescope.builtin")

    map("<C-b>",   vim.lsp.buf.definition,  "Go to definition (Ctrl+B)")
    map("<C-b>",   vim.lsp.buf.definition,  "Go to definition (Ctrl+B)", "i")
    map("<C-A-b>", vim.lsp.buf.implementation, "Go to implementation (Ctrl+Alt+B)")
    map("<C-A-b>", vim.lsp.buf.implementation, "Go to implementation (Ctrl+Alt+B)", "i")
    map("<A-F7>",  tb.lsp_references,       "Find usages (Alt+F7)")
    map("<C-S-i>", vim.lsp.buf.hover,       "Hover doc (Ctrl+Shift+I)")
    map("<C-S-i>", vim.lsp.buf.hover,       "Hover doc (Ctrl+Shift+I)", "i")
    map("<A-CR>",  vim.lsp.buf.code_action, "Code action (Alt+Enter)")
    map("<A-CR>",  vim.lsp.buf.code_action, "Code action (Alt+Enter)", "i")
    map("<S-F6>",  vim.lsp.buf.rename,      "Rename (Shift+F6)")
    map("<C-F12>", tb.lsp_document_symbols, "File structure (Ctrl+F12)")

    -- ── Java-specific IntelliJ keymaps ─────────────────────────────────────────
    -- IntelliJ: Alt+Insert → Generate (constructors, getters, toString, etc.)
    -- jdtls has no standalone `generate()` function (that name only exists
    -- under `jdtls.tests`, for generating test scaffolding) — its "generate
    -- constructor/toString/equals&hashCode/delegate" actions are surfaced as
    -- regular LSP code actions, so this opens the code-action menu.
    map("<A-Insert>", vim.lsp.buf.code_action, "Generate code (Alt+Insert)")
    map("<A-Insert>", vim.lsp.buf.code_action, "Generate code (Alt+Insert)", "i")

    -- IntelliJ: Ctrl+Alt+O → Optimize / organize imports
    map("<C-A-o>", jdtls.organize_imports, "Organize imports (Ctrl+Alt+O)")
    map("<C-A-o>", jdtls.organize_imports, "Organize imports (Ctrl+Alt+O)", "i")

    -- Extract refactorings (no direct IntelliJ equivalent, via <leader>j)
    map("<leader>jv", jdtls.extract_variable, "Extract variable")
    map("<leader>jv", jdtls.extract_variable, "Extract variable", "v")
    map("<leader>jm", jdtls.extract_method,   "Extract method")
    map("<leader>jm", jdtls.extract_method,   "Extract method", "v")
    map("<leader>jc", jdtls.extract_constant, "Extract constant")

    -- Test running (requires vscode-java-test bundle — currently disabled,
    -- see has_test_bundle comment above)
    -- test_nearest_method runs with DAP attached (noDebug=false by default)
    -- pass noDebug=true for a plain run without the debugger
    if has_test_bundle then
      local dap = require("jdtls.dap")
      -- IntelliJ: Shift+F10 → Run test (no debugger)
      map("<S-F10>", function() dap.test_nearest_method({ config_overrides = { noDebug = true } }) end,  "Run test method (Shift+F10)")
      -- IntelliJ: Shift+F9 → Debug test (with debugger attached)
      map("<S-F9>",  function() dap.test_nearest_method() end, "Debug test method (Shift+F9)")
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
