local config = require 'trld.config'
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

   require('trld.utils').display_diagnostics(line_diags, bufnr, ns, config.config.position)
end

function M.hide(bufnr)
   bufnr = bufnr or 0
   local _ns_trld = vim.api.nvim_get_namespaces()['trld']

   if not _ns_trld then
      return
   end

   local ns_trld = vim.diagnostic.get_namespace(_ns_trld)
   if ns_trld.user_data.diags then
      vim.api.nvim_buf_clear_namespace(bufnr, _ns_trld, 0, -1)
   end
   ns_trld.user_data.diags = false
end

---@param user_configs table
M.setup = function(user_configs)
   config.merge_configs(user_configs or {})

   -- Enable autocmds?
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
