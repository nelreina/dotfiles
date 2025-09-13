require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})
require("smart-enter"):setup({
	open_multi = true,
})
require("git"):setup()

require("full-border"):setup()

require("starship"):setup()

require("custom-shell"):setup({
	history_path = "default",
	save_history = true,
})
-- DuckDB plugin configuration
require("duckdb"):setup()
