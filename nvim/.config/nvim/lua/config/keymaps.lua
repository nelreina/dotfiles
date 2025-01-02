-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap
local opts = { noremap = true, silent = true }
-- keymap.set("n", "<leader>f", ":NvimTreeToggle<CR>", opts)
-- keymap.set("n", "<leader>m", ":NvimTreeFocus<CR>", opts)
keymap.set("n", "<leader>q", ":q<CR>", opts) -- Close the current window
keymap.set("n", "<leader>Q", ":qa<CR>", opts) -- Close all windows

vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-H>", "copilot#Previous()", { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-K>", "copilot#Next()", { silent = true, expr = true })
vim.cmd("wincmd L")
