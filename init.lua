-- =========================================================
-- Basic editor options
-- =========================================================
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true

-- Toggle relative line numbers
vim.keymap.set("n", "<leader>n", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative line numbers" })

-- =========================================================
-- Bootstrap lazy.nvim
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- Plugins
-- =========================================================
require("lazy").setup({

  -- =======================
  -- Tree-sitter (Python)
  -- =======================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python" },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },

  -- =======================
  -- OSC52 clipboard (SSH → Mac)
  -- =======================
  {
    "ojroques/nvim-osc52",
    config = function()
      local osc52 = require("osc52")

      osc52.setup({
        max_length = 0,
        silent = true,
        trim = false,
      })

      -- Copy yanks to macOS clipboard over SSH
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            osc52.copy_register("+")
          end
        end,
      })

      -- Optional explicit mappings
      vim.keymap.set("n", "<leader>y", osc52.copy_operator, { expr = true, desc = "OSC52 copy operator" })
      vim.keymap.set("v", "<leader>y", osc52.copy_visual, { desc = "OSC52 copy visual" })
    end,
  },

})

-- =========================================================
-- Clipboard behavior
-- =========================================================
-- NOTE:
-- Copy (yy / y) → goes to your Mac clipboard via OSC52
-- Paste (Cmd+V) → handled by your terminal
-- "+p is NOT used for pasting from Mac (security restriction)
