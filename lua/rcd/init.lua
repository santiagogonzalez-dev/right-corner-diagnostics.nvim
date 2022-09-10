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
   M.config = vim.tbl_deep_extend('force', M.default_config, user_config or {})

   -- Enable autocmds?
   if M.config.auto_cmds then
      local au_rcd = vim.api.nvim_create_augroup('right_corner_diagnostics', { clear = false })

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
         group = au_rcd,
         callback = function()
            M.show()
         end,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
         group = au_rcd,
         callback = function()
            M.hide()
         end,
      })
   end
end

return M
