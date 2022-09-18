local M = {}

M.config = {}

M.default_config = {
   position = 'top',
   auto_cmds = true,
}

function M.show()
   local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1

   local ns_rcd = vim.api.nvim_create_namespace 'right_corner_diagnostics'
   local diag_ns = vim.diagnostic.get_namespace(ns_rcd)

   local line_diags = vim.diagnostic.get(0, { lnum = line_nr })

   -- Clear and exit namespace if line has no diagnostics.
   if vim.tbl_isempty(line_diags) then
      if diag_ns.user_data.diags then
         vim.api.nvim_buf_clear_namespace(0, ns_rcd, 0, -1)
      end
      return
   end

   if diag_ns.user_data.last_line_nr == line_nr and diag_ns.user_data.diags then
      return
   end

   diag_ns.user_data.diags = true
   diag_ns.user_data.last_line_nr = line_nr

   require('rcd.utils').display_diagnostics(line_diags, 0, ns_rcd, M.config.position)
end

function M.hide()
   local ns_rcd = vim.api.nvim_get_namespaces()['right_corner_diagnostics']

   if not ns_rcd then
      return
   end

   local diag_ns = vim.diagnostic.get_namespace(ns_rcd)
   if diag_ns.user_data.diags then
      vim.api.nvim_buf_clear_namespace(0, ns_rcd, 0, -1)
   end
   diag_ns.user_data.diags = false
end

-- Setup function
---@param user_config table
M.setup = function(user_config)
   M.config = vim.tbl_deep_extend('keep', user_config or {}, M.default_config)

   if M.config.auto_cmds then
      local au_rcd = vim.api.nvim_create_augroup('right_corner_diagnostics', {})
      local show_autocmds = { 'TextChanged', 'CursorHold', 'CursorHoldI' }
      local hide_autocmds = { 'CursorMoved', 'CursorMovedI' }

      if vim.diagnostic.config().update_in_insert == false then
         table.remove(show_autocmds) -- Remove `CursorHoldI` from the table.
         table.remove(hide_autocmds) -- Remove `CursorMovedI` from the table.

         table.insert(show_autocmds, 'InsertLeave')
         table.insert(hide_autocmds, 'InsertEnter')
      end

      vim.api.nvim_create_autocmd(show_autocmds, {
         group = au_rcd,
         callback = function()
            vim.defer_fn(function()
               M.show()
            end, 100)
         end,
      })

      vim.api.nvim_create_autocmd(hide_autocmds, {
         group = au_rcd,
         callback = M.hide,
      })
   end
end

return M
