-- ~/.config/yazi/init.lua
require("bookmarks"):setup({
	last_directory = { enable = true, persist = false },
	persist = "all",
	desc_format = "full",
	file_pick_mode = "hover",
	notify = {
		enable = true,
		timeout = 5,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})

require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

-- require("git"):setup()

require("full-border"):setup()

require("starship"):setup()

require("custom-shell"):setup({
	history_path = "default",
	save_history = true,
})

require("mactag"):setup({
	-- Keys used to add or remove tags
	keys = {
		r = "Red",
		o = "Orange",
		y = "Yellow",
		g = "Green",
		b = "Blue",
		p = "Purple",
	},
	-- Colors used to display tags
	colors = {
		Red = "#ee7b70",
		Orange = "#f5bd5c",
		Yellow = "#fbe764",
		Green = "#91fc87",
		Blue = "#5fa3f8",
		Purple = "#cb88f8",
	},
})
