-- ~/.config/yazi/init.lua
-- require("bookmarks"):setup({
-- 	last_directory = { enable = true, persist = false },
-- 	persist = "all",
-- 	desc_format = "full",
-- 	file_pick_mode = "hover",
-- 	notify = {
-- 		enable = true,
-- 		timeout = 5,
-- 		message = {
-- 			new = "New bookmark '<key>' -> '<folder>'",
-- 			delete = "Deleted bookmark in '<key>'",
-- 			delete_all = "Deleted all bookmarks",
-- 		},
-- 	},
-- })
--
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})

-- require("git"):setup()

-- require("full-border"):setup()

require("starship"):setup()

require("custom-shell"):setup({
	history_path = "default",
	save_history = true,
})
