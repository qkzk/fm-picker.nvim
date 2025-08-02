local M = {}
local fm_term
local Toggleterm = require("toggleterm.terminal").Terminal
local selected_filepath = nil

-- Close all opened buffers with this filepath
local function delete_buffer_by_path(path)
	local bufs = vim.api.nvim_list_bufs()
	for _, buf in ipairs(bufs) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.fn.fnamemodify(name, ":p") == vim.fn.fnamemodify(path, ":p") then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end
end

-- Open path in buffer and toggle fm
local function open_buffer_by_path(filepath)
	if fm_term then
		selected_filepath = filepath
		fm_term:toggle()
	end
	vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

-- Parse and execute messages.
local function handle_data(data)
	local msg = vim.trim(data)
	if vim.startswith(msg, "OPEN ") then
		local filepath = msg:sub(6)
		vim.schedule(function()
			open_buffer_by_path(filepath)
		end)
	elseif vim.startswith(msg, "DELETE ") then
		local filepath = msg:sub(8)
		vim.schedule(function()
			delete_buffer_by_path(filepath)
		end)
	end
end

-- Handle a received message.
-- Log errors to neovim logs,
-- Execute commands,
-- Close the connection if EOF is reached.
local function handle_message(err, data, client)
	if err then
		vim.notify("Error reading socket reply fm: " .. err, vim.log.levels.ERROR)
		return
	end
	if data then
		handle_data(data)
	else
		vim.loop.shutdown(client, function()
			client:close()
		end)
	end
end

-- Start a server listening on `fm_nvim_socket_path` and awaiting IPC commands.
local function start_reply_socket(fm_nvim_socket_path)
	local server = vim.loop.new_pipe(false)
	local ok, err = pcall(function()
		vim.loop.pipe_bind(server, fm_nvim_socket_path)
	end)
	if not ok then
		vim.notify("Error binding socket reply: " .. err, vim.log.levels.ERROR)
		return
	end

	vim.loop.listen(server, 128, function(err)
		if err then
			vim.notify("Error receiving reply from fm: " .. err, vim.log.levels.ERROR)
			return
		end

		local client = vim.loop.new_pipe(false)
		vim.loop.accept(server, client)

		vim.loop.read_start(client, function(err, data)
			handle_message(err, data, client)
		end)
	end)
end

-- Send a message through UNIX Socket
local function send_to_fm_socket(nvim_fm_socket_path, file_path)
	local sock = vim.loop.new_pipe(false)
	vim.loop.pipe_connect(sock, nvim_fm_socket_path, function(err)
		if err then
			vim.notify("Error connecting fm socket: " .. err, vim.log.levels.ERROR)
			return
		end
		local message = "GO " .. file_path .. "\n"
		sock:write(message)
		sock:shutdown(function()
			sock:close()
		end)
	end)
end

-- Creates the fm command with all required parameters
-- Requires fm_tui version >=0.2.1
local function build_fm_command(fm_path, servername, file_path, nvim_fm_socket_path, fm_nvim_socket_path)
	return fm_path
		.. " --neovim -l -s "
		.. servername
		.. " -p "
		.. file_path
		.. " --input-socket "
		.. nvim_fm_socket_path
		.. " --output-socket "
		.. fm_nvim_socket_path
end

-- Toggle the FM file picker
function M.toggle_with_path(fm_path)
	-- socket used to send messages from fm to nvim
	local nvim_fm_socket_path = "/tmp/nvim-fm-" .. tostring(vim.fn.getpid()) .. ".sock"
	-- socket used to send messages from nvim to fmnvim
	local fm_nvim_socket_path = "/tmp/fm-nvim-" .. tostring(vim.fn.getpid()) .. ".sock"
	local file_path = vim.api.nvim_buf_get_name(0)
	local servername = vim.v.servername

	-- Creates the terminal with fm if it doesn't exist yet
	if not fm_term then
		vim.notify("opened reply socket")
		local fm_cmd = build_fm_command(fm_path, servername, file_path, nvim_fm_socket_path, fm_nvim_socket_path)

		fm_term = Toggleterm:new({
			cmd = fm_cmd,
			hidden = true,
			direction = "float",
			on_exit = function()
				fm_term = nil
			end,
			on_close = function()
				if selected_filepath then
					local path = selected_filepath
					selected_filepath = nil
					vim.schedule(function()
						vim.cmd("edit " .. vim.fn.fnameescape(path))
					end)
				end
			end,
		})
		start_reply_socket(fm_nvim_socket_path)
	else
		send_to_fm_socket(nvim_fm_socket_path, file_path)
	end

	fm_term:toggle()
end

return M
