local M = {}

-- default config
M.default_config = {
   position = 'top',
   auto_cmds = true,
}

-- config
M.config = {}

---@param user_configs table
---@return nil
M.merge_configs = function(user_configs)
   M.config = vim.tbl_deep_extend('force', M.default_config, user_configs or {})
end

return M
