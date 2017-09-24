#!/usr/bin/lua5.3

local sdl = require("SDL")
local sdlImage = require("SDL.image")

-- Logger setup.
local logPath = "tutorial.log"
local logLevels = {"DEBUG", "INFO", "WARNING", "ERROR"}

-- Restrict the logging level to file and to standard output individually.
local logFileLevel = 1
local logStdoutLevel = 1

function logWrite(level, message)

   -- The message to write.
   local toWrite = string.format("[%s] %s: %s", os.date("%T"),
                                 logLevels[level], message)

   if logPath and level >= logFileLevel then
      local logFile = io.open(logPath, "a")
      logFile:write(toWrite .. "\n")
      logFile:close()
   end

   if level >= logStdoutLevel then
      print(toWrite)
   end
end

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
                    flags={sdl.window.Resizable}}
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

-- Determine texture properties.
local format, access, imageWidth, imageHeight = blueSquareTexture:query()

-- Main loop.
local boxDim = 100
local position = {w=boxDim, h=boxDim}
local renderBox = position  -- Stores position co-ordinates as integers.
local running = true
local movement = {}
local loopPeriod = 1 / 60  -- Seconds
local boxSpeed = 600  -- Pixels per second
local rootTwo = 0.707106  -- Square root of two.
local previousFrameTime = sdl.getTicks()
while running do

   -- Event polling: q quits (and other quitting events also work), and keys
   -- move the box.
   for event in sdl.pollEvent() do

      if event.type == sdl.event.Quit then
         running = false

      elseif event.type == sdl.event.KeyDown then
         if sdl.getKeyName(event.keysym.sym) == "Q" then
            running = false
         elseif sdl.getKeyName(event.keysym.sym) == "Up" then
            movement.up = true

         elseif sdl.getKeyName(event.keysym.sym) == "Down" then
            movement.down = true
         elseif sdl.getKeyName(event.keysym.sym) == "Left" then
            movement.left = true
         elseif sdl.getKeyName(event.keysym.sym) == "Right" then
            movement.right = true
         end

      elseif event.type == sdl.event.KeyUp then
         if sdl.getKeyName(event.keysym.sym) == "Up" then
            movement.up = false
         elseif sdl.getKeyName(event.keysym.sym) == "Down" then
            movement.down = false
         elseif sdl.getKeyName(event.keysym.sym) == "Left" then
            movement.left = false
         elseif sdl.getKeyName(event.keysym.sym) == "Right" then
            movement.right = false
         end
      end
   end

   -- Determine the vector of motion of the box.
   local velocity = {x=0, y=0}

   -- Horizontal motion
   if movement.right then
      velocity.x = 1
   elseif movement.left then
      velocity.x = -1
   end

   -- Vertical motion
   if movement.up then
      velocity.y = -1
   elseif movement.down then
      velocity.y = 1
   end

   -- Normalization
   if velocity.x ~= 0 and velocity.y ~= 0 then
      velocity.x = velocity.x * rootTwo
      velocity.y = velocity.y * rootTwo
   end

   -- Determine the new position of the box. If the position is not known, put
   -- the box in the centre.
   local windowX, windowY = window:getSize()
   if not position.x then
      position.x = math.floor(windowX / 2 - boxDim / 2)
      position.y = math.floor(windowY / 2 - boxDim / 2)
   else
      position.x = position.x + boxSpeed * velocity.x * loopPeriod
      position.y = position.y + boxSpeed * velocity.y * loopPeriod
   end

   -- Don't let the box go out of bounds, recalling that the position of the
   -- box represents its upper-left corner.
   if position.x < 0 then
      position.x = 0
   elseif position.x > windowX - boxDim then
      position.x = windowX - boxDim
   end

   if position.y < 0 then
      position.y = 0
   elseif position.y > windowY - boxDim then
      position.y = windowY - boxDim
   end

   -- Draw to the display.
   local returnCode, errorMsg = renderer:clear()
   if not returnCode then
      error(errorMsg)
   end

   -- Convert position co-ordinates to floats.

   for key, value in pairs({x=position.x, y=position.y}) do
      renderBox[key] = math.tointeger(math.floor(value))
   end

   local returnCode, errorMsg = renderer:copy(blueSquareTexture, nil, renderBox)
   if not returnCode then
      error(errorMsg)
   end
   renderer:present()

   -- Delay until end of frame.
   local delay = loopPeriod * 1000 - sdl.getTicks() + previousFrameTime
   sdl.delay(delay % 1 >= 0.5 and math.ceil(delay) or math.floor(delay))
   previousFrameTime = sdl.getTicks()

end

-- SDL Deinitialisation
sdl.quit()
