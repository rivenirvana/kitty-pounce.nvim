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
    vim.fn.system('kitty @ kitten scripts/pounce.py ' .. kitty_mappings[direction])
  end
end

function M.navigateLeft()
  navigate 'h'
end
function M.navigateDown()
  navigate 'j'
end
function M.navigateUp()
  navigate 'k'
end
function M.navigateRight()
  navigate 'l'
end

function M.setup()
  vim.api.nvim_create_user_command('NavigateLeft', M.navigateLeft, {})
  vim.api.nvim_create_user_command('NavigateDown', M.navigateDown, {})
  vim.api.nvim_create_user_command('NavigateUp', M.navigateUp, {})
  vim.api.nvim_create_user_command('NavigateRight', M.navigateRight, {})

  vim.api.nvim_set_keymap('n', nvim_bindings.Left, ':NavigateLeft<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Down, ':NavigateDown<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Up, ':NavigateUp<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Right, ':NavigateRight<CR>', { silent = true })
end

return M
