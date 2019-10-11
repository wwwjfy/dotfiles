require("application")
require("layout")
require("shortcut")

require("local")

-- silence noise
hs.hotkey.setLogLevel(2)
hs.window.filter.setLogLevel(1)

function focusLastFocused()
    local wf = hs.window.filter
    local lastFocused = wf.defaultCurrentSpace:getWindows(wf.sortByFocusedLast)
    if #lastFocused > 0 then lastFocused[1]:focus() end
end
