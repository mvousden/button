#!/usr/bin/lua5.1

local sdl = require("SDL")
local sdlImage = require("SDL.image")

-- SDL initialisation
local returnCode, errorMsg = sdl.init(sdl.flags.Video,
                                          sdl.flags.Audio)
if not returnCode then
   error(errorMsg)
end

-- SDL image initialisation
local imageFlags={sdlImage.flags.PNG}
local formatsLoaded, returnCode, errorMsg = sdlImage.init(imageFlags)
for index, flag in ipairs(imageFlags) do
   if not formatsLoaded[flag] then
      error(errorMsg)
   end
end

-- Print SDL version.
print(string.format("Initialised SDL Version %d.%d.%d", sdl.VERSION_MAJOR,
                    sdl.VERSION_MINOR, sdl.VERSION_PATCH))

-- Create a window.
local windowSpec = {title="Tutorial SDL window",
                    flags= {sdl.window.Resizable}}
local window, errorMsg = sdl.createWindow(windowSpec)
if not window then
   error(errorMsg)
end

-- Create a renderer for the window.
local renderer, errorMsg = sdl.createRenderer(window, 0, 0)
if not renderer then
   error(errorMsg)
end

-- Load an image as a texture.
local image, errorMsg = sdlImage.load("blue_square.png")
if not image then
   error(errorMsg)
end

local blueSquareTexture, errorMsg = renderer:createTextureFromSurface(image)
if not blueSquareTexture then
   error(errorMsg)
end

-- Draw the image using the renderer.
local returnCode, errorMsg = renderer:clear()
if not returnCode then
   error(errorMsg)
end

local returnCode, errorMsg = renderer:copy(blueSquareTexture)
if not returnCode then
   error(errorMsg)
end

renderer:present()

-- Poll for events, and print them.
local running = true
while running do
   for event in sdl.pollEvent() do
      if event.type == sdl.event.Quit then
         running = false
      elseif event.type == sdl.event.KeyDown then
         print(string.format("key down: %d -> %s", event.keysym.sym,
                             sdl.getKeyName(event.keysym.sym)))
      elseif event.type == sdl.event.KeyUp then
         print(string.format("key up: %d -> %s", event.keysym.sym,
                             sdl.getKeyName(event.keysym.sym)))
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
