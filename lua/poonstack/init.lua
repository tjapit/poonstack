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
	poondir = os.getenv("HOME") .. "/.local/state/nvim/poonstack",
}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})
	M._create_poondir(M.config.poondir)
	M.config.poonfile, M.config.poonfile_path = M._create_poonfile(M.config.cwd, M.config.poondir)
end

M._create_poondir = function(poondir)
	-- 1 if path is directory
	-- 0 if path not diirectory or not exists
	-- nil on error
	if vim.fn.isdirectory(poondir) then
		return
	end

	-- returns 1 if created, 0 if already exists
	-- nil if error during creation
	if not vim.fn.mkdir(poondir) then
		return -- failed to create directory
	end
end

M._create_poonfile = function(cwd, poondir)
	local poonfile = M.get_poonfile(cwd)
	local poonfile_path = M.get_poonfile_path(cwd, poondir)

	if vim.fn.writefile({}, poonfile_path) == -1 then
		return
	end

	return poonfile, poonfile_path
end

---Returns the filepath that stores the harpoon list for the current workking
---directory.
---
---It replaces all the slashes (/) with percents (%) and the ends with the
---project directory name with a .json extension.
---
---@param cwd string current working directory
---@return string poonfile the poonfile that stores harpoon list
M.get_poonfile = function(cwd)
	return cwd:gsub("/", "%%") .. ".json"
end

---Returns the absolute path to the poonfile.
---
---@param cwd string current working directory absolute path
---@param poondir string harpoon list storage directory absolute path
---@return string poonfile_path poonfile absolute path
M.get_poonfile_path = function(cwd, poondir)
	return poondir .. "/" .. M.get_poonfile(cwd)
end

---Saves the current branch's harpoon list onto the poonfile
--
---@param branch string current branch
---@param harpoon_list any items on the harpoon list
M.save = function(branch, harpoon_list)
	if not vim.fn.filereadable(M.poonfile_path) then
		return
	end

	branch = branch:trim()
	local poonlist_json = vim.json.encode({
		[branch] = harpoon_list,
	})
	vim.fn.writefile({ poonlist_json }, M.config.poonfile_path)
end

M.push = function(branch)
	-- code
end

---Returns the harpoon list for the given branch
M.pop = function(branch)
	return { branch }
end

M.setup()
M.save(vim.fn.system("git branch --show-current"), harpoon:list().items)
M.push(vim.fn.system("git branch --show-current"))
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
