-- =========================================================
-- Basic editor options
-- =========================================================
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set("n", "<leader>n", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative line numbers" })

-- =========================================================
-- Bootstrap lazy.nvim
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out .. "\n", "WarningMsg" },
      { "Make sure git is installed and the instance has internet access.\n", "Normal" },
    }, true, {})
    return
  end
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
    lazy = false, -- load during startup so configs module exists
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.api.nvim_echo({
          { "nvim-treesitter not available yet. Run :Lazy sync and restart.\n", "WarningMsg" },
        }, true, {})
        return
      end

      configs.setup({
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
  -- OSC52 clipboard (EC2 -> Mac over SSH)
  -- =======================
  {
    "ojroques/nvim-osc52",
    lazy = false,
    config = function()
      local ok, osc52 = pcall(require, "osc52")
      if not ok then
        vim.api.nvim_echo({
          { "nvim-osc52 not available yet. Run :Lazy sync and restart.\n", "WarningMsg" },
        }, true, {})
        return
      end

      osc52.setup({
        max_length = 0,
        silent = true,
        trim = false,
      })

      -- When you yank normally (yy, yw, visual+y), copy to + using OSC52
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            osc52.copy_register("+")
          end
        end,
      })

      -- Optional explicit copy mappings
      vim.keymap.set("n", "<leader>y", osc52.copy_operator, { expr = true, desc = "OSC52 copy operator" })
      vim.keymap.set("v", "<leader>y", osc52.copy_visual, { desc = "OSC52 copy visual" })
    end,
  },
})
