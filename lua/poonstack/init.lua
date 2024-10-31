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
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")

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
local istracked = function()
	if vim.fn.system("git branch"):find("fatal") then
		return false
	end
	return true
end

M.config = {
	cwd = vim.fn.getcwd(),
	branch = vim.fn.system("git branch --show-current"):trim(),
	poonstack_dir = os.getenv("HOME") .. "/.local/state/nvim/poonstack",
}

M._poonstack = {}

M._count_poons = function()
	local count = 0
	for _ in pairs(M._poonstack) do
		count = count + 1
	end
	return count
end

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	local err = M._create_poonstack_dir()
	if err then
		vim.notify(err, vim.log.levels.ERROR)
	end

	err = M._create_poonstack_file()
	if err then
		vim.notify(err, vim.log.levels.ERROR)
	end

	harpoon:list():clear() -- override harpoon persistence
	M.read()
	M.load()
end

M._switch_branch = function(branch)
	M.write()
	M.config.branch = branch
  harpoon:list():clear()
	M.load()
end

M._create_poonstack_dir = function()
	-- 1 if path is directory
	-- 0 if path not diirectory or not exists
	-- nil on error
	if vim.fn.isdirectory(M.config.poonstack_dir) then
		return
	end

	-- returns 1 if created, 0 if already exists
	-- nil if error during creation
	if not vim.fn.mkdir(M.config.poonstack_dir) then
		return -- failed to create directory
	end
end

---Creates poonstack file and assigns the path and filename to M.config
---@return nil|string error nil on success, error message on error
M._create_poonstack_file = function()
	-- if not git tracked, don't create file
	if not istracked() then
		return
	end

	M.config.poonstack_file = M.get_poonstack_file()
	M.config.poonstack_filepath = M.get_poonstack_filepath()

	if vim.fn.filereadable(M.config.poonstack_filepath) == 1 then
		return -- don't create file if already exists
	end

	if vim.fn.writefile({}, M.config.poonstack_filepath) == -1 then
		return "error creating poonstack file" -- error when creating file
	end
end

---Returns the filepath that stores the harpoon list for the current workking
---directory.
---
---It replaces all the slashes (/) with percents (%) and the ends with the
---project directory name with a .json extension.
---
---@return string poonstack_file the poonstack file that stores harpoon list
M.get_poonstack_file = function()
	return M.config.cwd:gsub("/", "%%") .. ".json"
end

---Returns the absolute path to the poonstack file.
---
---@return string poonstack_filepath poonstack absolute path
M.get_poonstack_filepath = function()
	return M.config.poonstack_dir .. "/" .. M.get_poonstack_file()
end

---Writes the poonstack to the given file.
---
---Converts the poonstack into json before writing it to the file.
---
---@return nil|string result nil on success, error message on error
M.write = function()
	-- push current poon to poonstack
	M.push()

	-- write from M._poonstack to file
	local poonstack_json = vim.fn.json_encode(M._poonstack)
	return vim.fn.writefile({ poonstack_json }, M.config.poonstack_filepath)
end

---Reads from the poonstack file and loads it to the poonstack
M.read = function()
	if vim.fn.filereadable(M.config.poonstack_filepath) == 0 then
		return "file does not exist/not readable"
	end

	local poonstack_json = vim.fn.readfile(M.config.poonstack_filepath)
	if poonstack_json == {} then
		return "empty poonstack file"
	end

	if #poonstack_json == 0 then
		return
	end

	M._poonstack = vim.fn.json_decode(poonstack_json)
end

---Loads the harpoon list of the given branch from poonstack > harpoon
M.load = function()
	for _, poon in ipairs(M._poonstack[M.config.branch]) do
		harpoon:list():add(poon)
	end
end

---Pushes the current branch's harpoon > poonstack
--
M.push = function()
	local poon = harpoon:list().items
	M._poonstack[M.config.branch] = poon
end

---Pops the harpoon list for current branch
---
---@return table|nil poon table with harpoon items, each containing context (row, col) and filepath
M.pop = function()
	if M._count_poons() == 0 then
		return
	end

	local res = M._poonstack[M.config.branch]
	M._poonstack[M.config.branch] = nil

	return res
end

M.setup()

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

M._clear = function()
	M._poonstack = {}
end

local poonstack_git_checkout = function(prompt_bufnr)
	local selection = actions_state.get_selected_entry()
	if selection then
		local branch = selection.value

		actions.git_checkout(prompt_bufnr)

		M._switch_branch(branch)
	end
end

vim.api.nvim_create_user_command("PoonstackGitCheckout", function()
	require("telescope.builtin").git_branches({
		attach_mappings = function(_, map)
			map("i", "<CR>", poonstack_git_checkout)
			map("n", "<CR>", poonstack_git_checkout)
			return true
		end,
	})
end, {})

return M
