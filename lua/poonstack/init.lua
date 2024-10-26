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

M.push = function(project_path, branch_name, harpoon_list) 
end

M.pop = function(project_path, branch_name) 
end

--[[
lua require("poonstack").push("~/code/lua/plugins/poonstack.nvim/", "main", {
  ...
})

lua require("poonstack").pop("~/code/lua/plugins/poonstack.nvim/", "main")
--]]

return M
