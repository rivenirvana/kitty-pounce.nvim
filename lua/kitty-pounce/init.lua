-- TODO: Only load when KITTY_IN_NVIM var is set
local M = {}

local mappings = {
  { target = 'Window', name = 'Left', kittyLiteral = 'left', direction = 'h' },
  { target = 'Window', name = 'Down', kittyLiteral = 'bottom', direction = 'j' },
  { target = 'Window', name = 'Up', kittyLiteral = 'top', direction = 'k' },
  { target = 'Window', name = 'Right', kittyLiteral = 'right', direction = 'l' },
  { target = 'Edge', name = 'TopLeft', direction = 't' },
  { target = 'Edge', name = 'BottomRight', direction = 'b' },
}

local mod = { name = 'alt', key = 'M' }

local function navigate_window(mapping)
  local target = vim.fn.winnr()
  local neighbor = vim.fn.winnr('1' .. mapping.direction)

  if vim.api.nvim_win_get_config(0).relative == '' and target ~= neighbor then
    vim.api.nvim_command('wincmd ' .. mapping.direction)
  else
    -- TODO: Make kitten path configurable
    vim.fn.system('kitty @ kitten pounce.py ' .. mod.name .. '+' .. mapping.direction .. ' ' .. mapping.kittyLiteral .. ' defer')
  end
end

local function navigate_edge(mapping)
  local target = vim.fn.winnr()
  local last = vim.fn.winnr '$'

  if vim.api.nvim_win_get_config(0).relative == '' and ((mapping.direction == 't' and target ~= 1) or (mapping.direction == 'b' and target ~= last)) then
    vim.api.nvim_command('wincmd ' .. mapping.direction)
  end
end

local function set_keymaps()
  for index, mapping in ipairs(mappings) do
    vim.api.nvim_set_keymap('n', '<' .. mod.key .. '-' .. mapping.direction .. '>', ':NavigateWindow' .. mapping.name .. '<CR>', { silent = true })
    if index == 4 then
      break
    end
  end
end

function M.setup()
  for _, mapping in ipairs(mappings) do
    if mapping.target == 'Window' then
      vim.api.nvim_create_user_command('NavigateWindow' .. mapping.name, function()
        navigate_window(mapping)
      end, {})
    else
      vim.api.nvim_create_user_command('NavigateEdge' .. mapping.name, function()
        navigate_edge(mapping)
      end, {})
    end
  end

  -- TODO: Make keybinds configurable
  set_keymaps()

  vim.api.nvim_create_autocmd('FocusGained', {
    callback = function()
      vim.api.nvim_set_keymap('n', '<' .. mod.key .. '-' .. mappings[1].direction .. '>', ':NavigateEdge' .. mappings[6].name .. '<CR>', { silent = true })
      vim.api.nvim_set_keymap('n', '<' .. mod.key .. '-' .. mappings[2].direction .. '>', ':NavigateEdge' .. mappings[5].name .. '<CR>', { silent = true })
      vim.api.nvim_set_keymap('n', '<' .. mod.key .. '-' .. mappings[3].direction .. '>', ':NavigateEdge' .. mappings[6].name .. '<CR>', { silent = true })
      vim.api.nvim_set_keymap('n', '<' .. mod.key .. '-' .. mappings[4].direction .. '>', ':NavigateEdge' .. mappings[5].name .. '<CR>', { silent = true })

      vim.defer_fn(set_keymaps, 5)
    end,
  })
end

return M
