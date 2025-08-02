vim.api.nvim_create_user_command("FmPickerToggle", function()
	require("fm_picker").toggle()
end, {})
