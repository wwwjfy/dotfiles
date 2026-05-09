local IDEKey = "shortcutIDE"
local chooserCallback = {
    reload = function()
        hs.reload()
        hs.notify.show("HammerSpoon reloaded", "", "")
    end,
    closeNotifications = function()
        local jsScript = [[
function run(input, parameters) {
    const SE = Application("System Events");
    SE.includeStandardAdditions = true;

    const NC = SE.processes.byName("NotificationCenter");

    const CLOSE_TITLES = ["Close", "Clear", "Clear All"];

    const tryPerformActions = (element) => {
        try {
            for (let action of element.actions()) {
                const desc = action.description();
                if (desc === "Clear All" || desc === "Close") {
                    action.perform();
                    return true;
                }
            }
        } catch(e) {}
        return false;
    };

    const tryCloseWindow = (win) => {
        // Modern macOS (15+): each notification is its own window with direct buttons
        try {
            for (let btn of win.buttons()) {
                if (CLOSE_TITLES.indexOf(btn.title()) >= 0) {
                    if (tryPerformActions(btn)) return true;
                }
            }
        } catch(e) {}

        // Try actions on the window itself
        if (tryPerformActions(win)) return true;

        // macOS 26+: win > AXGroup > AXGroup > AXScrollArea > AXGroup > notifications
        try {
            const groups = win.uiElements[0].uiElements[0].uiElements[0].uiElements[0].uiElements();
            for (let group of groups) {
                if (tryPerformActions(group)) return true;
            }
        } catch(e) {}

        // Legacy grouped view (macOS 14 and earlier)
        try {
            const groups = win.uiElements[0].uiElements[0].uiElements[0].uiElements();
            for (let group of groups) {
                if (tryPerformActions(group)) return true;
            }
        } catch(e) {}

        return false;
    };

    let closedCount = 0;
    const startTime = Date.now();

    while (Date.now() - startTime < 30000) {
        let windows;
        try {
            windows = NC.windows();
        } catch(e) { break; }
        if (windows.length === 0) break;

        let acted = false;
        for (let win of windows) {
            try {
                if (tryCloseWindow(win)) {
                    closedCount++;
                    acted = true;
                    break;
                }
            } catch(e) {}
        }

        if (!acted) break;
    }

    if (closedCount === 0) {
        throw new Error("No notifications found or could not close any");
    }

    return "Closed " + closedCount + " notification(s)";
}
]]
        local tmpFile = os.tmpname() .. ".js"
        local f = io.open(tmpFile, "w")
        if not f then
            print("closeNotifications: could not create temp file")
            return
        end
        f:write(jsScript)
        f:close()

        hs.task.new("/usr/bin/osascript", function(exitCode, stdOut, stdErr)
            os.remove(tmpFile)
            if exitCode == 0 then
                print("Close notifications success:", stdOut)
            else
                print("Close notifications error:", stdErr)
            end
        end, {"-l", "JavaScript", tmpFile}):start()
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

