vim.cmd "packadd packer.nvim"

-- load plugin after entering vim ui
local packer_lazy_load = function(plugin, timer)
  if plugin then
      timer = timer or 0
      vim.defer_fn(function()
         require("packer").loader(plugin)
      end, timer)
   end
end


local function lazy_load_packer()
    local present, packer = pcall(require, "packer")

    if not present then
       local packer_path = vim.fn.stdpath "data" .. "/site/pack/packer/opt/packer.nvim"

       print "Cloning packer.."
       -- remove the dir before cloning
       vim.fn.delete(packer_path, "rf")
       vim.fn.system {
          "git",
          "clone",
          "https://github.com/wbthomason/packer.nvim",
          "--depth",
          "20",
          packer_path,
       }

       vim.cmd "packadd packer.nvim"
       present, packer = pcall(require, "packer")

       if present then
          print "Packer cloned successfully."
       else
          error("Couldn't clone packer !\nPacker path: " .. packer_path .. "\n" .. packer)
       end
    end

    packer.init {
       display = {
          open_fn = function()
             return require("packer.util").float { border = "single" }
          end,
          prompt_border = "single",
       },
       git = {
          clone_timeout = 6000, -- seconds
       },
       auto_clean = true,
       compile_on_sync = true,
       snapshot = utils,
    }

    return packer
end

local present, packer = pcall(lazy_load_packer)

if not present then
   return false
end

local plugins = {
    {"nvim-lua/plenary.nvim"},
    {"lewis6991/impatient.nvim"},

    {
        "wbthomason/packer.nvim",
        event = "VimEnter",
    },

    {
        "feline-nvim/feline.nvim",
      config = function()
         require "my_feline_config"
      end,
   },

   {
       "lukas-reineke/indent-blankline.nvim",
      event = "BufRead",
      config = function()
          local blankline = require "indent_blankline"
          local options = {
              indentLine_enabled = 1,
              char = "▏",
              filetype_exclude = {
                 "help",
                 "terminal",
                 "alpha",
                 "packer",
                 "lspinfo",
                 "TelescopePrompt",
                 "TelescopeResults",
                 "nvchad_cheatsheet",
                 "lsp-installer",
                 "",
              },
              buftype_exclude = { "terminal" },
              show_trailing_blankline_indent = false,
              show_first_indent_level = false,
           }
           blankline.setup(options)
      end,
   },

   {
       "NvChad/nvim-colorizer.lua",
      event = "BufRead",
      config = function()
          require("colorizer").setup()
      end,
   },

   {
   "nvim-treesitter/nvim-treesitter",
      event = { "BufRead", "BufNewFile" },
      run = ":TSUpdate",
      config = function()
          local treesitter = require("nvim-treesitter.configs")
          local options = {
              ensure_installed = {
                  "lua",
                  "vim",
              },
              highlight = {
                  enable = true,
                  use_languagetree = tree,
              },
          }
          treesitter.setup(options)
      end,
   },

   {
      "neovim/nvim-lspconfig",
      module = "lspconfig",
      config = function()
         require "my_lsp_config"
      end,
   },

   -- {
   --     "andymass/vim-matchup",
   --    opt = true,
   --    setup = function()
   --       packer_lazy_load "vim-matchup"
   --    end,
   -- },

   -- load luasnips + cmp related in insert mode only
   {
   "rafamadriz/friendly-snippets",
      module = "cmp_nvim_lsp",
      event = "InsertEnter",
   },

   {
   "hrsh7th/nvim-cmp",
      after = "friendly-snippets",
      config = function()
         require "my_cmp_config"
      end,
   },

   {
       "L3MON4D3/LuaSnip",
      wants = "friendly-snippets",
      after = "nvim-cmp",
      config = function()
           local present, luasnip = pcall(require, "luasnip")

           if not present then
              return
           end

           luasnip.config.set_config {
              history = true,
              updateevents = "TextChanged,TextChangedI",
           }

           require("luasnip.loaders.from_vscode").lazy_load()
      end,
   },

   {
       "saadparwaiz1/cmp_luasnip",
      after = "LuaSnip",
   },

   {
       "hrsh7th/cmp-nvim-lua",
      after = "cmp_luasnip",
   },

   {
       "hrsh7th/cmp-nvim-lsp",

      after = "cmp-nvim-lua",
   },

   {
       "hrsh7th/cmp-buffer",
      after = "cmp-nvim-lsp",
   },

   {
       "hrsh7th/cmp-path",
      after = "cmp-buffer",
   },

   -- misc plugins
   {
       "windwp/nvim-autopairs",
      after = "nvim-cmp",
      config = function()
           local present1, autopairs = pcall(require, "nvim-autopairs")
           local present2, cmp = pcall(require, "cmp")

           if not present1 and present2 then
              return
           end

           autopairs.setup {
              fast_wrap = {},
              disable_filetype = { "TelescopePrompt", "vim" },
           }

           local cmp_autopairs = require "nvim-autopairs.completion.cmp"

           cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
   },

   {
       "numToStr/Comment.nvim",
      module = "Comment",
      keys = { "gc", "gb" },

      setup = function()
         require("my_mappings").comment()
      end,

      config = function()
          require("Comment").setup()
      end,
   },

   -- file managing , picker etc
   {
       "kyazdani42/nvim-tree.lua",
      cmd = { "NvimTreeToggle", "NvimTreeFocus" },
      setup = function()
         require("my_mappings").nvimtree()
      end,

      config = function()
         require "my_nvimtree_config"
      end,
   },

   {
       "nvim-telescope/telescope.nvim",
      cmd = "Telescope",

      setup = function()
         require("my_mappings").telescope()
      end,

      config = function()
         require "my_telescope_config"
      end,
   },

   {
       "folke/which-key.nvim",
       config = function()
           local present, whichkey = pcall(require, "which-key")
           if not present then
               return
           end
           whichkey.setup{}
       end
   },

   {
       "dracula/vim",
   }
}

return packer.startup(function(use)
   for _, v in pairs(plugins) do
      use(v)
   end
end)
