vim.notify("Hello, Tim")

-- testing reading from json and decoding
local json_file = vim.fn.readfile("example.json")
local json_example = vim.fn.json_decode(json_file)
-- P(json_example["milky-way"])
