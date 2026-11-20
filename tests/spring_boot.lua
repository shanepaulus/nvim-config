-- application.yml in a Spring Boot project must offer property completion
-- (server.*, spring.jpa.*, ...) taken from the project's own classpath.
-- Only the yml buffer is opened: no Java file has to be open first.
--
--   nvim --headless -i NONE -c "luafile tests/spring_boot.lua"
--
-- Slow (jdtls imports a Maven project, up to a few minutes on first run).
-- Exits non-zero if any check fails.

local failed = 0
local function out(s) io.stdout:write(s .. "\n") end

-- Minimal Spring Boot Maven project with web + JPA starters.
local dir = vim.fn.tempname()
vim.fn.mkdir(dir .. "/src/main/java/demo", "p")
vim.fn.mkdir(dir .. "/src/main/resources", "p")
vim.fn.writefile({
  '<?xml version="1.0" encoding="UTF-8"?>',
  '<project xmlns="http://maven.apache.org/POM/4.0.0">',
  "  <modelVersion>4.0.0</modelVersion>",
  "  <parent>",
  "    <groupId>org.springframework.boot</groupId>",
  "    <artifactId>spring-boot-starter-parent</artifactId>",
  "    <version>4.1.2</version>",
  "    <relativePath/>",
  "  </parent>",
  "  <groupId>demo</groupId>",
  "  <artifactId>demo</artifactId>",
  "  <version>0.0.1</version>",
  "  <dependencies>",
  "    <dependency>",
  "      <groupId>org.springframework.boot</groupId>",
  "      <artifactId>spring-boot-starter-webmvc</artifactId>",
  "    </dependency>",
  "    <dependency>",
  "      <groupId>org.springframework.boot</groupId>",
  "      <artifactId>spring-boot-starter-data-jpa</artifactId>",
  "    </dependency>",
  "  </dependencies>",
  "</project>",
}, dir .. "/pom.xml")
vim.fn.writefile({
  "package demo;",
  "",
  "import org.springframework.boot.autoconfigure.SpringBootApplication;",
  "",
  "@SpringBootApplication",
  "public class DemoApplication {}",
}, dir .. "/src/main/java/demo/DemoApplication.java")
vim.fn.writefile({ "spring:", "  application:", "    name: demo", "" },
  dir .. "/src/main/resources/application.yml")

vim.cmd.edit(dir .. "/src/main/resources/application.yml")
local buf = vim.api.nvim_get_current_buf()

local function check(name, ok, detail)
  if ok then
    out("PASS  " .. name)
  else
    failed = failed + 1
    out("FAIL  " .. name .. (detail and (": " .. detail) or ""))
  end
end

local function client(name)
  return vim.lsp.get_clients({ bufnr = buf, name = name })[1]
end

check("spring-boot LS attaches to application.yml",
  (vim.wait(30000, function() return client("spring-boot") ~= nil end, 200)))
check("jdtls starts for the project (classpath source)",
  (vim.wait(30000, function() return #vim.lsp.get_clients({ name = "jdtls" }) > 0 end, 200)))

-- Completion labels for `text` typed on a new last line.
local function labels(text)
  local last = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_set_lines(buf, last - 1, last, false, { text })
  local c = client("spring-boot")
  if not c then return {} end
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(buf) },
    position = { line = last - 1, character = #text },
  }
  local resp = c:request_sync("textDocument/completion", params, 10000, buf)
  local result = resp and resp.result or {}
  local items = result.items or result
  local found = {}
  for _, item in ipairs(items) do found[#found + 1] = item.label end
  return found
end

local function wait_for_label(text, want)
  local got = {}
  local ok = vim.wait(300000, function()
    got = labels(text)
    return vim.tbl_contains(got, want)
  end, 3000)
  return ok, ("labels for %q: %s"):format(text, table.concat(vim.list_slice(got, 1, 10), ", "))
end

check("server.* completion", wait_for_label("server.po", "server.port"))
check("spring.jpa.* completion (from JPA starter on classpath)",
  wait_for_label("spring.jpa.show", "spring.jpa.show-sql"))

vim.cmd(failed == 0 and "qa!" or "cq")
