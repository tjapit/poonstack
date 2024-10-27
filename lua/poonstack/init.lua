local M = {}

-- M.setup = function(opts)
-- 	print("Options:", opts)
-- end

-- Idea:
-- save to a json file, example of this can be seen in example.json
--
-- main key would be the repos, and then inside each repos would have
-- their own branches. The branch_names would hold an array of filepaths
-- that was stored in harpoon.
--
-- we need somewhere to store that .json file. Idea would be to copy what
-- undotree did (e.g. ~/.local/state/nvim/poonstack), check what they do
-- with :set undodir?.

-- functions we need:
-- - require("harpoon"):list().items -> get the list
-- - require("harpoon"):list():add() -> add to list
-- - vim.fn.writefile() -> save to file
-- - vim.fn.readfile() -> read from the json file
-- - vim.fn.json_decode() -> decode the readfile() results

local harpoon = require("harpoon")

---Trims the whitespace from the start and end of a string.
--
---@param s string
---@return string
---@return integer count
string.trim = function(s)
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

M.config = {
	cwd = vim.fn.getcwd(),
	cwb = vim.fn.system("git branch --show-current"),
	poonstack_dir = os.getenv("HOME") .. "/.local/state/nvim/poonstack",
}

M._poonstack = {}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})
	M._create_poondir(M.config.poonstack_dir)
	M.config.poonstack_file, M.config.poonstack_filepath =
		M._create_poonstack_file(M.config.cwd, M.config.poonstack_dir)
end

M._create_poondir = function(poonstack_dir)
	-- 1 if path is directory
	-- 0 if path not diirectory or not exists
	-- nil on error
	if vim.fn.isdirectory(poonstack_dir) then
		return
	end

	-- returns 1 if created, 0 if already exists
	-- nil if error during creation
	if not vim.fn.mkdir(poonstack_dir) then
		return -- failed to create directory
	end
end

M._create_poonstack_file = function(cwd, poonstack_dir)
	-- if not git tracked, don't create file
	if vim.fn.system("git branch"):find("fatal") then
		return
	end

	local poonstack_file = M.get_poonstack_file(cwd)
	local poonstack_filepath = M.get_poonstack_path(cwd, poonstack_dir)

	if vim.fn.filereadable(poonstack_filepath) == 1 then
		return poonstack_file, poonstack_filepath -- don't create file if already exists
	end

	if vim.fn.writefile({}, poonstack_filepath) then
		return -- error when creating file
	end

	return poonstack_file, poonstack_filepath
end

---Returns the filepath that stores the harpoon list for the current workking
---directory.
---
---It replaces all the slashes (/) with percents (%) and the ends with the
---project directory name with a .json extension.
---
---@param cwd string current working directory
---@return string poonstack the poonstack file that stores harpoon list
M.get_poonstack_file = function(cwd)
	return cwd:gsub("/", "%%") .. ".json"
end

---Returns the absolute path to the poonstack file.
---
---@param cwd string current working directory absolute path
---@param poonstack_dir string harpoon list storage directory absolute path
---@return string poonstack_filepath poonstack absolute path
M.get_poonstack_path = function(cwd, poonstack_dir)
	return poonstack_dir .. "/" .. M.get_poonstack_file(cwd)
end

---Writes the poonstack to the given file.
---
---Converts the poonstack into json before writing it to the file.
---
---@param file string path to the file to save to
---@return nil|string result nil on success, error message on error
M.write = function(file)
	-- write from M._poonstack to file
	local poonstack_json = vim.fn.json_encode(M._poonstack)
	return vim.fn.writefile({ poonstack_json }, file)
end

---Reads from the poonstack file and loads it to the poonstack
M.read = function()
	if not vim.fn.filereadable(M.config.poonstack_filepath) then
		return
	end

	local poonstack_json = vim.fn.readfile(M.config.poonstack_filepath)
	if #poonstack_json == 0 then
		return
	end

	M._poonstack = vim.fn.json_decode(poonstack_json)
end

---Loads the harpoon list of the current branch from poonstack -> harpoon
M.load = function(branch)
	branch = branch:trim()
	for _, poon in ipairs(M._poonstack[branch]) do
		harpoon:list():add(poon)
	end
end

---Pushes the current branch's harpoon list onto the poonstack.
--
---@param branch string current branch
---@param harpoon_list any items on the harpoon list
M.push = function(branch, harpoon_list)
	branch = branch:trim()
	M._poonstack[branch] = harpoon_list
end

---Returns the harpoon list for the given branch off the poonstack
---
---Does not actually pop it off the stack.
---@param branch string current working branch
---@return table|nil poon table with harpoon items, each containing context (row, col) and filepath
M.pop = function(branch)
	if #M._poonstack == 0 then
		return
	end

	branch = branch:trim()
	return M._poonstack[branch]
end

M.setup()
-- M.push(vim.fn.system("git branch --show-current"), harpoon:list().items)
-- M.pop(vim.fn.system("git branch --show-current"))
M.read()
M.load(vim.fn.system("git branch --show-current"))

--[[
lua require("poonstack").push("master", {
  {
    context = {
      row = 0,
      col = 0,
    },
    value = "src/app/auth/embed-kyc.component.ts"
  },
  ...
})

lua require("poonstack").pop("master")
--]]

return M
