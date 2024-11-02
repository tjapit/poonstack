local harpoon = require("harpoon")
local poonstack = require("poonstack")

local function add_poons(poons)
	for _, poon in ipairs(poons) do
		harpoon:list():add(poon)
	end
end

describe("poonstack", function()
	before_each(function()
		poonstack._clear()
		harpoon:list():clear()
	end)

	it("can be required", function()
		require("poonstack")
	end)

	it("can push a single item", function()
		local exp_item = {
			context = { row = 0, col = 0 },
			value = "README.md",
		}
		local expected = { exp_item }
		add_poons(expected)

		poonstack.push() -- -> poonstack
		poonstack.pop() -- poonstack -> harpoon

		local actual = require("harpoon"):list().items
		assert.are.same(expected, actual, "should have a single item: README.md")
	end)

	it("can push multiple items", function()
		local exp_item1 = {
			context = { row = 0, col = 0 },
			value = "lua/poonstack/init.lua",
		}
		local exp_item2 = {
			context = { row = 0, col = 0 },
			value = ".gitignore",
		}
		local expected = { exp_item1, exp_item2 }
		add_poons(expected)

		poonstack.push() -- -> poonstack
		poonstack.pop() -- poonstack -> harpoon

		local actual = require("harpoon"):list().items
		assert.are.same(expected, actual, "should have a two items: lua/poonstack/init.lua and .gitignore")
	end)
end)
