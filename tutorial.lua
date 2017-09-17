#!/usr/bin/lua5.1

local sdl = require("SDL")
local sdlImage = require("SDL.image")

-- SDL initialisation
local returnCode, errorMessage = sdl.init(sdl.flags.Video,
                                          sdl.flags.Audio)
if not returnCode then
   error(errorMessage)
end

-- SDL image initialisation
local imageFlags={sdlImage.flags.PNG}
local formatsLoaded, returnCode, errorMessage = sdlImage.init(imageFlags)
for index, flag in ipairs(imageFlags) do
   if not formatsLoaded[flag] then
      error(errorMessage)
   end
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

-- Create a renderer for the window.
local renderer, errorMessage = sdl.createRenderer(window, 0, 0)
if not renderer then
   error(errorMessage)
end

-- Load an image.
local image, errorMessage = sdlImage.load("blue_square.png")
if not image then
   error(errorMessage)
end
local blueSquareTexture = renderer:createTextureFromSurface(image)

-- Draw the image using the renderer.
local returnCode, errorMessage = renderer:clear()
if not returnCode then
   error(errorMessage)
end

local returnCode, errorMessage = renderer:copy(blueSquareTexture)
if not returnCode then
   error(errorMessage)
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
