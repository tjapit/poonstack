local utils = {}

---Trims the whitespace from the start and end of a string.
--
---@param s string
---@return string
---@return integer count
string.trim = function(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

---Check if project is tracked by Git.
---@return boolean istracked true if tracked, false otherwise
utils.istracked = function()
	if vim.fn.system("git branch"):find("fatal") then
		return false
	end
	return true
end

return utils
