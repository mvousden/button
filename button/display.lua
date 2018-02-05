-- Defines a simple singleton display class, which interfaces with SDL to
-- display a window to the user. The module table is the instance of display.

local sdl = require("SDL")
local log = require("button/logger")


local title = "SDL window"
local flags = {sdl.window.Resizable}
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


function Display:update()
   -- Updates the display with render operations since the previous
   -- call, then clears the renderer. Returns nothing.
   self.renderer:present()
   local returnCode, errorMsg = self.renderer:clear()
   if not returnCode then
      error(errorMsg)
   end
end


-- Module table, simply creates the display and returns its table.
return Display:create()
