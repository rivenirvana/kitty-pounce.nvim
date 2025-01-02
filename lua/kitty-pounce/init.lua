-- TODO: Only load when KITTY_IN_NVIM var is set
-- TODO: Wraparound window focus
local M = {}

local commandPrefix = 'Pounce'
local mod = { name = 'alt', key = 'M' }
local cardinals = {
  { name = 'Left', kittyLiteral = 'left', direction = 'h', cornerName = 'BottomRight', cornerDirection = 'b' },
  { name = 'Down', kittyLiteral = 'bottom', direction = 'j', cornerName = 'TopLeft', cornerDirection = 't' },
  { name = 'Up', kittyLiteral = 'top', direction = 'k', cornerName = 'BottomRight', cornerDirection = 'b' },
  { name = 'Right', kittyLiteral = 'right', direction = 'l', cornerName = 'TopLeft', cornerDirection = 't' },
}

local function navigate_window(direction, literal)
  local target = vim.fn.winnr()
  local neighbor = vim.fn.winnr('1' .. direction)

  if vim.api.nvim_win_get_config(0).relative == '' and vim.api.nvim_get_mode().mode ~= 'c' and target ~= neighbor then
    vim.api.nvim_command('wincmd ' .. direction)
  else
    -- TODO: Make kitten path configurable
    vim.fn.system('kitty @ kitten pounce.py ' .. mod.name .. '+' .. direction .. ' ' .. literal .. ' defer')
  end
end

-- TODO: Make edge navigation on focus optional
local function navigate_edge(direction)
  local target = vim.fn.winnr()
  local last = vim.fn.winnr '$'

  if
    vim.api.nvim_win_get_config(0).relative == ''
    and vim.api.nvim_get_mode().mode ~= 'c'
    and ((direction == 't' and target ~= 1) or (direction == 'b' and target ~= last))
  then
    vim.api.nvim_command('wincmd ' .. direction)
  end
end

local function create_plugin_keymap(key, direction, target, name)
  local modes = { 'n', 'c', 'i' }
  for _, mode in ipairs(modes) do
    vim.api.nvim_set_keymap(mode, '<' .. key .. '-' .. direction .. '>', '<Cmd>' .. commandPrefix .. target .. name .. '<CR>', { silent = true })
  end
end

local function set_true_keymaps(mappings)
  for _, mapping in ipairs(mappings) do
    create_plugin_keymap(mod.key, mapping.direction, 'Window', mapping.name)
  end
end

local function set_temp_keymaps(mappings)
  for _, mapping in ipairs(mappings) do
    create_plugin_keymap(mod.key, mapping.direction, 'Edge', mapping.cornerName)
  end
end

function M.setup()
  for index, mapping in ipairs(cardinals) do
    vim.api.nvim_create_user_command(commandPrefix .. 'Window' .. mapping.name, function()
      navigate_window(mapping.direction, mapping.kittyLiteral)
    end, {})
    if index > 2 then
      vim.api.nvim_create_user_command(commandPrefix .. 'Edge' .. mapping.cornerName, function()
        navigate_edge(mapping.cornerDirection)
      end, {})
    end
  end

  -- TODO: Make keybinds configurable
  set_true_keymaps(cardinals)

  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      -- TODO: Maybe use nvim's key timeout values
      vim.defer_fn(function()
        set_true_keymaps(cardinals)
      end, 10)
    end,
  })

  vim.api.nvim_create_autocmd('FocusLost', {
    callback = function()
      set_temp_keymaps(cardinals)
    end,
  })
end

return M
