--- @since 26.8.15

-- wormhole.yazi -- send and receive files with magic-wormhole.
--
-- Two things shape this plugin:
--
--   1. `wormhole send` accepts exactly ONE path -- passing two fails with
--      "Got unexpected extra argument". So a multi-file selection is bundled
--      into one tar.gz, sent, and the tarball removed afterwards. Directories
--      need no bundling: wormhole zips them itself.
--
--   2. Both send and receive are interactive and long-lived -- they print a
--      code, then block until the peer connects. So the TUI is handed over
--      with `ui.hide()` and the child inherits the real terminal, rather than
--      being piped.

local function notify(level, s, ...)
	ya.notify {
		title = "wormhole",
		content = string.format(s, ...),
		level = level,
		timeout = 5,
	}
end

-- Since 26.8.15 (#4096) `tab.selected` yields File, not Url; `f.url or f`
-- keeps this working on both.
local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, f in pairs(tab.selected) do
		paths[#paths + 1] = tostring(f.url or f)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths, tostring(tab.current.cwd)
end)

local function basename(p) return p:match("([^/]+)/?$") end

-- Give the terminal to a blocking, interactive command, then take it back.
local function run_interactive(args, cwd)
	local permit = ui.hide()

	local cmd = Command("wormhole"):arg(args)
		:stdin(Command.INHERIT)
		:stdout(Command.INHERIT)
		:stderr(Command.INHERIT)
	if cwd then cmd = cmd:cwd(cwd) end

	local child, err = cmd:spawn()
	if not child then
		permit:drop()
		return nil, tostring(err)
	end

	local status, werr = child:wait()
	permit:drop()

	if not status then return nil, tostring(werr) end
	return status
end

local function report(status, err)
	if not status then return notify("error", "wormhole failed to run: %s", err) end
	if not status.success then return notify("error", "wormhole exited with %d", status.code) end
	return true
end

-- Bundle a multi-file selection into a single tarball. Paths are reduced to
-- basenames and tar is run with -C <cwd>, so the archive has no leading
-- directories for the receiver to dig through.
local function bundle(paths, cwd)
	local tarball = "/tmp/wormhole-" .. ya.hash(cwd .. tostring(ya.time())) .. ".tar.gz"

	local args = { "-czf", tarball, "-C", cwd }
	for _, p in ipairs(paths) do args[#args + 1] = basename(p) end

	local status, err = Command("tar"):arg(args):status()
	if not status then return nil, tostring(err) end
	if not status.success then return nil, string.format("tar exited with %d", status.code) end

	return tarball
end

local function send()
	ya.emit("escape", { visual = true })

	local paths, cwd = selected_or_hovered()
	if #paths == 0 then
		return notify("warn", "Nothing selected or hovered")
	end

	local target, tarball = paths[1], nil
	if #paths > 1 then
		local t, err = bundle(paths, cwd)
		if not t then return notify("error", "Bundling failed: %s", err) end
		target, tarball = t, t
		notify("info", "Bundled %d items into %s", #paths, basename(t))
	end

	local status, err = run_interactive({ "send", target }, cwd)

	if tarball then fs.remove("file", Url(tarball)) end

	if report(status, err) then
		notify("info", "Sent %s", basename(target))
	end
end

local function receive()
	local _, cwd = selected_or_hovered()

	local code, event = ya.input {
		title = "Wormhole code:",
		pos = { "top-center", y = 3, w = 46 },
	}
	if event ~= 1 or not code or code == "" then
		return
	end

	-- Trim whitespace; codes get pasted with strays surprisingly often.
	code = code:match("^%s*(.-)%s*$")

	local status, err = run_interactive({ "receive", "--accept-file", code }, cwd)
	if report(status, err) then
		notify("info", "Received into %s", cwd)
	end
end

return {
	entry = function(_, job)
		local action = job.args[1] or "send"
		if action == "send" then
			return send()
		elseif action == "receive" then
			return receive()
		end
		notify("warn", "Unknown action %q -- expected 'send' or 'receive'", action)
	end,
}
