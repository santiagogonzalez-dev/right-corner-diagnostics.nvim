local M = {}

-- default config
M.default_config = {
   position = 'top',
   auto_cmds = true,
   formatter = function(diag)
      local u = require 'trld.utils'
      local diag_lines = {}

      for line in diag.message:gmatch '[^\n]+' do
         line = line:gsub('[ \t]+%f[\r\n%z]', '')
         table.insert(diag_lines, line)
      end

      local lines = {}
      for _, diag_line in ipairs(diag_lines) do
         table.insert(lines, { { diag_line .. ' ', u.get_hl_by_severity(diag.severity) } })
      end

      return lines
   end,
}

-- config
M.config = {}

---@param user_configs table
---@return nil
M.merge_configs = function(user_configs)
   M.config = vim.tbl_deep_extend('force', M.default_config, user_configs or {})
end

return M
