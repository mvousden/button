#!/usr/bin/lua5.3

local sdl = require("SDL")
local sdlImage = require("SDL.image")

local display = require("button/display")
local log = require("button/logger")
local sdlInitialiser = require("button/sdl_initialiser")

-- SDL initialisation
sdlInitialiser.initialise_all()

-- Load an image as a texture.
local imagePath = "button/blue_square.png"
local image = assert(sdlImage.load(imagePath))
log.getLogger():info(string.format("Image at %s loaded.", imagePath))

local blueSquareTexture = assert(display.renderer:createTextureFromSurface(image))

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

log.getLogger():debug("Entering main loop.")
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
   local windowX, windowY = display.window:getSize()
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

   -- Convert position co-ordinates to floats.
   for key, value in pairs({x=position.x, y=position.y}) do
      renderBox[key] = math.tointeger(math.floor(value))
   end

   -- Draw to the display.
   assert(display.renderer:copy(blueSquareTexture, nil, renderBox))
   display:update()

   -- Delay until end of frame.
   local delay = (previousFrameTime + loopPeriod * 1000) - sdl.getTicks()
   print(string.format("Current ticks: %f", sdl.getTicks()))
   print(string.format("Previous frame ticks: %f", previousFrameTime))
   print(string.format("Loop period: %f", loopPeriod * 1000))
   print(string.format("Frame delay: %f", delay))
   sdl.delay(delay % 1 >= 0.5 and math.ceil(delay) or math.floor(delay))
   previousFrameTime = sdl.getTicks()

end

-- SDL Deinitialisation
log.getLogger():info("Wrapping up.")
sdl.quit()
