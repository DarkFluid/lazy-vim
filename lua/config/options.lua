-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.snacks_animate = false

-- Ensure the swap-file directory exists (snacks.explorer E303 fix)
local swap_dir = vim.fn.stdpath("state") .. "/swap"
if vim.fn.isdirectory(swap_dir) == 0 then
  vim.fn.mkdir(swap_dir, "p")
end
vim.opt.directory = swap_dir .. "//"
