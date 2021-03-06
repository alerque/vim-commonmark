package.loaded["rust"] = nil -- Force module reload during dev
local rust = require("libvim_commonmark")

-- The Lua API is verbose and repetative
local call_function = vim.api.nvim_call_function
local buf_add_highlight = vim.api.nvim_buf_add_highlight
local buf_attach = vim.api.nvim_buf_attach
local buf_get_lines = vim.api.nvim_buf_get_lines
local buf_clear_namespace = vim.api.nvim_buf_clear_namespace
local get_var = vim.api.nvim_get_var

local commonmarker = {
	_attachments = {},
	_namespace = vim.api.nvim_create_namespace("rustymarks"),
	extensions = {},
}

-- luacheck: ignore dump
local function dump(...)
	if select("#", ...) == 1 then
		vim.api.nvim_out_write(vim.inspect((...)))
	else
		vim.api.nvim_out_write(vim.inspect {...})
	end
	vim.api.nvim_out_write("\n")
end

local function byte2pos (byte)
	local line = call_function("byte2line", { byte })
	-- local col = byte - vim.api.nvim_buf_get_offset(buffer, line)
	local col = byte - call_function("line2byte", { line })
	return line, col
end

local function get_contents (buffer)
	local lines = buf_get_lines(buffer, 0, -1, true)
	for i = 1, #lines do lines[i] = lines[i] .. "\n" end
	return table.concat(lines)
end

local function highlight (buffer, namespace)
	local contents = get_contents(buffer)
	local events = rust.get_offsets(contents)
	for _, event in ipairs(events) do
		local sline, scol = byte2pos(event.first)
		local eline, ecol = byte2pos(event.last)
		if sline < eline then
			buf_add_highlight(buffer, namespace, event.group, sline - 1, scol, -1)
			sline = sline + 1
			while sline < eline do
				buf_add_highlight(buffer, namespace, event.group, sline - 1, 0, -1)
				sline = sline + 1
			end
			buf_add_highlight(buffer, namespace, event.group, sline - 1, 0, ecol)
		else
			buf_add_highlight(buffer, namespace, event.group, sline - 1, scol, ecol)
		end
	end
end

function commonmarker:init ()
	self.extensions = get_var("commonmark#extensions")
	rust.init(self.extensions)
	return self
end

function commonmarker:detach (buffer)
	dump(self._attachments)
	self._attachments[buffer] = nil
	buf_clear_namespace(buffer, self._namespace, 0, -1)
end

function commonmarker:attach (buffer)
	if self._attachments[buffer] then return end
	self._attachments[buffer] = true
	highlight(buffer, self._namespace)
	buf_attach(buffer, false, {
			on_lines = function (_, _, _, _, _, _)
				dump(self)
				buf_clear_namespace(buffer, self._namespace, 0, -1)
				-- Returning true here detaches, we thought we should have been already
				if not self._attachments[buffer] then return true end
				highlight(buffer, self._namespace)
			end,
			on_detach = function (_)
				self._attachments[buffer] = nil
				self:detach(buffer)
			end
		})
end

return commonmarker
