local utils = {}

local config = require 'trld.config'

-- Return higlight group name based on the lsp diagnostic severity.
---@param level number @ For example `vim.diagnostic.severity.ERROR` returns `1`
---@return string @ The return string is going to match with the `highlights`
---table, for example `DiagnosticVirtualTextError`
utils.get_hl_by_severity = function(level)
   local highlights = {
      error = 'DiagnosticVirtualTextError',
      warn = 'DiagnosticVirtualTextWarn',
      info = 'DiagnosticVirtualTextInfo',
      hint = 'DiagnosticVirtualTextHint',
   }

   local list_severity = {
      [vim.diagnostic.severity.ERROR] = 'error',
      [vim.diagnostic.severity.WARN] = 'warn',
      [vim.diagnostic.severity.INFO] = 'info',
      [vim.diagnostic.severity.HINT] = 'hint',
   }

   local severity = list_severity[level]

   return highlights[severity]
end

-- Reverse a table
---@param T table
---@return table @ It's the same table that we used as a param
utils.reverse_table = function(T)
   for i = 1, math.floor(#T / 2) do
      local j = #T - i + 1
      T[i], T[j] = T[j], T[i]
   end
   return T
end

-- display diagnostics
utils.display_diagnostics = function(diags, bufnr, ns, pos)
   local win_info = vim.fn.getwininfo(vim.fn.win_getid())[1]

   -- reverse diag order if rendering on the bottom
   if pos == 'bottom' then
      diags = utils.reverse_table(diags)
   end

   -- render each diag
   for i, diag in ipairs(diags) do
      local msgs = config.config.formatter(diag)
      for j, msg in ipairs(msgs) do
         local x = nil
         if pos == 'top' then
            x = (win_info.topline - 3) + (i + j)
            if win_info.botline < x then
               return
            end
         elseif pos == 'bottom' then
            x = win_info.botline - (i + j)
            if win_info.topline > x then
               return
            end
         end
         vim.api.nvim_buf_set_extmark(bufnr, ns, x, 0, {
            virt_text = msg,
            virt_text_pos = 'right_align',
            virt_lines_above = true,
            strict = false,
         })
      end
   end
end

return utils
