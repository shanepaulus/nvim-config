-- Don't re-indent the line while typing `:` (runtime indent/yaml.vim does,
-- and after a comment line it jumps the key to the wrong column).
-- Indent is still computed on Enter / o / O.
vim.opt_local.indentkeys:remove("<:>")
