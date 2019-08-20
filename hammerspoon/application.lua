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

application.hotkey("Mail", {"cmd"}, "r", function(app)
    app:selectMenuItem({"Message", "Reply All"})
end)
application.hotkey("Safari", {"cmd"}, "q", function(app)
end)
application.hotkey("Finder", {"cmd"}, "s", function(app)
    local _, output, _ = hs.osascript.applescript([[tell application "Finder"
    if (count windows) > 0 then
        set currentDir to POSIX path of ((target of front Finder window) as text)
    end if
end tell]])
    if output == nil then
        return
    end
    hs.application.launchOrFocus("/Applications/iTerm.app")
    hs.eventtap.keyStroke({"cmd"}, "t")
    hs.eventtap.keyStrokes(" cd '" .. output .. "'")
    hs.eventtap.keyStroke({}, "return")
end)

hyperHotkeyApps = {
    {key = "i", path = "/Applications/iTerm.app"},
    {key = "r", path = "/Users/tony/Applications/StringerX.app"},
    {key = "t", path = "/Applications/Tweetbot.app"},
    {key = "m", path = "/Applications/Mail.app"},
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
    {key = "c", id = "com.google.Chrome"},
    {key = "s", id = "com.apple.Safari"},
    {key = "x", id = "com.apple.dt.Xcode"},
}

for _, v in ipairs(runningHotkeyApps) do
    hs.hotkey.bind({"shift", "cmd", "ctrl", "alt"}, v.key, function()
        local running = hs.application.applicationsForBundleID(v.id)
        if #running > 0 then
            hs.application.launchOrFocusByBundleID(running[1]:bundleID())
        end
    end)
end
