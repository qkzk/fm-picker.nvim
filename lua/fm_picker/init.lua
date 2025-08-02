local M = {}

local config = {
	fm_path = "/usr/bin/fm",
}

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
end

function M.toggle()
	local fm_exec = vim.fn.fnameescape(config.fm_path)
	local Toggleterm = require("toggleterm.terminal").Terminal

	require("fm_picker.internal").toggle_with_path(fm_exec)
end

return M
