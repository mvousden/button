#!/usr/bin/lua5.1

local sdl = require("SDL")

-- SDL Initialisation
local returnCode, errorMessage = sdl.init(sdl.flags.Video,
                                          sdl.flags.Audio)
if not returnCode then
   error(errorMessage)
end

-- Print SDL version.
print(string.format("Initialised SDL Version %d.%d.%d", sdl.VERSION_MAJOR,
                    sdl.VERSION_MINOR, sdl.VERSION_PATCH))

-- Create a window.
local windowSpec = {title="Tutorial SDL window",
                    flags= {sdl.window.Resizable}}
local window, errorMessage = sdl.createWindow(windowSpec)
if not window then
   error(errorMessage)
end

-- Poll for events, and print them.
local running = true
while running do
   for event in sdl.pollEvent() do
      if event.type == sdl.event.Quit then
         running = false
      elseif event.type == sdl.event.KeyDown then
         print(string.format("key down: %d -> %s", event.keysym.sym, sdl.getKeyName(event.keysym.sym)))
      elseif event.type == sdl.event.MouseWheel then
         print(string.format("mouse wheel: %d, x=%d, y=%d",
                             event.which, event.x, event.y))
      elseif event.type == sdl.event.MouseButtonDown then
         print(string.format("mouse button down: %d, x=%d, y=%d",
                             event.button, event.x, event.y))
      elseif event.type == sdl.event.MouseMotion then
         print(string.format("mouse motion: x=%d, y=%d", event.x, event.y))
      end
   end
end

-- SDL Deinitialisation
sdl.quit()
