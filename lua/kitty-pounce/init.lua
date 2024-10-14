-- TODO: Only load when KITTY_IN_NVIM var is set
local M = {}

local kitty_mappings = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
}

local nvim_bindings = {
  Left = '<A-h>',
  Down = '<A-j>',
  Up = '<A-k>',
  Right = '<A-l>',
}

local function navigate(direction)
  local neighbor = 1
  if kitty_mappings[direction] then
    neighbor = vim.fn.winnr('1' .. direction)
  else
    neighbor = vim.fn.winnr '$'
  end

  if vim.fn.winnr() ~= neighbor or not vim.api.nvim_win_get_config(0).zindex then
    vim.api.nvim_command('wincmd ' .. direction)
  else
    -- TODO: Make kitten path configurable
    vim.fn.system('kitty @ kitten pounce.py ' .. kitty_mappings[direction])
  end
end

function M.setup()
  vim.api.nvim_create_user_command('NavigateWindowLeft', function()
    navigate 'h'
  end, {})
  vim.api.nvim_create_user_command('NavigateWindowDown', function()
    navigate 'j'
  end, {})
  vim.api.nvim_create_user_command('NavigateWindowUp', function()
    navigate 'k'
  end, {})
  vim.api.nvim_create_user_command('NavigateWindowRight', function()
    navigate 'l'
  end, {})
  vim.api.nvim_create_user_command('NavigateEdgeTopLeft', function()
    navigate 't'
  end, {})
  vim.api.nvim_create_user_command('NavigateEdgeBottomRight', function()
    navigate 'b'
  end, {})

  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      vim.api.nvim_set_keymap('n', nvim_bindings.Left, ':NavigateEdgeBottomRight<CR>', { silent = true })
      vim.api.nvim_set_keymap('n', nvim_bindings.Down, ':NavigateEdgeTopLeft<CR>', { silent = true })
      vim.api.nvim_set_keymap('n', nvim_bindings.Up, ':NavigateEdgeBottomRight<CR>', { silent = true })
      vim.api.nvim_set_keymap('n', nvim_bindings.Right, ':NavigateEdgeTopLeft<CR>', { silent = true })

      vim.defer_fn(function()
        vim.api.nvim_set_keymap('n', nvim_bindings.Left, ':NavigateWindowLeft<CR>', { silent = true })
        vim.api.nvim_set_keymap('n', nvim_bindings.Down, ':NavigateWindowDown<CR>', { silent = true })
        vim.api.nvim_set_keymap('n', nvim_bindings.Up, ':NavigateWindowUp<CR>', { silent = true })
        vim.api.nvim_set_keymap('n', nvim_bindings.Right, ':NavigateWindowRight<CR>', { silent = true })
      end, 5)
    end,
  })

  -- TODO: Make keybinds configurable
  vim.api.nvim_set_keymap('n', nvim_bindings.Left, ':NavigateWindowLeft<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Down, ':NavigateWindowDown<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Up, ':NavigateWindowUp<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', nvim_bindings.Right, ':NavigateWindowRight<CR>', { silent = true })
end

return M
