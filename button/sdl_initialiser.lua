-- Defines convenience functions for initialising and tearing-down SDL.

local sdl = require("SDL")
local sdlImage = require("SDL.image")

local log = require("button/logger")


function initialise_all()
   initialise_sdl_core()
   initialise_sdl_image()
end


function initialise_sdl_core()
   -- Initialises SDL. Returns nothing, but exits if SDL could not be
   -- initialised.
   local returnCode, errorMsg = sdl.init(sdl.flags.Video, sdl.flags.Audio)
   if not returnCode then
      error(errorMsg)
   end
   log.getLogger():info(string.format("SDL Initialised. Version: %d.%d.%d.",
                                      sdl.VERSION_MAJOR, sdl.VERSION_MINOR,
                                      sdl.VERSION_PATCH))
end


function initialise_sdl_image()
   -- Initialises the SDL image module. Returns nothing, but exits if the
   -- module could not be initialised.
   local imageFlags = {sdlImage.flags.PNG}
   local formatsLoaded, returnCode, errorMsg = sdlImage.init(imageFlags)
   for index, flag in ipairs(imageFlags) do
      if not formatsLoaded[flag] then
         error(errorMsg)
      end
   end
   log.getLogger():info("SDL image module initialised.")
end


-- Module table.
return {initialise_all=initialise_all, initialise_sdl_core=initialise_sdl_core,
        initialise_sdl_image=initialise_sdl_image}
