hs.hotkey.bind({"ctrl"}, ",", function()
    local win = hs.window.frontmostWindow()
    local screen = win:screen()
    win:setFrame(screen:frame())
end)

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, ";", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "'", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.w / 2
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)


