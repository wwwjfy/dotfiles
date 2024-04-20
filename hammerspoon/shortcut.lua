local IDEKey = "shortcutIDE"
local chooserCallback = {
    reload = function()
        hs.reload()
        hs.notify.show("HammerSpoon reloaded", "", "")
    end,
    closeNotifications = function()
        hs.osascript.javascript([[
function run(input, parameters) {

  const appNames = [];
  const skipAppNames = [];
  const verbose = true;

  const scriptName = "close_notifications_applescript";

  const CLEAR_ALL_ACTION = "Clear All";
  const CLEAR_ALL_ACTION_TOP = "Clear";
  const CLOSE_ACTION = "Close";

  const notNull = (val) => {
    return val !== null && val !== undefined;
  };

  const isNull = (val) => {
    return !notNull(val);
  };

  const notNullOrEmpty = (val) => {
    return notNull(val) && val.length > 0;
  };

  const isNullOrEmpty = (val) => {
    return !notNullOrEmpty(val);
  };

  const isError = (maybeErr) => {
    return notNull(maybeErr) && (maybeErr instanceof Error || maybeErr.message);
  };

  const systemVersion = () => {
    return Application("Finder").version().split(".").map(val => parseInt(val));
  };

  const systemVersionGreaterThanOrEqualTo = (vers) => {
    return systemVersion()[0] >= vers;
  };

  const isBigSurOrGreater = () => {
    return systemVersionGreaterThanOrEqualTo(11);
  };

  const V11_OR_GREATER = isBigSurOrGreater();
  const V12 = systemVersion()[0] === 12;
  const APP_NAME_MATCHER_ROLE = V11_OR_GREATER ? "AXStaticText" : "AXImage";
  const hasAppNames = notNullOrEmpty(appNames);
  const hasSkipAppNames = notNullOrEmpty(skipAppNames);
  const hasAppNameFilters = hasAppNames || hasSkipAppNames;
  const appNameForLog = hasAppNames ? ` [${appNames.join(",")}]` : "";

  const logs = [];
  const log = (message, ...optionalParams) => {
    let message_with_prefix = `${new Date().toISOString().replace("Z", "").replace("T", " ")} [${scriptName}]${appNameForLog} ${message}`;
    console.log(message_with_prefix, optionalParams);
    logs.push(message_with_prefix);
  };

  const logError = (message, ...optionalParams) => {
    if (isError(message)) {
      let err = message;
      message = `${err}${err.stack ? (" " + err.stack) : ""}`;
    }
    log(`ERROR ${message}`, optionalParams);
  };

  const logErrorVerbose = (message, ...optionalParams) => {
    if (verbose) {
      logError(message, optionalParams);
    }
  };

  const logVerbose = (message) => {
    if (verbose) {
      log(message);
    }
  };

  const getLogLines = () => {
    return logs.join("\n");
  };

  const getSystemEvents = () => {
    let systemEvents = Application("System Events");
    systemEvents.includeStandardAdditions = true;
    return systemEvents;
  };

  const getNotificationCenter = () => {
    try {
      return getSystemEvents().processes.byName("NotificationCenter");
    } catch (err) {
      logError("Could not get NotificationCenter");
      throw err;
    }
  };

  const getNotificationCenterGroups = (retryOnError = false) => {
    try {
      let notificationCenter = getNotificationCenter();
      if (notificationCenter.windows.length <= 0) {
        return [];
      }
      if (!V11_OR_GREATER) {
        return notificationCenter.windows();
      }
      if (V12) {
        return notificationCenter.windows[0].uiElements[0].uiElements[0].uiElements();
      }
      return notificationCenter.windows[0].uiElements[0].uiElements[0].uiElements[0].uiElements();
    } catch (err) {
      logError("Could not get NotificationCenter groups");
      if (retryOnError) {
        logError(err);
        log("Retrying getNotificationCenterGroups...");
        return getNotificationCenterGroups(false);
      } else {
        throw err;
      }
    }
  };

  const isClearButton = (description, name) => {
    return description === "button" && name === CLEAR_ALL_ACTION_TOP;
  };

  const matchesAnyAppNames = (value, checkValues) => {
    if (isNullOrEmpty(checkValues)) {
      return false;
    }
    let lowerAppName = value.toLowerCase();
    for (let checkValue of checkValues) {
      if (lowerAppName === checkValue.toLowerCase()) {
        return true;
      }
    }
    return false;
  };

  const matchesAppName = (role, value) => {
    if (role !== APP_NAME_MATCHER_ROLE) {
      return false;
    }
    if (hasAppNames) {
      return matchesAnyAppNames(value, appNames);
    }
    return !matchesAnyAppNames(value, skipAppNames);
  };

  const notificationGroupMatches = (group) => {
    try {
      let description = group.description();
      if (V11_OR_GREATER && isClearButton(description, group.name())) {
        return true;
      }
      if (V11_OR_GREATER && description !== "group") {
        return false;
      }
      if (!V11_OR_GREATER) {
        let matchedAppName = !hasAppNameFilters;
        if (!matchedAppName) {
          for (let elem of group.uiElements()) {
            if (matchesAppName(elem.role(), elem.description())) {
              matchedAppName = true;
              break;
            }
          }
        }
        if (matchedAppName) {
          return notNull(findCloseActionV10(group, -1));
        }
        return false;
      }
      if (!hasAppNameFilters) {
        return true;
      }
      let firstElem = group.uiElements[0];
      return matchesAppName(firstElem.role(), firstElem.value());
    } catch (err) {
      logErrorVerbose(`Caught error while checking window, window is probably closed: ${err}`);
      logErrorVerbose(err);
    }
    return false;
  };

  const findCloseActionV10 = (group, closedCount) => {
    try {
      for (let elem of group.uiElements()) {
        if (elem.role() === "AXButton" && elem.title() === CLOSE_ACTION) {
          return elem.actions["AXPress"];
        }
      }
    } catch (err) {
      logErrorVerbose(`(group_${closedCount}) Caught error while searching for close action, window is probably closed: ${err}`);
      logErrorVerbose(err);
      return null;
    }
    log("No close action found for notification");
    return null;
  };

  const findCloseAction = (group, closedCount) => {
    try {
      if (!V11_OR_GREATER) {
        return findCloseActionV10(group, closedCount);
      }
      let checkForPress = isClearButton(group.description(), group.name());
      let clearAllAction;
      let closeAction;
      for (let action of group.actions()) {
        let description = action.description();
        if (description === CLEAR_ALL_ACTION) {
          clearAllAction = action;
          break;
        } else if (description === CLOSE_ACTION) {
          closeAction = action;
        } else if (checkForPress && description === "press") {
          clearAllAction = action;
          break;
        }
      }
      if (notNull(clearAllAction)) {
        return clearAllAction;
      } else if (notNull(closeAction)) {
        return closeAction;
      }
    } catch (err) {
      logErrorVerbose(`(group_${closedCount}) Caught error while searching for close action, window is probably closed: ${err}`);
      logErrorVerbose(err);
      return null;
    }
    log("No close action found for notification");
    return null;
  };

  const closeNextGroup = (groups, closedCount) => {
    try {
      for (let group of groups) {
        if (notificationGroupMatches(group)) {
          let closeAction = findCloseAction(group, closedCount);

          if (notNull(closeAction)) {
            try {
              closeAction.perform();
              return [true, 1];
            } catch (err) {
              logErrorVerbose(`(group_${closedCount}) Caught error while performing close action, window is probably closed: ${err}`);
              logErrorVerbose(err);
            }
          }
          return [true, 0];
        }
      }
      return false;
    } catch (err) {
      logError("Could not run closeNextGroup");
      throw err;
    }
  };

  try {
    let groupsCount = getNotificationCenterGroups(true).filter(group => notificationGroupMatches(group)).length;

    if (groupsCount > 0) {
      logVerbose(`Closing ${groupsCount}${appNameForLog} notification group${(groupsCount > 1 ? "s" : "")}`);

      let startTime = new Date().getTime();
      let closedCount = 0;
      let maybeMore = true;
      let maxAttempts = 2;
      let attempts = 1;
      while (maybeMore && ((new Date().getTime() - startTime) <= (1000 * 30))) {
        try {
          let closeResult = closeNextGroup(getNotificationCenterGroups(), closedCount);
          maybeMore = closeResult[0];
          if (maybeMore) {
            closedCount = closedCount + closeResult[1];
          }
        } catch (innerErr) {
          if (maybeMore && closedCount === 0 && attempts < maxAttempts) {
            log(`Caught an error before anything closed, trying ${maxAttempts - attempts} more time(s).`)
            attempts++;
          } else {
            throw innerErr;
          }
        }
      }
    } else {
      throw Error(`No${appNameForLog} notifications found...`);
    }
  } catch (err) {
    logError(err);
    logError(err.message);
    getLogLines();
    throw err;
  }

  return getLogLines();
}
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

