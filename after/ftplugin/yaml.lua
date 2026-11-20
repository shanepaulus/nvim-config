-- Enter / o after a `# comment` starts a plain line, not another comment
-- (runtime ftplugin/yaml.vim adds `r` and `o` to formatoptions).
vim.opt_local.formatoptions:remove({ "r", "o" })
