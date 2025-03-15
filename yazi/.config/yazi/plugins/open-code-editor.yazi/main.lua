local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

return {
	entry = function()
		ya.manager_emit("escape", { visual = true })

		local urls = selected_or_hovered()
		if #urls == 0 then
			return ya.notify({ title = "Code Editor", content = "No file selected", level = "warn", timeout = 5 })
		end

		local status, err = Command("code"):arg("-r"):args(urls):spawn():wait()
		if not status or not status.success then
			ya.notify({
				title = "Code Editor",
				content = string.format("Open Code Editor failed, error: %s", status and status.code or err),
				level = "error",
				timeout = 5,
			})
		else
			ya.notify({
				title = "Code Editor",
				content = "Open Code Editor successful",
				level = "info",
				timeout = 5,
			})
		end
	end,
}
