-- Defines a simple singleton display class, which interfaces with SDL to
-- display a window to the user. The display is created by calling getDisplay.

local sdl = require("SDL")
local log = require("button/logger")

-- Default configuration (used at display creation time).
local title = "SDL window"
local flags = {sdl.window.Resizable}

-- Display class behaviour.
Display = {}
Display.__index = Display


function Display:create(args)
   -- Creates a display (window and renderer) using SDL. Input arguments:
   --  - args: Table of arguments to pass to sdl.createWindow if the display
   --    has not been created. Is not used otherwise
   local display = {}
   setmetatable(display, Display)

   loadedImages = {}

   -- Create the SDL window using args, and substituting with defaults if
   -- entries are missing.
   local defaultWindowSpec = {title="Tutorial SDL window",
                              flags={sdl.window.Resizable}}
   if args then
      for key, value in pairs(args) do
         defaultWindowSpec[key] = value
      end
   end

   local window, errorMsg = sdl.createWindow(defaultWindowSpec)
   if not window then
      error(errorMsg)
   end
   display.window = window
   log.getLogger():info("Window created.")

   -- Create a renderer targetting that window.
   local renderer, errorMsg = sdl.createRenderer(display.window, 0, 0)
   if not renderer then
      error(errorMsg)
   end
   display.renderer = renderer
   log.getLogger():info("Renderer created.")

   -- Return the display object we've created.
   return display
end

-- Singleton logic.
local _display = nil  -- Holds the display once created.


function getDisplay(args)
   -- Creates the display if it has not already been initialised, and returns
   -- it if it has been. Input arguments:
   --  - args: Table of arguments to pass to sdl.createWindow if the display
   --    has not been created. Is not used otherwise
   if not _display then
      _display = Display:create(args)
   end
   return _display
end

-- Module table.
return {getDisplay=getDisplay}
