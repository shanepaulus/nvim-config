-- Spring Boot property completion in application*.yml / application*.properties
-- (server.*, spring.jpa.*, and every @ConfigurationProperties on the project's
-- classpath). The Spring Boot LS (Mason: vscode-spring-boot-tools) gets that
-- classpath from jdtls, via the jdtls bundle added in ftplugin/java.lua.
return {
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = { "mfussenegger/nvim-jdtls", "williamboman/mason.nvim" },
    opts = {},
    config = function(_, opts)
      require("spring_boot").setup(opts)

      -- jdtls only starts from ftplugin/java.lua, so opening just application.yml
      -- would give the Spring Boot LS no classpath and no completions. Load one of
      -- the project's Java files into a hidden buffer to start jdtls for it.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("spring_boot_start_jdtls", { clear = true }),
        pattern = { "yaml", "jproperties" },
        callback = function(event)
          local name = vim.api.nvim_buf_get_name(event.buf)
          if not vim.fs.basename(name):match("^application.*%.") then return end
          if #vim.lsp.get_clients({ name = "jdtls" }) > 0 then return end

          local root = vim.fs.root(name, { "pom.xml", "build.gradle", "build.gradle.kts" })
          if not root then return end
          local java = vim.fn.globpath(root, "src/main/java/**/*.java", false, true)[1]
          if not java then return end

          vim.schedule(function()
            vim.fn.bufload(vim.fn.bufadd(java))
          end)
        end,
      })
    end,
  },
}
