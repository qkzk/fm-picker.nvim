local M = {}

local config = {
	-- where is fm executable on your system ? `$ which fm` should tell you !
	fm_path = "/usr/bin/fm",
}

--- Update the config
---@param user_config table
function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})
end

---Entry point. Toggle the fm file picker.
function M.toggle()
	local fm_path = vim.fn.fnameescape(config.fm_path)
	require("fm_picker.internal").toggle_with_path(fm_path)
end

return M
