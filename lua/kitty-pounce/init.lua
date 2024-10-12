-- TODO: Only load when KITTY_IN_NVIM var is set
local M = {}

local kitty_mappings = {
  h = 'left',
  j = 'bottom',
  k = 'top',
  l = 'right',
}

local nvim_bindings = {
  Left = '<A-h>',
  Down = '<A-j>',
  Up = '<A-k>',
  Right = '<A-l>',
}

local function navigate(direction)
  local neighbor = vim.fn.winnr('1' .. direction)
  if vim.fn.winnr() ~= neighbor and vim.api.nvim_win_get_config(0).relative == '' then
    vim.api.nvim_command('wincmd ' .. direction)
  else
    -- TODO: Make kitten path configurable
    vim.fn.system('kitty @ kitten scripts/pounce.py ' .. kitty_mappings[direction])
  end
end

function M.setup()
  vim.api.nvim_create_user_command('NavigateLeft', function()
    navigate 'h'
  end, {})
  vim.api.nvim_create_user_command('NavigateDown', function()
    navigate 'j'
  end, {})
  vim.api.nvim_create_user_command('NavigateUp', function()
    navigate 'k'
  end, {})
  vim.api.nvim_create_user_command('NavigateRight', function()
    navigate 'l'
  end, {})

  -- TODO: Make keybinds configurable
  vim.api.nvim_set_keymap('n', nvim_bindings.Left, ':NavigateLeft<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Down, ':NavigateDown<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Up, ':NavigateUp<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Right, ':NavigateRight<CR>', { silent = true })
end

return M
