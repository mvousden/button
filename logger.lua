-- Defines a simple singleton logging class, where the logger can be obtained,
-- and created if necessary, by calling getLogger.
--
-- This logger has four levels: DEBUG (1), INFO (2), WARNING (3), and ERROR
-- (4). Log entries are written by calling one of the "debug", "info"
-- etc. methods from the logger table.
--
-- Log entries are printed to the standard output, and to a file by default.

-- Configuration (used at logger creation time).
local logPath = "button.log"  -- The path to the log file, or nil if no file is
                              -- to be written.
local logFileLevel = 1  -- Sets the level below which log entries are not
                        -- printed to the log file.
local logStdoutLevel = 1  -- Likewise for the standard output.

-- Logger behaviour
Logger = {}
Logger.__index = Logger

function Logger:create()
   local logger = {}
   setmetatable(logger, Logger)

   -- Open the file for appending, if it has been defined.
   if logPath then
      logger.logFile = io.open(logPath, "a")
   end

   -- Define logging functions from the levels.

   return logger
end

function Logger:__gc()
   getLogger():debug("Log closed.")
   self.logFile:close()
end

-- http://lua-users.org/wiki/LuaClassesWithMetatable
-- http://lua-users.org/wiki/SimpleLuaClasses
-- https://stackoverflow.com/questions/3078440/destructors-in-lua#3078798
-- http://ultravisual.co.uk/blog/2012/01/29/singletons-in-lua/

-- Singleton pattern functions.
local _logger = nil  -- Holds the logger once created.

function getLogger()
   -- Creates the logger if it has not already been initialised, and returns it
   -- if it has been.
   if _logger then
      return _logger
   else
      _logger = Logger:create()
      getLogger():debug("Log opened.")
   end
end
