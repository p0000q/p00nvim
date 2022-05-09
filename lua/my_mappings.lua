local M = {}
local present, wk = pcall(require, "which-key")
if not present then
    print("which-key cannot be loaded")
    return M
end

local map = function(mode, keys, command, opt)
   local options = { silent = true }

   if opt then
      options = vim.tbl_extend("force", options, opt)
   end

   if type(keys) == "table" then
      for _, keymap in ipairs(keys) do
         M.map(mode, keymap, command, opt)
      end
      return
   end

   vim.keymap.set(mode, keys, command, opt)
end

local cmd = vim.cmd
local user_cmd = vim.api.nvim_create_user_command

-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
-- http<cmd> ://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
-- empty mode is same as using <cmd> :map
-- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour

map({ "n", "x", "o" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map({ "n", "x", "o" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
map("", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- use ESC to turn off search highlighting
map("n", "<Esc>", "<cmd> :noh <CR>")

-- move cursor within insert mode
map("i", "<C-h>", "<Left>")
map("i", "<C-e>", "<End>")
map("i", "<C-l>", "<Right>")
map("i", "<C-j>", "<Down>")
map("i", "<C-k>", "<Up>")
map("i", "<C-a>", "<ESC>^i")

-- navigation between windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-j>", "<C-w>j")
wk.register({
    ["<leader>wq"] = { "<cmd> :q <CR>", "quit window"},
    ["<leader>wo"] = { "<cmd> :only <CR>", "only window"},
})

-- Add Packer commands because we are not loading it at startup

local packer_cmd = function(callback)
   return function()
      require "my_plugins"
      require("packer")[callback]()
   end
end

-- snapshot stuff
user_cmd("PackerSnapshot", function(info)
   require "my_plugins"
   require("packer").snapshot(info.args)
end, { nargs = "+" })

user_cmd("PackerSnapshotDelete", function(info)
   require "my_plugins"
   require("packer.snapshot").delete(info.args)
end, { nargs = "+" })

user_cmd("PackerSnapshotRollback", function(info)
   require "my_plugins"
   require("packer").rollback(info.args)
end, { nargs = "+" })

user_cmd("PackerClean", packer_cmd "clean", {})
user_cmd("PackerCompile", packer_cmd "compile", {})
user_cmd("PackerInstall", packer_cmd "install", {})
user_cmd("PackerStatus", packer_cmd "status", {})
user_cmd("PackerSync", packer_cmd "sync", {})
user_cmd("PackerUpdate", packer_cmd "update", {})

-- --------------------- plugin mappings below

M.comment = function()
   map("n", "<leader>/", "<cmd> :lua require('Comment.api').toggle_current_linewise()<CR>")
   map("v", "<leader>/", "<esc><cmd> :lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>")
end

M.nvimtree = function()
   wk.register({
       ["<leader>e"] = {"<cmd> :NvimTreeToggle<CR>", "nvimtree"},
   })
end

M.telescope = function()
    wk.register({
        ["<leader>fb"] = { "<cmd> :Telescope buffers <CR>", "buffers"},
        ["<leader>ff"] = { "<cmd> :Telescope find_files<CR>", "files"},
        ["<leader>fh"] = { "<cmd> :Telescope help_tags<CR>", "tags"},
        ["<leader>fw"] = { "<cmd> :Telescope live_grep<CR>", "tags"},
        ["<leader>fs"] = { "<cmd> :Telescope grep_string<CR>", "tags"},
    })
end

M.lspconfig = function()
   -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions
   wk.register({
       g = {
           name = "lsp-goto",
           D = { function() vim.lsp.buf.declaration() end, "declaration"},
           d = { function() vim.lsp.buf.definition() end, "definition"},
           i = { function() vim.lsp.buf.implementation() end, "implementation" },
           r = { function() vim.lsp.buf.references() end, "references"},
       },
       ["C-k"] = { function() vim.lsp.buf.signature_help() end },
       ["<leader>ca"] = { function() vim.lsp.buf.code_acton() end, "code action"},
       ["<leader>cr"] = { function() vim.lsp.buf.rename() end, "rename"},
       ["<leader>cf"] = { function() vim.lsp.buf.formatting() end, "formatiting"},
       ["<leader>k"] = { function() vim.lsp.buf.hover() end, "hover" },
  })
end

M.hopKeys = function()
    vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
    vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
    vim.api.nvim_set_keymap('o', 'f', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true })<cr>", {})
    vim.api.nvim_set_keymap('o', 'F', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true })<cr>", {})
    vim.api.nvim_set_keymap('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", {})
    vim.api.nvim_set_keymap('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", {})
    vim.api.nvim_set_keymap('n', '<leader>e', "<cmd> lua require'hop'.hint_words({ hint_position = require'hop.hint'.HintPosition.END })<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>e', "<cmd> lua require'hop'.hint_words({ hint_position = require'hop.hint'.HintPosition.END })<cr>", {})
    vim.api.nvim_set_keymap('o', '<leader>e', "<cmd> lua require'hop'.hint_words({ hint_position = require'hop.hint'.HintPosition.END, inclusive_jump = true })<cr>", {})
end
        -- ["<leader>fs"] = { "<cmd> :Telescope grep_string<CR>", "tags"},
    wk.register({
        ["<leader>j"] = {"<cmd> :HopLine<CR>", "jump to line"}
    })

return M

