-- Defines a simple singleton logging class, where the logger can be obtained,
-- and created if necessary, by calling getLogger.

local logLevels = {"DEBUG", "INFO", "WARNING", "ERROR"}

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


-- Writing functions
function write_message_to_file(message, logFile, level)
   -- Writes a log message to a file. Arguments:
   --   message: String denoting message to write.
   --   logFile: File object to write to.
   --   level: Integer denoting the log level.
   -- Returns nothing.
   logFile:write(message_to_logline(message .. "\n", level))
end


function write_message_to_stdout(message, level)
   -- Writes a log message to standard output. Arguments:
   --   message: String denoting message to write.
   --   level: Integer denoting the log level.
   -- Returns nothing.
   print(message_to_logline(message, level))
end


function message_to_logline(message, level)
   -- Converts a logging message and a logging level to a line entry to be
   -- written either to a file or to the standard output. Arguments:
   --   message: String denoting message to write.
   --   level: Integer denoting the log level.
   -- Returns the line entry as a string.

   return string.format("[%s] %s: %s", os.date("%H:%M:%S"),
                        logLevels[level], message)
end


-- Logger class behaviour
Logger = {}
Logger.__index = Logger


function Logger:create()
   local logger = {}
   setmetatable(logger, Logger)

   -- Open the file for appending, if it has been defined.
   if logPath then
      logger.logFile = io.open(logPath, "a")
   end

   -- Define logging functions from the levels. Iterate over each log level and
   -- "predefine" a logging function for that level.
   for id, level in ipairs(logLevels) do
      if logFileLevel > id and logStdoutLevel > id then
         logger[string.lower(level)] = function(message) end
      elseif logFileLevel > id and logStdoutLevel <= id then
         logger[string.lower(level)] = function(message)
            write_message_to_stdout(message, id)
         end
      elseif logFileLevel <= id and logger.logFile and logStdoutLevel > id then
         logger[string.lower(level)] = function(message)
            write_message_to_file(message, logger.logFile, id)
         end
      elseif logFileLevel <= id and logger.logFile and logStdoutLevel <= id then
         logger[string.lower(level)] = function(message)
            print(string.format("Printing %s", message))
            write_message_to_stdout(message, id)
            write_message_to_file(message, logger.logFile, id)
         end
      end
   end

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
      for key, value in pairs(_logger) do print(key, value) end
      _logger:debug("Log opened.")
      return _logger
   end
end


-- Module table
return {getLogger=getLogger}
