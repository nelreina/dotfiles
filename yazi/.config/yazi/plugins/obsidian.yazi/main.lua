-- obsidian.yazi — Obsidian vault integration for Yazi
-- Features: backlinks, tags, daily notes, wikilink follower, command menu

local VAULT_PATH = "/Users/nelsonreina/Documents/src/nellyb-space/Documents/second-brain/second-brain"
local RG = "/opt/homebrew/bin/rg"

local function vault_path()
	return VAULT_PATH
end

local function stem(path)
	-- Extract filename without extension
	local name = path:match("([^/]+)$") or path
	return name:match("(.+)%.%w+$") or name
end

local function rel_path(full)
	-- Get path relative to vault
	local vp = vault_path()
	if full:sub(1, #vp) == vp then
		return full:sub(#vp + 2)
	end
	return full
end

-- Run rg and return lines
local function rg_run(args)
	local cmd = RG
	for _, a in ipairs(args) do
		cmd = cmd .. " " .. a
	end
	local handle = io.popen(cmd .. " 2>/dev/null")
	if not handle then return {} end
	local output = handle:read("*a")
	handle:close()
	local lines = {}
	for line in output:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

-- Get current file path from sync context
local get_current = ya.sync(function()
	local cur = cx.active.current
	local hovered = cur.hovered
	if hovered then
		return tostring(hovered.url), tostring(cur.cwd)
	end
	return nil, tostring(cur.cwd)
end)

-- BACKLINKS: Find all files linking to current file via [[wikilinks]]
local function backlinks()
	local file_path, cwd = get_current()
	if not file_path then
		ya.notify { title = "Obsidian", content = "No file selected", timeout = 3, level = "warn" }
		return
	end

	local name = stem(file_path)
	-- Search for [[name]] or [[name|alias]] patterns
	local pattern = "\\[\\[" .. name .. "(\\]\\]|\\|)"
	local lines = rg_run({
		"--files-with-matches",
		"--type", "md",
		"-e", "'" .. pattern .. "'",
		"'" .. vault_path() .. "'"
	})

	if #lines == 0 then
		ya.notify { title = "Backlinks", content = "No backlinks found for " .. name, timeout = 3, level = "info" }
		return
	end

	-- Build candidate list for ya.which
	local cands = {}
	local file_map = {}
	for i, line in ipairs(lines) do
		if line ~= file_path and i <= 26 then
			local key = string.char(96 + #cands + 1) -- a, b, c...
			local display = rel_path(line)
			table.insert(cands, { on = key, desc = display })
			file_map[#cands] = line
		end
	end

	if #cands == 0 then
		ya.notify { title = "Backlinks", content = "No backlinks found for " .. name, timeout = 3, level = "info" }
		return
	end

	ya.notify { title = "Backlinks", content = #cands .. " backlinks for [[" .. name .. "]]", timeout = 2, level = "info" }

	local idx = ya.which { cands = cands, silent = false }
	if idx and file_map[idx] then
		local target = file_map[idx]
		local dir = target:match("(.+)/[^/]+$")
		local fname = target:match("([^/]+)$")
		if dir then
			ya.emit("cd", { dir })
			ya.emit("reveal", { fname })
		end
	end
end

-- TAGS: Browse all tags in vault
local function tags()
	-- Find #tags (not in code blocks) and frontmatter tags
	local tag_lines = rg_run({
		"--no-filename",
		"--type", "md",
		"-o",
		"-e", "'(?:^|\\s)#([a-zA-Z][a-zA-Z0-9_/-]+)'",
		"'" .. vault_path() .. "'"
	})

	-- Also get frontmatter tags: "tags: [foo, bar]" or "- foo"
	local fm_lines = rg_run({
		"--no-filename",
		"--type", "md",
		"-o",
		"-e", "'(?<=tags:\\s)\\[.*?\\]'",
		"'" .. vault_path() .. "'"
	})

	-- Count tags
	local counts = {}
	for _, line in ipairs(tag_lines) do
		local tag = line:match("#?([a-zA-Z][a-zA-Z0-9_/-]+)")
		if tag then
			counts[tag] = (counts[tag] or 0) + 1
		end
	end

	-- Parse frontmatter tag arrays
	for _, line in ipairs(fm_lines) do
		for tag in line:gmatch("[%w_/-]+") do
			if tag ~= "tags" then
				counts[tag] = (counts[tag] or 0) + 1
			end
		end
	end

	-- Sort by count
	local sorted = {}
	for tag, count in pairs(counts) do
		table.insert(sorted, { tag = tag, count = count })
	end
	table.sort(sorted, function(a, b) return a.count > b.count end)

	if #sorted == 0 then
		ya.notify { title = "Tags", content = "No tags found in vault", timeout = 3, level = "warn" }
		return
	end

	-- Show top 26 tags
	local cands = {}
	local tag_map = {}
	for i, item in ipairs(sorted) do
		if i > 26 then break end
		local key = string.char(96 + i)
		table.insert(cands, { on = key, desc = "#" .. item.tag .. " (" .. item.count .. ")" })
		tag_map[i] = item.tag
	end

	local idx = ya.which { cands = cands, silent = false }
	if not idx or not tag_map[idx] then return end

	local selected_tag = tag_map[idx]

	-- Find files with this tag
	local files = rg_run({
		"--files-with-matches",
		"--type", "md",
		"-e", "'#" .. selected_tag .. "\\b'",
		"-e", "'tags:.*" .. selected_tag .. "'",
		"'" .. vault_path() .. "'"
	})

	if #files == 0 then
		ya.notify { title = "Tags", content = "No files with #" .. selected_tag, timeout = 3, level = "info" }
		return
	end

	local file_cands = {}
	local file_map2 = {}
	for i, f in ipairs(files) do
		if i > 26 then break end
		local key = string.char(96 + i)
		table.insert(file_cands, { on = key, desc = rel_path(f) })
		file_map2[i] = f
	end

	local idx2 = ya.which { cands = file_cands, silent = false }
	if idx2 and file_map2[idx2] then
		local target = file_map2[idx2]
		local dir = target:match("(.+)/[^/]+$")
		local fname = target:match("([^/]+)$")
		if dir then
			ya.emit("cd", { dir })
			ya.emit("reveal", { fname })
		end
	end
end

-- WEEKLY NOTE: Navigate to this week's note
local function daily()
	local vp = vault_path()
	local target_dir = vp .. "/Weekly"

	-- Calculate ISO week number
	local t = os.time()
	local d = os.date("*t", t)
	-- ISO week: Monday is day 1
	local jan1 = os.time({ year = d.year, month = 1, day = 1 })
	local jan1_wday = os.date("*t", jan1).wday
	-- Adjust: Lua wday is 1=Sun, ISO is 1=Mon
	local adj = (jan1_wday + 5) % 7
	local yday = os.date("*t", t).yday
	local week = math.floor((yday + adj - 1) / 7) + 1
	local week_label = string.format("%d-W%02d", d.year, week)
	local target_file = target_dir .. "/" .. week_label .. ".md"

	local f = io.open(target_file, "r")
	if f then
		f:close()
		ya.notify { title = "Weekly Note", content = "Opening " .. week_label, timeout = 2, level = "info" }
	else
		ya.notify { title = "Weekly Note", content = week_label .. " not found — run sync first", timeout = 3, level = "warn" }
		return
	end

	ya.emit("cd", { target_dir })
	ya.emit("reveal", { week_label .. ".md" })
end

-- WIKILINKS: Parse current file for [[links]] and navigate
local function links()
	local file_path = get_current()
	if not file_path then
		ya.notify { title = "Obsidian", content = "No file selected", timeout = 3, level = "warn" }
		return
	end

	-- Read file and extract wikilinks
	local f = io.open(file_path, "r")
	if not f then
		ya.notify { title = "Links", content = "Cannot read file", timeout = 3, level = "error" }
		return
	end
	local content = f:read("*a")
	f:close()

	local link_set = {}
	local link_list = {}
	-- Match [[link]] and [[link|display]]
	for link in content:gmatch("%[%[([^%]|]+)[|%]]") do
		if not link_set[link] then
			link_set[link] = true
			table.insert(link_list, link)
		end
	end

	if #link_list == 0 then
		ya.notify { title = "Links", content = "No wikilinks found", timeout = 3, level = "info" }
		return
	end

	table.sort(link_list)

	local cands = {}
	local link_map = {}
	for i, link in ipairs(link_list) do
		if i > 26 then break end
		local key = string.char(96 + i)
		table.insert(cands, { on = key, desc = "[[" .. link .. "]]" })
		link_map[i] = link
	end

	local idx = ya.which { cands = cands, silent = false }
	if not idx or not link_map[idx] then return end

	local target_name = link_map[idx]

	-- Find the file in vault
	local files = rg_run({
		"--files",
		"--type", "md",
		"-g", "'*" .. target_name .. ".md'",
		"'" .. vault_path() .. "'"
	})

	if #files == 0 then
		-- Try broader search
		files = rg_run({
			"--files",
			"--type", "md",
			"-g", "'*" .. target_name .. "*'",
			"'" .. vault_path() .. "'"
		})
	end

	if #files > 0 then
		local target = files[1]
		local dir = target:match("(.+)/[^/]+$")
		local fname = target:match("([^/]+)$")
		if dir then
			ya.emit("cd", { dir })
			ya.emit("reveal", { fname })
		end
	else
		ya.notify { title = "Links", content = "File not found: " .. target_name, timeout = 3, level = "warn" }
	end
end

-- SEARCH: Interactive vault search with rg
local function search()
	local value, event = ya.input {
		pos = { "top-center", y = 3, w = 50 },
		title = "🔍 Search vault:",
		value = "",
	}

	if event ~= 1 or not value or value == "" then return end

	local files = rg_run({
		"--files-with-matches",
		"--type", "md",
		"--smart-case",
		"-e", "'" .. value .. "'",
		"'" .. vault_path() .. "'"
	})

	if #files == 0 then
		ya.notify { title = "Search", content = "No results for: " .. value, timeout = 3, level = "info" }
		return
	end

	local cands = {}
	local file_map = {}
	for i, f in ipairs(files) do
		if i > 26 then break end
		local key = string.char(96 + i)
		table.insert(cands, { on = key, desc = rel_path(f) })
		file_map[i] = f
	end

	ya.notify { title = "Search", content = #files .. " results for: " .. value, timeout = 2, level = "info" }

	local idx = ya.which { cands = cands, silent = false }
	if idx and file_map[idx] then
		local target = file_map[idx]
		local dir = target:match("(.+)/[^/]+$")
		local fname = target:match("([^/]+)$")
		if dir then
			ya.emit("cd", { dir })
			ya.emit("reveal", { fname })
		end
	end
end

-- COMMAND MENU
local function menu()
	local idx = ya.which {
		cands = {
			{ on = "b", desc = "Backlinks — files linking here" },
			{ on = "t", desc = "Tags — browse vault tags" },
			{ on = "d", desc = "Daily — today's note" },
			{ on = "l", desc = "Links — follow wikilinks" },
			{ on = "s", desc = "Search — full-text search" },
			{ on = "v", desc = "Vault — go to vault root" },
		},
		silent = false,
	}

	if idx == 1 then backlinks()
	elseif idx == 2 then tags()
	elseif idx == 3 then daily()
	elseif idx == 4 then links()
	elseif idx == 5 then search()
	elseif idx == 6 then ya.emit("cd", { vault_path() })
	end
end

return {
	entry = function(self, job)
		local action = job.args[1] or "menu"

		if action == "backlinks" then backlinks()
		elseif action == "tags" then tags()
		elseif action == "daily" then daily()
		elseif action == "links" then links()
		elseif action == "search" then search()
		elseif action == "menu" then menu()
		else
			ya.notify { title = "Obsidian", content = "Unknown action: " .. action, timeout = 3, level = "error" }
		end
	end,
}
