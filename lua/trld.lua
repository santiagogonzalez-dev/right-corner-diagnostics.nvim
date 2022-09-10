local config = require 'trld.config'
local utils = require 'trld.utils'
local M = {}

function M.show(opts, bufnr, line_nr)
   bufnr = bufnr or 0
   line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
   opts = opts or { ['lnum'] = line_nr }

   local ns = vim.api.nvim_create_namespace 'trld'
   local diag_ns = vim.diagnostic.get_namespace(ns)

   local line_diags = vim.diagnostic.get(bufnr, opts)

   -- clear and exit namespace if line has no diagnostics
   if vim.tbl_isempty(line_diags) then
      if diag_ns.user_data.diags then
         vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      end
      return
   end

   if diag_ns.user_data.last_line_nr == line_nr and diag_ns.user_data.diags then
      return
   end

   diag_ns.user_data.diags = true
   diag_ns.user_data.last_line_nr = line_nr

   utils.display_diagnostics(line_diags, bufnr, ns, config.config.position)
end

function M.hide(bufnr)
   bufnr = bufnr or 0
   local namespace = vim.api.nvim_get_namespaces()['trld']
   if namespace == nil then
      return
   end
   local ns = vim.diagnostic.get_namespace(namespace)
   if ns.user_data.diags then
      vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
   end
   ns.user_data.diags = false
end

M.setup = function(cfg)
   config.merge_configs(cfg or {})

   if config.config.auto_cmds then
      local au_trld = vim.api.nvim_create_augroup('trld', { clear = false })

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
         group = au_trld,
         callback = function()
            M.show()
         end,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
         group = au_trld,
         callback = function()
            M.hide()
         end,
      })
   end
end

return M
