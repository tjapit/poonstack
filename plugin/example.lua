vim.notify("Hello, Tim")

-- testing reading from json and decoding
-- local harpoon = require("harpoon")
-- local json_file = vim.fn.readfile("example.json")
-- local json_example = vim.fn.json_decode(json_file)
-- P(json_example["milky-way"])
-- harpoon:list():add({
-- 	context = {},
-- 	value = "README.md",
-- })
-- P(harpoon:list().items)
require("poonstack")
