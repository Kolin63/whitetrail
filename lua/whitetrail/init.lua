-- SPDX-License-Identifier: MIT
-- Copyright (c) Colin Melican 2025

local M = {}

local config = {
  whitespace = { " " },
}

-- if character is in config.whitespace, returns true
M.is_whitespace = function(char)
  for _, i in ipairs(config.whitespace) do
    if i == char then return true end
  end
  return false
end

-- checks for whitespace in given buffer number
M.check = function(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local og = line
    while M.is_whitespace(line:sub(#line, #line)) do
      line = line:sub(1, #line - 1)
    end

    if line ~= og then
      vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { line })
    end
  end
end

-- checks all buffers for whitespace
M.check_all = function()
  local tabs = vim.api.nvim_list_tabpages()
  for _, tab in ipairs(tabs) do
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      M.check(buf)
    end
  end
end

-- config stuff
M.setup = function(input)
  if input.whitespace ~= nil then config.whitespace = input.whitespace end

  vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "White Trail",
    callback = M.check_all
  })

  vim.api.nvim_create_user_command("WhiteTrail", M.check_all, {})
end

return M
