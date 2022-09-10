# right-corner-diagnostics.nvim

This plugins is a [fork](https://github.com/Mofiqul/trld.nvim) that aims to be a
little bit simpler for the user and for whoever that wants to .

## What does it do?
There's various ways of viewing diagnostics in Neovim, but I really liked this
implementation that simply uses virtual text to show the diagnostics at either
top or bottom of the buffer, instead of the default virtual text at the end of
the line.

## Preview
![Diagnostics being displayed](https://github.com/santigo-zero/tests/blob/master/Screenshot_20220910_190828.png?raw=true "Diagnostics being display at the bottom of the screen")

## Highlight groups
In the original [trld.nvim](https://github.com/Mofiqul/trld.nvim) there was a
possibility of defining the highlight groups for the plugin to make use of, but
I decided to hard code the groups to be: `DiagnosticVirtualTextError`,
`DiagnosticVirtualTextWarn`, `DiagnosticVirtualTextInfo` and
`DiagnosticVirtualTextHint` so it's very probable that your colorscheme already
supports them.

## Installation and Configuration

```lua
-- Packer
use {
  'santigo-zero/right-corner-diagnostics.nvim',
  event = 'LspAttach',
  config = function()
    -- Default config
    require('rcd').setup {
      -- Where to render the diagnostics: top or bottom, the latter sitting at
      -- the bottom line of the buffer, not of the terminal.
      position = 'top',

      -- In order to print the diagnostics we need to use autocommands, you can
      -- disable this behaviour and call the functions yourself if you think
      -- your autocmds work better than the default ones with this option:
      auto_cmds = true,
    }

    -- If you don't have it in your config already you can disable the virtual
    -- text at the end of the line with this line:
    vim.diagnostic.config({ virtual_text = false })
  end,
}
```

### Showing the diagnostics with autocommands
If you found a better way of showing diagnostics please consider opening an
issue, this are the defaults that are going to be used:

```lua
local au_rcd = vim.api.nvim_create_augroup('right_corner_diagnostics', {})

vim.api.nvim_create_autocmd({
  'CursorHold',
  'CursorHoldI',
}, {
  group = au_rcd,
  callback = require('rcd').show,
})

vim.api.nvim_create_autocmd({
  'CursorMoved',
  'CursorMovedI',
}, {
  group = au_rcd,
  callback = require('rcd').hide,
})
```
