#!/usr/bin/env lua
-- Checks that a color token is only used for the kind of element it belongs to:
-- text* on Label/Text/TextInput, icon* on Glyph, fill*/line*/knob* on shapes, line* on borders.
-- Usage: token-kinds.lua <quickshell dir>
local root = arg[1] or "."
local old = { bg = 1, surface = 1, hover = 1, muted = 1, fg = 1, bright = 1, accent = 1, danger = 1, warning = 1, success = 1 }
local shapes = { Rectangle = 1, PanelWindow = 1, FloatingWindow = 1, WlSessionLockSurface = 1, Clickable = 1, ActionButton = 1, Item = 1 }
local texts = { Label = 1, Text = 1, TextInput = 1 }

local function kind(token) return token:match("^(%l+)") end

local function allowed(file, typ, prop, token)
  local k = kind(token)
  if file == "components/Glyph.qml" then return k == "icon" end
  if prop == "border.color" then return k == "line" end
  if prop == "glyphColor" then return k == "icon" end
  if typ == "Glyph" then return k == "icon" end
  if texts[typ] then return k == "text" end
  if shapes[typ] or prop == "idleColor" or prop == "hoverColor" then return k == "fill" or k == "line" or k == "knob" end
  return true
end

local bad = 0
local files = io.popen("cd " .. root .. " && find . -name '*.qml' | sort")
for rel in files:lines() do
  rel = rel:gsub("^%./", "")
  if rel ~= "Theme.qml" then
    local stack, prop = {}, "?"
    local n = 0
    for line in io.lines(root .. "/" .. rel) do
      n = n + 1
      local code = line:gsub("//.*", "")
      local start = code:match("^%s*([%a_][%w_.]*)%s*:")
      if start then prop = start end
      local events = {}
      for s in code:gmatch("(){") do
        events[#events + 1] = { s, "open", code:sub(1, s - 1):match("([%u][%w_.]*)%s*$") or "?" }
      end
      for s in code:gmatch("()}") do events[#events + 1] = { s, "close" } end
      table.sort(events, function(a, b) return a[1] < b[1] end)
      for s, token in code:gmatch("()Theme%.(%l[%w_]*)") do
        if old[token] or token:match("^text") or token:match("^icon") or token:match("^fill") or token:match("^line") or token:match("^knob") then
          local st = {}
          for i, v in ipairs(stack) do st[i] = v end
          for _, e in ipairs(events) do
            if e[1] >= s then break end
            if e[2] == "close" then st[#st] = nil else st[#st + 1] = e[3] end
          end
          local typ = st[#st] or "(root)"
          local inline = nil
          for p, name in code:sub(1, s - 1):gmatch("[{;]%s*()([%a_][%w_.]*)%s*:") do inline = name end
          local p = inline or prop
          if old[token] then
            print(("%s:%d: old color token Theme.%s"):format(rel, n, token)); bad = bad + 1
          elseif not allowed(rel, typ, p, token) then
            print(("%s:%d: Theme.%s does not fit a %s %s"):format(rel, n, token, typ, p)); bad = bad + 1
          end
        end
      end
      for _, e in ipairs(events) do
        if e[2] == "close" then stack[#stack] = nil else stack[#stack + 1] = e[3] end
      end
    end
  end
end
os.exit(bad == 0 and 0 or 1)
