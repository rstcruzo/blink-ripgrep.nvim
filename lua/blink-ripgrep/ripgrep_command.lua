---@class blink-ripgrep.RipgrepCommand
---@field command string[]
---@field root string
---@field debugify_for_shell? fun(self):nil # Echo the command to the messages buffer for debugging purposes.
local RipgrepCommand = {}
RipgrepCommand.__index = RipgrepCommand

---@param prefix string
---@param options blink-ripgrep.Options
---@return blink-ripgrep.RipgrepCommand
---@nodiscard
function RipgrepCommand.get_command(prefix, options)
  local cmd = {
    "rg",
    "--no-config",
    "--json",
    "--context=" .. options.context_size,
    "--word-regexp",
    "--max-filesize=" .. options.max_filesize,
    options.search_casing,
  }

  for _, option in ipairs(options.additional_rg_options) do
    table.insert(cmd, option)
  end

  table.insert(cmd, "--")
  table.insert(cmd, prefix .. "[\\w_-]+")

  local root = (vim.fs.root(0, options.project_root_marker) or vim.fn.getcwd())
  table.insert(cmd, root)

  local command = setmetatable({
    command = cmd,
    root = root,
  }, RipgrepCommand)

  return command
end

-- Print the command to :messages for debugging purposes.
function RipgrepCommand:debugify_for_shell()
  -- print the command to :messages for hacky debugging, but don't show it
  -- in the ui so that it doesn't interrupt the user's work
  local debug_cmd = vim.deepcopy(self.command)

  -- The pattern is not compatible with shell syntax, so escape it
  -- separately. The user should be able to copy paste it into their posix
  -- compatible terminal.
  local pattern = debug_cmd[9]
  debug_cmd[9] = "'" .. pattern .. "'"
  debug_cmd[10] = vim.fn.fnameescape(debug_cmd[10])

  local things = table.concat(debug_cmd, " ")
  vim.api.nvim_exec2("echomsg " .. vim.fn.string(things), {})
end

return RipgrepCommand
