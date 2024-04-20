local application = hs.application
local appfinder = hs.appfinder

function application.hotkey(appName, mods, key, pressedFn)
    local hotkey = hs.hotkey.new(mods, key, function()
        local app = appfinder.appFromName(appName)
        if app ~= nil then
            pressedFn(app)
        end
    end)
    hs.window.filter.new(appName)
        :subscribe(hs.window.filter.windowFocused, function() hotkey:enable() end)
        :subscribe(hs.window.filter.windowUnfocused, function() hotkey:disable() end)
end

application.hotkey("Safari", {"cmd"}, "q", function(app)
end)
application.hotkey("Firefox", {"cmd"}, "q", function(app)
end)

local hyperHotkeyApps = {
    {key = "i", path = "/Applications/kitty.app"},
    {key = "r", path = "/Users/tony/Applications/StringerX.app"},
    {key = "t", path = "/Applications/Mona.app"},
    {key = "m", path = "/Applications/FMail2.app"},
    {key = "f", path = "/System/Library/CoreServices/Finder.app"},
    {key = "e", path = "/Applications/Sublime Text.app"},
    {key = "u", path = "/Applications/Things3.app"},
}

for _, v in ipairs(hyperHotkeyApps) do
    hs.hotkey.bind({"shift", "cmd", "ctrl", "alt"}, v.key, function()
        hs.application.launchOrFocus(v.path)
    end)
end

hs.hotkey.bind({"shift", "cmd"}, "d", function()
    hs.application.launchOrFocus("Dictionary")
end)

runningHotkeyApps = {
    {key = "c", id = "org.mozilla.firefox"},
    {key = "s", id = "com.apple.Safari"},
    {key = "x", id = "com.apple.dt.Xcode"},
}

for _, v in ipairs(runningHotkeyApps) do
    hs.hotkey.bind({"shift", "cmd", "ctrl", "alt"}, v.key, function()
        local running = hs.application.applicationsForBundleID(v.id)
        if #running > 0 then
            hs.application.launchOrFocusByBundleID(v.id)
        end
    end)
end
