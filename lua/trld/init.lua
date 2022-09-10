local M = {}

M.config = {}

M.default_config = {
   position = 'top',
   auto_cmds = true,
}

function M.show(opts, bufnr, line_nr)
   bufnr = bufnr or 0
   line_nr = line_nr or (vim.api.nvim_win_get_cursor(0)[1] - 1)
   opts = opts or { ['lnum'] = line_nr }

   local ns_trld = vim.api.nvim_create_namespace 'trld'
   local diag_ns = vim.diagnostic.get_namespace(ns_trld)

   local line_diags = vim.diagnostic.get(bufnr, opts)

   -- Clear and exit namespace if line has no diagnostics.
   if vim.tbl_isempty(line_diags) then
      if diag_ns.user_data.diags then
         vim.api.nvim_buf_clear_namespace(bufnr, ns_trld, 0, -1)
      end
      return
   end

   if diag_ns.user_data.last_line_nr == line_nr and diag_ns.user_data.diags then
      return
   end

   diag_ns.user_data.diags = true
   diag_ns.user_data.last_line_nr = line_nr

   require('trld.utils').display_diagnostics(line_diags, bufnr, ns_trld, M.config.position)
end

---@param bufnr integer|nil
function M.hide(bufnr)
   bufnr = bufnr or 0
   local ns_trld = vim.api.nvim_get_namespaces()['trld']

   if not ns_trld then
      return
   end

   local diag_ns = vim.diagnostic.get_namespace(ns_trld)
   if diag_ns.user_data.diags then
      vim.api.nvim_buf_clear_namespace(bufnr, ns_trld, 0, -1)
   end
   diag_ns.user_data.diags = false
end

-- Setup function
---@param user_config table
M.setup = function(user_config)
   M.config = vim.tbl_deep_extend('force', M.default_config, user_config or {})

   -- Enable autocmds?
   if M.config.auto_cmds then
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
            M.hide(vim.api.nvim_get_current_buf())
         end,
      })
   end
end

return M
