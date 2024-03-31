local IDEKey = "shortcutIDE"
local chooserCallback = {
    reload = function()
        hs.reload()
        hs.notify.show("HammerSpoon reloaded", "", "")
    end,
    closeNotifications = function()
        hs.osascript.applescript([[
tell application "System Events"
	tell process "NotificationCenter"
		repeat with theGroup in groups of UI element 1 of scroll area 1 of window "Notification Center"
			repeat with theAction in actions of theGroup
				if description of theAction is "Close" or description of theAction is "Clear All" then
					tell theGroup
						perform theAction
					end tell
				end if
			end repeat
		end repeat
	end tell
end tell
]])
    end,
    chooseIDE = function()
        chooser = hs.chooser.new(function(choice)
            if not choice then
                return
            end
            hs.settings.set(IDEKey, choice["bundleID"])
        end)
        chooser:queryChangedCallback(function(query)
            selectByIndex(chooser, query)
        end)
        chooser:choices({
            {
                text="1. PyCharm",
                bundleID="com.jetbrains.pycharm"
            },
            {
                text="2. GoLand",
                bundleID="com.jetbrains.goland"
            }
        })
        hs.timer.doAfter(0.1, function()
            chooser:show()
        end)
    end,
    setDefaultBrowser = function()
        chooser = hs.chooser.new(function(choice)
            if not choice then
                return
            end
            hs.urlevent.setDefaultHandler("http", choice["bundleID"])
        end)
        chooser:queryChangedCallback(function(query)
            selectByIndex(chooser, query)
        end)
        chooser:choices({
            {
                text="1. Safari",
                bundleID="com.apple.Safari"
            },
            {
                text="2. Firefox",
                bundleID="org.mozilla.firefox"
            }
        })
        hs.timer.doAfter(0.1, function()
            chooser:show()
        end)
    end,
    doNotDisturb = function()
        local function toggleDoNotDisturb()
            local origPos = hs.mouse.getAbsolutePosition()
            local screenFrame = hs.screen.mainScreen():fullFrame()
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], hs.geometry.point(screenFrame.w-30,10), {"alt"}):post()
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], hs.geometry.point(screenFrame.w-30,10), {"alt"}):post()
            hs.mouse.setAbsolutePosition(origPos)
        end
        toggleDoNotDisturb()
        hs.timer.doAfter(25 * 60, function()
            local output = hs.execute("defaults -currentHost read com.apple.notificationcenterui doNotDisturb")
            local isOn = output:gsub("%s+$", "") == "1"
            if isOn then
                toggleDoNotDisturb()
            end
        end)
    end
}

hs.hotkey.bind({"ctrl", "cmd"}, "k", function()
    local chooser = hs.chooser.new(function(choice)
        if not choice then
            return
        end
        chooserCallback[choice["id"]]()
    end)
    chooser:queryChangedCallback(function(query)
        selectByIndex(chooser, query)
    end)
    chooser:choices({
        {
            id="reload",
            text="1. Reload HammerSpoon"
        },
        {
            id="closeNotifications",
            text="2. Close notifications"
        },
        {
            id="chooseIDE",
            text="3. PyCharm or GoLand"
        },
        {
            id="setDefaultBrowser",
            text="4. Set default browser"
        },
        {
            id="doNotDisturb",
            text="5. Do not disturb for 25 min"
        }
    })
    chooser:show()
end)

hs.hotkey.bind({"shift", "cmd", "ctrl", "alt"}, "p", function()
    local IDE = hs.settings.get(IDEKey)
    if IDE == "" then
        return
    end
    local running = hs.application.applicationsForBundleID(IDE)
    if #running > 0 then
        hs.application.launchOrFocusByBundleID(IDE)
    end
end)

function selectByIndex(chooser, query)
    local selected = tonumber(query)
    if not selected then
        return
    end
    if selected > chooser:rows() or selected < 1 then
        return
    end
    chooser:select(selected)
end

